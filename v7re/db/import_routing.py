"""Load a step-1 export directory into SQLite."""

from __future__ import annotations

import csv
import gzip
import json
import sqlite3
from datetime import datetime, timezone
from pathlib import Path

SCHEMA = Path(__file__).with_name("schema_routing.sql")


def _now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def import_topology(root: Path, db_path: Path, manifest: dict | None = None) -> dict:
    root = Path(root)
    db_path.parent.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(db_path)
    try:
        con.executescript(SCHEMA.read_text(encoding="utf-8"))
        summary = json.loads((root / "summary.json").read_text(encoding="utf-8"))
        part = summary.get("part") or "xc7vx485tffg1761-2"

        con.execute("DELETE FROM tiles")
        with gzip.open(root / "tiles.csv.gz", "rt", encoding="utf-8", newline="") as fh:
            con.executemany(
                "INSERT INTO tiles(tile_name,type,grid_x,grid_y,clock_region,"
                "wire_count,pip_count) VALUES(?,?,?,?,?,?,?)",
                ((r["tile_name"], r["type"], int(r["grid_x"]), int(r["grid_y"]),
                  r["clock_region"], int(r["wire_count"]), int(r["pip_count"]))
                 for r in csv.DictReader(fh)),
            )

        uniform = json.loads((root / "type_uniformity.json").read_text(encoding="utf-8"))
        con.execute("DELETE FROM tile_types")
        for tname, meta in uniform.items():
            tpl = root / "templates" / f"{tname}.json"
            d = json.loads(tpl.read_text(encoding="utf-8"))
            import hashlib
            con.execute(
                "INSERT INTO tile_types(type,instances,wires,pips,uniform,template,"
                "template_sha) VALUES(?,?,?,?,?,?,?)",
                (tname, meta["instances"], len(d["wire_defs"]), len(d["pip_defs"]),
                 int(bool(meta["uniform"])), str(tpl.relative_to(root)),
                 hashlib.sha256(tpl.read_bytes()).hexdigest()),
            )

        conn_dir = root / "conns"
        con.execute("DELETE FROM conn_rules")
        links = 0
        if conn_dir.exists():
            known = set(uniform)
            for f in conn_dir.glob("*.json"):
                if f.stem not in known:
                    continue
                d = json.loads(f.read_text(encoding="utf-8"))
                rows = [(d["type"], wire, dx, dy, ttype, twire)
                        for wire, entries in d["links"].items()
                        for dx, dy, ttype, twire in entries]
                con.executemany(
                    "INSERT OR IGNORE INTO conn_rules(type,wire,dx,dy,target_type,"
                    "target_wire) VALUES(?,?,?,?,?,?)", rows)
                links += len(rows)

        con.execute("INSERT OR REPLACE INTO meta(key,value) VALUES('part',?)", (part,))
        con.execute("INSERT OR REPLACE INTO meta(key,value) VALUES('imported_at',?)",
                    (_now(),))
        if manifest:
            con.execute("DELETE FROM artifacts WHERE stage='s01_topology'")
            con.executemany(
                "INSERT OR REPLACE INTO artifacts(stage,path,bytes,sha256) "
                "VALUES('s01_topology',?,?,?)",
                ((p, m["bytes"], m["sha256"]) for p, m in manifest["files"].items()),
            )
        con.execute(
            "INSERT OR REPLACE INTO stages(stage,part,status,started_at,finished_at,"
            "result_json) VALUES('s01_topology',?,?,?,?,?)",
            (part, "done", None, _now(),
             json.dumps({"tiles": summary["tiles"], "types": summary["types"],
                         "wires": summary["wires"], "pips": summary["pips"],
                         "conn_links": links})),
        )
        con.commit()
        return {"db": str(db_path), "tiles": summary["tiles"], "types": summary["types"],
                "wires": summary["wires"], "pips": summary["pips"],
                "conn_links": links}
    finally:
        con.close()
