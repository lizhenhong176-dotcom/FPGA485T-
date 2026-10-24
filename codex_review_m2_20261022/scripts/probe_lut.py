#!/usr/bin/env python3
"""Clean probe for one (LOC, BEL): build DCP, write two INIT variants, diff."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from config import PART, work_root
from vivado.probe import probe


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--loc", required=True, help="e.g. SLICE_X10Y10")
    ap.add_argument("--bel", default="A6LUT", help="e.g. A6LUT / B6LUT")
    ap.add_argument("--init-a", default="0000000000000001")
    ap.add_argument("--init-b", default="0000000000000002")
    ap.add_argument("--part", default=PART)
    ap.add_argument("--workdir", default=None)
    ap.add_argument("--rebuild", action="store_true", help="force re-implementation")
    args = ap.parse_args()

    if args.workdir:
        workdir = Path(args.workdir)
    else:
        safe = args.loc.replace(":", "_")
        workdir = work_root() / "probe" / safe / args.bel

    result = probe(
        workdir=workdir,
        loc=args.loc,
        bel=args.bel,
        init_a=args.init_a,
        init_b=args.init_b,
        part=args.part,
        rebuild=args.rebuild,
    )

    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
