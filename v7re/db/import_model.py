"""Build the canonical V7 model database from the split source databases.

Sources:
  * P0 site boundary: ``v7_p0.sqlite`` (86,022 fabric sites, BEL/site pins)
  * current probe DB: ``v7.sqlite`` (raw probes and probe_bits)
  * routing metadata: ``v7_routing.db`` (tiles and tile_types only)

Routing edges/PIP geometry are deliberately *not* copied; attach
``v7_routing.db`` when a query needs ``edges_exact``/``tileconn``.

The import is reproducible: it deletes and rebuilds the target file, writes
source hashes into ``meta``, and records the run in ``stages``.
"""

from __future__ import annotations

import hashlib
import json
import sqlite3
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCHEMA = HERE / "schema_model.sql"

DEFAULT_P0_DB = Path(r"E:\v7work\p0\v7_p0.sqlite")
DEFAULT_PROBE_DB = Path(r"E:\v7work\_curated_20261021\db\v7.sqlite")
DEFAULT_ROUTING_DB = Path(r"E:\v7work\_curated_20261021\routing\v7_routing.db")
DEFAULT_OUT = Path(r"E:\v7work\model\v7_model.sqlite")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _attach(conn: sqlite3.Connection, path: Path, name: str) -> None:
    if not path.exists():
        raise FileNotFoundError(path)
    # Source DBs live in read-only directories on the Linux host.  immutable
    # prevents SQLite from trying to create a WAL/journal beside them.
    uri = f"file:{path.as_posix()}?mode=ro&immutable=1"
    conn.execute(f"ATTACH DATABASE ? AS {name}", (uri,))


def build(
    out: str | Path = DEFAULT_OUT,
    p0_db: str | Path = DEFAULT_P0_DB,
    probe_db: str | Path = DEFAULT_PROBE_DB,
    routing_db: str | Path = DEFAULT_ROUTING_DB,
    *,
    hash_sources: bool = True,
    strict_counts: bool = True,
) -> dict:
    out = Path(out)
    p0_db = Path(p0_db)
    probe_db = Path(probe_db)
    routing_db = Path(routing_db)
    out.parent.mkdir(parents=True, exist_ok=True)
    for suffix in ("", "-wal", "-shm"):
        p = Path(str(out) + suffix)
        if p.exists():
            p.unlink()

    started = time.time()
    conn = sqlite3.connect(f"file:{out.as_posix()}?mode=rwc", uri=True)
    conn.execute("PRAGMA journal_mode=OFF")
    conn.execute("PRAGMA synchronous=OFF")
    conn.execute("PRAGMA temp_store=MEMORY")
    conn.execute("PRAGMA cache_size=-200000")
    conn.executescript(SCHEMA.read_text(encoding="utf-8"))

    try:
        meta = dict(conn.execute("SELECT key, value FROM meta").fetchall())
    except sqlite3.OperationalError:
        meta = {}

    _attach(conn, p0_db, "p0")
    _attach(conn, probe_db, "old")
    _attach(conn, routing_db, "routing")

    # Device/part from P0.
    p0_meta = dict(conn.execute("SELECT key, value FROM p0.meta").fetchall())
    part = p0_meta["part"]
    device = p0_meta["device"]

    # P0 templates.
    conn.execute(
        "INSERT INTO site_types(site_type,instances,representative,template_json)"
        " SELECT type,instances,representative,template_json FROM p0.site_types"
    )
    conn.execute(
        "INSERT INTO site_bels(site_type,bel) SELECT site_type,bel FROM p0.site_bels"
    )
    conn.execute(
        "INSERT INTO site_bel_pins(site_type,bel,pin,direction,site_wire,site_pin)"
        " SELECT site_type,bel,pin,direction,site_wire,site_pin FROM p0.site_bel_pins"
    )
    conn.execute(
        "INSERT INTO site_type_pips(site_type,name,bel,input_pin,output_pin,"
        "input_site_wire,output_site_wire)"
        " SELECT site_type,name,bel,input_pin,output_pin,"
        "input_site_wire,output_site_wire FROM p0.site_type_pips"
    )
    conn.execute(
        "INSERT INTO site_wires(site_type,wire,direction,is_site_pin)"
        " SELECT site_type,wire,direction,is_site_pin FROM p0.site_wires"
    )

    # Canonical sites: one row per strict-fabric instance.
    conn.execute(
        "INSERT INTO sites(device,site,site_type,tile,tile_type,clock_region,"
        "row,col,instance_x,instance_y,fabric)"
        " SELECT ?, site, site_type, tile_name, tile_type, clock_region,"
        "        instance_y, instance_x, instance_x, instance_y, 1"
        " FROM p0.site_instances",
        (device,),
    )

    # Per-instance site pin -> tile wire, with site name as the key.
    conn.execute(
        "INSERT INTO site_pins(device,site,site_pin,direction,tile_wire)"
        " SELECT ?, i.site, p.site_pin, p.direction, p.tile_wire"
        " FROM p0.site_pin_wires p JOIN p0.site_instances i ON i.id = p.site_id",
        (device,),
    )

    # Routing metadata only (not the 1.29 GB edge set).
    conn.execute(
        "INSERT INTO tiles(tile_name,type,grid_x,grid_y,clock_region,wire_count,pip_count)"
        " SELECT tile_name,type,grid_x,grid_y,clock_region,wire_count,pip_count"
        " FROM routing.tiles"
    )
    conn.execute(
        "INSERT INTO tile_types(type,instances,wires,pips,uniform,template,template_sha)"
        " SELECT type,instances,wires,pips,uniform,template,template_sha"
        " FROM routing.tile_types"
    )

    # Probe observations; only legal sites are kept.
    conn.execute(
        "INSERT INTO probes(device,loc,bel,init_a,init_b,frames,bits,created_at)"
        " SELECT ?, p.loc, p.bel, p.init_a, p.init_b, p.frames, p.bits, p.created_at"
        " FROM old.probes p"
        " WHERE p.loc IN (SELECT site FROM sites WHERE device=?)",
        (device, device),
    )
    conn.execute(
        "INSERT INTO probe_bits(device,loc,bel,frame,word,bit,init_a,init_b)"
        " SELECT ?, b.loc, b.bel, b.frame, b.word, b.bit, b.init_a, b.init_b"
        " FROM old.probe_bits b"
        " WHERE b.loc IN (SELECT site FROM sites WHERE device=?)",
        (device, device),
    )

    counts = {}
    for table in (
        "sites",
        "site_types",
        "site_bels",
        "site_bel_pins",
        "site_type_pips",
        "site_wires",
        "site_pins",
        "tiles",
        "tile_types",
        "probes",
        "probe_bits",
        "region_bases",
        "column_offsets",
        "site_frames",
        "bit_map",
        "pip_bits",
    ):
        counts[table] = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]

    # Integrity checks before declaring success.
    if strict_counts and counts["sites"] != 86022:
        raise RuntimeError(f"expected 86022 fabric sites, got {counts['sites']}")
    if strict_counts and counts["site_pins"] != 5489706:
        raise RuntimeError(f"expected 5489706 site pins, got {counts['site_pins']}")
    missing_probe_sites = conn.execute(
        "SELECT COUNT(*) FROM probes p LEFT JOIN sites s"
        " ON s.site=p.loc AND s.device=p.device WHERE s.site IS NULL"
    ).fetchone()[0]
    if missing_probe_sites:
        raise RuntimeError(f"{missing_probe_sites} probes refer to non-fabric sites")
    conn.execute("PRAGMA foreign_key_check")

    source_hashes = {}
    if hash_sources:
        source_hashes = {
            "p0_db": sha256_file(p0_db),
            "probe_db": sha256_file(probe_db),
            "routing_db": sha256_file(routing_db),
        }

    meta_rows = [
        ("part", part),
        ("device", device),
        ("schema", "model-v1"),
        ("built_at", time.strftime("%Y-%m-%dT%H:%M:%S%z")),
        ("p0_db", str(p0_db)),
        ("probe_db", str(probe_db)),
        ("routing_db", str(routing_db)),
        ("count_sites", str(counts["sites"])),
        ("count_site_types", str(counts["site_types"])),
        ("count_site_pins", str(counts["site_pins"])),
        ("count_probes", str(counts["probes"])),
        ("count_probe_bits", str(counts["probe_bits"])),
        ("count_tiles", str(counts["tiles"])),
        ("count_tile_types", str(counts["tile_types"])),
    ]
    meta_rows += [(f"source_{k}", v) for k, v in source_hashes.items()]
    conn.executemany("INSERT OR REPLACE INTO meta(key,value) VALUES (?,?)", meta_rows)

    conn.execute(
        "INSERT OR REPLACE INTO stages(stage,part,status,started_at,finished_at,result_json)"
        " VALUES (?,?,?,?,?,?)",
        (
            "m00_model",
            part,
            "done",
            time.strftime("%Y-%m-%dT%H:%M:%S"),
            time.strftime("%Y-%m-%dT%H:%M:%S"),
            json.dumps(counts, sort_keys=True),
        ),
    )
    conn.commit()
    elapsed = time.time() - started
    result = {
        "out": str(out),
        "bytes": out.stat().st_size,
        "elapsed_s": round(elapsed, 2),
        "counts": counts,
        "source_hashes": source_hashes,
    }
    conn.close()
    return result


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--p0-db", default=str(DEFAULT_P0_DB))
    ap.add_argument("--probe-db", default=str(DEFAULT_PROBE_DB))
    ap.add_argument("--routing-db", default=str(DEFAULT_ROUTING_DB))
    ap.add_argument("--no-hash", action="store_true")
    args = ap.parse_args()
    result = build(
        out=args.out,
        p0_db=args.p0_db,
        probe_db=args.probe_db,
        routing_db=args.routing_db,
        hash_sources=not args.no_hash,
    )
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
