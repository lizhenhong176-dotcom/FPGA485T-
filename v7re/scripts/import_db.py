"""Build the SQLite probe database from site table + clean-probe results."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from config import PART, work_root
from db.import_results import connect, import_probes, import_sites


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--db",
        default=str(work_root() / "db" / "v7.sqlite"),
        help="output SQLite database",
    )
    ap.add_argument(
        "--probe-root",
        default=str(work_root()),
        help="directory searched recursively for result.json",
    )
    ap.add_argument(
        "--exclude",
        default="legacy,codex_runs",
        help="comma-separated directory names to skip under --probe-root",
    )
    ap.add_argument(
        "--site-table",
        default=str(work_root() / "db" / "site_table_xc7vx485tffg1761_2.json"),
        help="site table JSON from scripts/enumerate_sites.py",
    )
    ap.add_argument("--part", default=PART)
    ap.add_argument("--skip-sites", action="store_true")
    args = ap.parse_args()

    conn = connect(args.db)
    try:
        if not args.skip_sites:
            n_sites = import_sites(conn, args.site_table, args.part)
            print(f"sites: {n_sites}")
        exclude = tuple(x for x in args.exclude.split(",") if x)
        counts = import_probes(conn, args.probe_root, args.part, exclude=exclude)
        print(f"probes: {counts['probes']}, bits: {counts['bits']}")
        print(f"db: {args.db}")
    finally:
        conn.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
