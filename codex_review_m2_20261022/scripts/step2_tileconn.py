"""Step 2 CLI: import canonical tile connections and query them offline.

Usage:
    python -m v7re.scripts.step2_tileconn import
    python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0
    python -m v7re.scripts.step2_tileconn stats
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))

from v7re.routing.tileconn import TileConn  # noqa: E402

RULES_DB = Path(r"E:\v7work\routing\step02\rules.db")
ROUTING_DB = Path(r"E:\v7work\routing\v7_routing.db")
TILES_GZ = Path(r"E:\v7work\routing\out_routing\tiles.csv.gz")


def cmd_import(args: argparse.Namespace) -> int:
    from v7re.db.import_tileconn import main as import_main

    sys.argv = ["import_tileconn", "--rules-db", str(args.rules_db),
                "--db", str(args.db), "--validation", str(args.validation)]
    return import_main()


def cmd_query(args: argparse.Namespace) -> int:
    table = TileConn.load(args.rules_db, args.tiles_gz)
    for target in table.edges(args.tile, args.wire):
        print(target.grid_x, target.grid_y, target.type, ",".join(target.wires))
    return 0


def cmd_stats(args: argparse.Namespace) -> int:
    if args.source == "rules":
        con = sqlite3.connect(f"file:{args.rules_db}?mode=ro", uri=True)
        rows = con.execute("SELECT COUNT(*), COUNT(DISTINCT family) FROM rules").fetchone()
        meta = dict(con.execute("SELECT k, v FROM meta").fetchall())
    else:
        con = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
        rows = con.execute("SELECT COUNT(*), COUNT(DISTINCT family) FROM tileconn").fetchone()
        meta = dict(con.execute("SELECT key, value FROM meta").fetchall())
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
    p.add_argument("--rules-db", default=str(RULES_DB))
    p.add_argument("--tiles-gz", default=str(TILES_GZ))
    p.set_defaults(func=cmd_query)

    p = sub.add_parser("stats")
    p.add_argument("--source", choices=["rules", "db"], default="rules")
    p.add_argument("--rules-db", default=str(RULES_DB))
    p.add_argument("--db", default=str(ROUTING_DB))
    p.set_defaults(func=cmd_stats)

    args = ap.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
