"""Import P0 site-topology exports into a queryable SQLite database.

Inputs are produced by scripts/export_site_topology.py:
  site_types.json
  site_instances.csv
  site_pin_wires.csv.gz
  validation.json

The database is intentionally independent of v7.sqlite (probe data).  The
site_pin_wires table is the join point to the routing database: tile_wire is
the same wire name used by routing/v7_routing.db.
"""

from __future__ import annotations

import argparse
import csv
import gzip
import hashlib
import json
import sqlite3
import time
from pathlib import Path

DEFAULT_P0 = Path(r"E:\v7work\p0")
DEFAULT_DB = Path(r"E:\v7work\p0\v7_p0.sqlite")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def connect(path: Path) -> sqlite3.Connection:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        path.unlink()
    conn = sqlite3.connect(str(path))
    conn.execute("PRAGMA journal_mode=OFF")
    conn.execute("PRAGMA synchronous=OFF")
    conn.execute("PRAGMA temp_store=MEMORY")
    conn.execute("PRAGMA cache_size=-200000")
    return conn


SCHEMA = """
CREATE TABLE meta (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

CREATE TABLE site_types (
    type TEXT PRIMARY KEY,
    instances INTEGER NOT NULL,
    representative TEXT NOT NULL,
    template_json TEXT NOT NULL
);

CREATE TABLE site_bels (
    site_type TEXT NOT NULL,
    bel TEXT NOT NULL,
    PRIMARY KEY (site_type, bel)
);

CREATE TABLE site_bel_pins (
    site_type TEXT NOT NULL,
    bel TEXT NOT NULL,
    pin TEXT NOT NULL,
    direction TEXT NOT NULL,
    site_wire TEXT NOT NULL,
    site_pin TEXT NOT NULL,
    PRIMARY KEY (site_type, bel, pin)
);

CREATE TABLE site_type_pips (
    site_type TEXT NOT NULL,
    name TEXT NOT NULL,
    bel TEXT NOT NULL,
    input_pin TEXT NOT NULL,
    output_pin TEXT NOT NULL,
    input_site_wire TEXT NOT NULL,
    output_site_wire TEXT NOT NULL,
    PRIMARY KEY (site_type, bel, name)
);

CREATE TABLE site_wires (
    site_type TEXT NOT NULL,
    wire TEXT NOT NULL,
    direction TEXT NOT NULL,
    is_site_pin INTEGER NOT NULL,
    PRIMARY KEY (site_type, wire)
);

CREATE TABLE site_instances (
    id INTEGER PRIMARY KEY,
    site TEXT NOT NULL UNIQUE,
    site_type TEXT NOT NULL,
    tile_name TEXT NOT NULL,
    tile_type TEXT NOT NULL,
    grid_x INTEGER NOT NULL,
    grid_y INTEGER NOT NULL,
    clock_region TEXT,
    instance_x INTEGER,
    instance_y INTEGER
);

CREATE TABLE site_pin_wires (
    site_id INTEGER NOT NULL,
    site_pin TEXT NOT NULL,
    direction TEXT NOT NULL,
    tile_wire TEXT NOT NULL,
    PRIMARY KEY (site_id, site_pin)
) WITHOUT ROWID;

CREATE INDEX idx_site_pin_wires_wire ON site_pin_wires(tile_wire);
CREATE INDEX idx_site_instances_type ON site_instances(site_type);
CREATE INDEX idx_site_bel_pins_wire ON site_bel_pins(site_type, site_wire);
"""


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--p0", default=str(DEFAULT_P0))
    ap.add_argument("--db", default=str(DEFAULT_DB))
    args = ap.parse_args()

    p0 = Path(args.p0)
    db = Path(args.db)
    started = time.time()
    types = json.loads((p0 / "site_types.json").read_text(encoding="utf-8"))
    validation = json.loads((p0 / "validation.json").read_text(encoding="utf-8"))
    if not validation.get("passed"):
        raise SystemExit("refusing to import failed validation.json")

    conn = connect(db)
    try:
        conn.executescript(SCHEMA)
        conn.executemany(
            "INSERT INTO meta(key,value) VALUES (?,?)",
            [
                ("part", types["part"]),
                ("device", types["device"]),
                ("fabric_sites", str(types["fabric_sites"])),
                ("site_types", str(len(types["site_types"]))),
                ("site_pin_wires", str(validation["site_pin_wires"])),
                ("source_tilegrid_sha256", types["source_tilegrid_sha256"]),
                ("source_sites_sha256", types["source_sites_sha256"]),
                ("validated", "1"),
            ],
        )

        site_id: dict[str, int] = {}
        next_id = 1
        inst_rows = []
        for row in csv.DictReader((p0 / "site_instances.csv").open(encoding="utf-8", newline="")):
            sid = next_id
            next_id += 1
            site_id[row["site"]] = sid
            inst_rows.append(
                (
                    sid,
                    row["site"],
                    row["site_type"],
                    row["tile_name"],
                    row["tile_type"],
                    int(row["grid_x"]),
                    int(row["grid_y"]),
                    row["clock_region"] or None,
                    int(row["instance_x"]) if row["instance_x"] else None,
                    int(row["instance_y"]) if row["instance_y"] else None,
                )
            )
        conn.executemany(
            "INSERT INTO site_instances(id,site,site_type,tile_name,tile_type,grid_x,grid_y,clock_region,instance_x,instance_y) VALUES (?,?,?,?,?,?,?,?,?,?)",
            inst_rows,
        )
        print(f"site_instances: {len(inst_rows)}", flush=True)

        type_rows = []
        bel_rows = []
        pin_rows = []
        pip_rows = []
        wire_rows = []
        for site_type, tpl in types["site_types"].items():
            type_rows.append(
                (site_type, tpl["instances"], tpl["representative"], json.dumps(tpl, sort_keys=True))
            )
            for bel in tpl["bels"]:
                bel_rows.append((site_type, bel["name"]))
                for pin in bel["pins"]:
                    pin_rows.append(
                        (
                            site_type,
                            bel["name"],
                            pin["name"],
                            pin["direction"],
                            pin["site_wire"],
                            pin["site_pin"],
                        )
                    )
            for pip in tpl["site_pips"]:
                pip_rows.append(
                    (
                        site_type,
                        pip["name"],
                        pip["bel"],
                        pip["input_pin"],
                        pip["output_pin"],
                        pip["input_site_wire"],
                        pip["output_site_wire"],
                    )
                )
            for wire in tpl["site_wires"]:
                wire_rows.append(
                    (
                        site_type,
                        wire["name"],
                        wire["direction"],
                        1 if wire["is_site_pin"] else 0,
                    )
                )
        conn.executemany(
            "INSERT INTO site_types(type,instances,representative,template_json) VALUES (?,?,?,?)",
            type_rows,
        )
        conn.executemany("INSERT INTO site_bels(site_type,bel) VALUES (?,?)", bel_rows)
        conn.executemany(
            "INSERT INTO site_bel_pins(site_type,bel,pin,direction,site_wire,site_pin) VALUES (?,?,?,?,?,?)",
            pin_rows,
        )
        conn.executemany(
            "INSERT INTO site_type_pips(site_type,name,bel,input_pin,output_pin,input_site_wire,output_site_wire) VALUES (?,?,?,?,?,?,?)",
            pip_rows,
        )
        conn.executemany(
            "INSERT INTO site_wires(site_type,wire,direction,is_site_pin) VALUES (?,?,?,?)",
            wire_rows,
        )
        print(
            f"templates: bels={len(bel_rows)} bel_pins={len(pin_rows)} "
            f"pips={len(pip_rows)} wires={len(wire_rows)}",
            flush=True,
        )

        batch = []
        n = 0
        with gzip.open(p0 / "site_pin_wires.csv.gz", "rt", encoding="utf-8", newline="") as f:
            for row in csv.DictReader(f):
                sid = site_id.get(row["site"])
                if sid is None:
                    raise SystemExit(f"site_pin_wires refers to missing site: {row['site']}")
                batch.append((sid, row["site_pin"], row["direction"], row["tile_wire"]))
                n += 1
                if len(batch) >= 100000:
                    conn.executemany(
                        "INSERT INTO site_pin_wires(site_id,site_pin,direction,tile_wire) VALUES (?,?,?,?)",
                        batch,
                    )
                    batch.clear()
                    print(f"site_pin_wires: {n}", flush=True)
        if batch:
            conn.executemany(
                "INSERT INTO site_pin_wires(site_id,site_pin,direction,tile_wire) VALUES (?,?,?,?)",
                batch,
            )
        print(f"site_pin_wires: {n}", flush=True)

        conn.execute("CREATE INDEX idx_site_instances_site ON site_instances(site)")
        conn.commit()
        counts = {}
        for table in (
            "site_types",
            "site_bels",
            "site_bel_pins",
            "site_type_pips",
            "site_wires",
            "site_instances",
            "site_pin_wires",
        ):
            counts[table] = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        conn.executemany(
            "INSERT INTO meta(key,value) VALUES (?,?)",
            [(f"count_{k}", str(v)) for k, v in counts.items()],
        )
        conn.commit()
        print(f"db: {db}", flush=True)
        print(json.dumps(counts, indent=2), flush=True)
        print(f"elapsed: {time.time() - started:.1f}s", flush=True)
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
