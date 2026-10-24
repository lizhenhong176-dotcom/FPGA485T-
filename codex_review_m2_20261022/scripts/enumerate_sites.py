"""Enumerate FPGA sites with Vivado and write a reusable JSON table."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from config import PART, work_root
from vivado.sites import DEFAULT_SITE_TYPES, enumerate_sites


def safe_name(value: str) -> str:
    return "".join(c if c.isalnum() else "_" for c in value)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--part", default=PART)
    ap.add_argument(
        "--types",
        default=",".join(DEFAULT_SITE_TYPES),
        help="comma-separated SITE_TYPE values, or 'all'",
    )
    ap.add_argument(
        "--workdir",
        default=str(work_root() / "db" / "site_enum"),
        help="Vivado scratch directory",
    )
    ap.add_argument("--out", default=None, help="output JSON path")
    ap.add_argument("--timeout", type=int, default=900)
    args = ap.parse_args()

    types = None if args.types.strip().lower() == "all" else tuple(
        t.strip() for t in args.types.split(",") if t.strip()
    )
    out = Path(args.out) if args.out else (
        work_root() / "db" / f"site_table_{safe_name(args.part)}.json"
    )

    payload = enumerate_sites(
        args.workdir,
        part=args.part,
        types=types,
        timeout=args.timeout,
    )
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    by_type: dict[str, int] = {}
    for site in payload["sites"]:
        by_type[site["type"]] = by_type.get(site["type"], 0) + 1
    print(f"device={payload['device']} count={payload['count']}")
    for key in sorted(by_type):
        print(f"  {key}: {by_type[key]}")
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
