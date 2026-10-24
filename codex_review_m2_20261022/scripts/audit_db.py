"""Audit imported probe word positions against the site table."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from config import work_root  # noqa: E402
from db.import_results import connect  # noqa: E402
from db.audit import audit_word_positions  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--db",
        default=str(work_root() / "db" / "v7.sqlite"),
        help="SQLite database to audit",
    )
    args = ap.parse_args()

    conn = connect(Path(args.db))
    try:
        errors, checked = audit_word_positions(conn)
    finally:
        conn.close()
    print(f"checked {checked} LUT6 words")
    if errors:
        print(f"{len(errors)} error(s):")
        for err in errors:
            print("  " + err)
        return 1
    print("OK: every non-aux word matches 2*(row%50)+half")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
