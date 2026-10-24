#!/usr/bin/env python3
"""Sweep many LOCs with the clean probe and record results."""

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
from vivado.probe import probe


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--locs", required=True, help="comma-separated SLICE_X..Y.. list")
    ap.add_argument("--bel", default="A6LUT")
    ap.add_argument("--init-a", default="0000000000000001")
    ap.add_argument("--init-b", default="0000000000000002")
    ap.add_argument("--part", default=PART)
    ap.add_argument("--work-root", default=None)
    ap.add_argument("--rebuild", action="store_true")
    args = ap.parse_args()

    root = Path(args.work_root) if args.work_root else work_root() / "sweep"
    root.mkdir(parents=True, exist_ok=True)

    locs = [s.strip() for s in args.locs.split(",") if s.strip()]
    results = []

    for loc in locs:
        workdir = root / loc.replace(":", "_") / args.bel
        try:
            result = probe(
                workdir=workdir,
                loc=loc,
                bel=args.bel,
                init_a=args.init_a,
                init_b=args.init_b,
                part=args.part,
                rebuild=args.rebuild,
            )
        except Exception as exc:  # keep the sweep going
            print(f"{loc:18s} FAILED: {exc}")
            results.append({"loc": loc, "error": str(exc)})
            continue

        results.append(result)
        frames = result["diff_frames"]
        bits = sum(len(v) for v in result["bits"].values())
        print(f"{loc:18s} frames={frames} bits={bits}")

    (root / "results.json").write_text(
        json.dumps(results, indent=2), encoding="utf-8"
    )

    csv_path = root / "results.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["loc", "bel", "frames", "bit_count", "error"])
        for r in results:
            frames = r.get("diff_frames", [])
            bits = sum(len(v) for v in r.get("bits", {}).values())
            writer.writerow(
                [
                    r.get("loc"),
                    r.get("bel", args.bel),
                    ";".join(map(str, frames)),
                    bits,
                    r.get("error", ""),
                ]
            )

    print(f"wrote {root / 'results.json'}")
    print(f"wrote {csv_path}")


if __name__ == "__main__":
    main()
