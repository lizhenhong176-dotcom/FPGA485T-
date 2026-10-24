"""Step 2 CLI: query canonical tile connections offline.

Two sources:

    --source rules   corridor rule table (compact, learned by step02)
    --source exact   materialised ground-truth edges (exact, ~40M rows)

Usage:
    python -m v7re.scripts.step2_tileconn import
    python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0
    python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0 --source exact
    python -m v7re.scripts.step2_tileconn stats --source exact
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from v7re.routing.tileconn import ExactEdges, TileConn  # noqa: E402

RULES_DB = Path(r"E:\v7work\routing\step02\rules.db")
ROUTING_DB = Path(r"E:\v7work\routing\v7_routing.db")
TILES_GZ = Path(r"E:\v7work\routing\out_routing\tiles.csv.gz")


def cmd_import(args: argparse.Namespace) -> int:
    from v7re.db.import_tileconn import main as import_main

    sys.argv = ["import_tileconn", "--rules-db", str(args.rules_db),
                "--db", str(args.db), "--validation", str(args.validation)]
    return import_main()


def cmd_query(args: argparse.Namespace) -> int:
    if args.source == "exact":
        table = ExactEdges.load(args.db)
        for target in table.edges(args.tile, args.wire):
            print(target.grid_x, target.grid_y, target.type, ",".join(target.wires))
        return 0
    rules = TileConn.load(args.rules_db, args.tiles_gz)
    for target in rules.edges(args.tile, args.wire):
        print(target.grid_x, target.grid_y, target.type, ",".join(target.wires))
    return 0


def cmd_stats(args: argparse.Namespace) -> int:
    if args.source == "exact":
        con = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
        edges = con.execute("SELECT COUNT(*) FROM edges_exact").fetchone()[0]
        tiles = con.execute("SELECT COUNT(*) FROM edge_tiles").fetchone()[0]
        wires = con.execute("SELECT COUNT(*) FROM edge_wires").fetchone()[0]
        meta = dict(con.execute("SELECT key, value FROM meta").fetchall())
        con.close()
        print(json.dumps({"edges": edges, "tiles": tiles, "wires": wires,
                          "meta": meta}, indent=1))
        return 0
    if args.source == "db":
        con = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
        rows = con.execute("SELECT COUNT(*), COUNT(DISTINCT family) FROM tileconn").fetchone()
        meta = dict(con.execute("SELECT key, value FROM meta").fetchall())
        con.close()
        print(json.dumps({"entries": rows[0], "families": rows[1], "meta": meta}, indent=1))
        return 0
    con = sqlite3.connect(f"file:{args.rules_db}?mode=ro", uri=True)
    rows = con.execute("SELECT COUNT(*), COUNT(DISTINCT family) FROM rules").fetchone()
    meta = dict(con.execute("SELECT k, v FROM meta").fetchall())
    con.close()
    print(json.dumps({"entries": rows[0], "families": rows[1], "meta": meta}, indent=1))
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("import")
    p.add_argument("--rules-db", default=str(RULES_DB))
    p.add_argument("--db", default=str(ROUTING_DB))
    p.add_argument("--validation", default=r"E:\v7work\routing\step02\validation.json")
    p.set_defaults(func=cmd_import)

    p = sub.add_parser("query")
    p.add_argument("--tile", required=True)
    p.add_argument("--wire", required=True)
    p.add_argument("--source", choices=["rules", "exact"], default="rules")
    p.add_argument("--rules-db", default=str(RULES_DB))
    p.add_argument("--db", default=str(ROUTING_DB))
    p.add_argument("--tiles-gz", default=str(TILES_GZ))
    p.set_defaults(func=cmd_query)

    p = sub.add_parser("stats")
    p.add_argument("--source", choices=["rules", "db", "exact"], default="rules")
    p.add_argument("--rules-db", default=str(RULES_DB))
    p.add_argument("--db", default=str(ROUTING_DB))
    p.set_defaults(func=cmd_stats)

    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
