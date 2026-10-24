"""Build a spread-out LUT6 probe manifest from a site table."""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from config import PART, work_root
from vivado.sites import DEFAULT_SITE_TYPES


def safe_name(value: str) -> str:
    return "".join(c if c.isalnum() else "_" for c in value)


def spread_indices(total: int, count: int) -> list[int]:
    if count >= total:
        return list(range(total))
    if count <= 1:
        return [0]
    seen: list[int] = []
    for i in range(count):
        idx = round(i * (total - 1) / (count - 1))
        if idx not in seen:
            seen.append(idx)
    return seen


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--sites",
        default=str(work_root() / "db" / f"site_table_{safe_name(PART)}.json"),
    )
    ap.add_argument("--count", type=int, default=20)
    ap.add_argument("--bel", default="A6LUT")
    ap.add_argument("--init-a", default="0000000000000001")
    ap.add_argument("--init-b", default="0000000000000002")
    ap.add_argument(
        "--types", default=",".join(DEFAULT_SITE_TYPES), help="comma-separated site types"
    )
    ap.add_argument("--tags", default="p0-smoke")
    ap.add_argument(
        "--out",
        default=None,
        help="output CSV (default E:/v7work/db/manifests/lut6_<count>.csv)",
    )
    args = ap.parse_args()

    types = {t.strip() for t in args.types.split(",") if t.strip()}
    payload = json.loads(Path(args.sites).read_text(encoding="utf-8"))
    sites = [
        s
        for s in payload.get("sites", [])
        if s.get("type") in types
        and (not s.get("bels") or args.bel in s.get("bels", []))
    ]
    sites.sort(
        key=lambda s: (
            s.get("row") is None,
            s.get("row") or 0,
            s.get("column") is None,
            s.get("column") or 0,
            s.get("site", ""),
        )
    )
    if not sites:
        print(f"no usable sites in {args.sites}", file=sys.stderr)
        return 1

    chosen = [sites[i] for i in spread_indices(len(sites), args.count)]
    out = (
        Path(args.out)
        if args.out
        else work_root() / "db" / "manifests" / f"lut6_{args.count}.csv"
    )
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8", newline="") as fh:
        writer = csv.writer(fh)
        writer.writerow(["loc", "bel", "init_a", "init_b", "tags"])
        for site in chosen:
            writer.writerow(
                [
                    site["site"],
                    args.bel,
                    args.init_a,
                    args.init_b,
                    args.tags,
                ]
            )

    print(f"picked {len(chosen)} of {len(sites)} usable sites")
    print(", ".join(s["site"] for s in chosen))
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
