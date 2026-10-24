#!/usr/bin/env python3
"""Generate synthetic run directories to self-test verify_run.py."""

from __future__ import annotations

import csv
import json
import sys
import time
from pathlib import Path

BASES = {0: 31748, 1: 26502, 2: 22000, 3: 5520, 4: 2140, 5: 1000}
DX = {10: 0, 20: 208, 40: 680, 60: 1224, 80: 1666, 100: 2086,
      120: 2588, 140: 3060, 160: 3504, 180: 4048, 200: 4520, 220: 4936}
POINTS = [
    ("SLICE_X10Y50", 1, 10), ("SLICE_X10Y100", 2, 10), ("SLICE_X10Y150", 3, 10),
    ("SLICE_X10Y200", 4, 10), ("SLICE_X10Y250", 5, 10),
    ("SLICE_X10Y160", 3, 10), ("SLICE_X60Y160", 3, 60), ("SLICE_X80Y160", 3, 80),
    ("SLICE_X180Y160", 3, 180), ("SLICE_X220Y160", 3, 220),
]


def build(root: Path, skew: int = 0, drop: str | None = None) -> None:
    root.mkdir(parents=True, exist_ok=True)
    rows, points = [], []
    for loc, region, x in POINTS:
        if loc == drop:
            rows.append({"loc": loc, "bel": "A6LUT", "frames": "", "bit_count": "0",
                         "error": "LOC not honored"})
            continue
        frame = BASES[region] + DX[x]
        frames = [frame, frame + 1]
        bits = {str(f): [[20, 15]] + [[50, i] for i in range(1, 10)] for f in frames}
        rows.append({"loc": loc, "bel": "A6LUT",
                     "frames": ";".join(map(str, frames)),
                     "bit_count": str(sum(len(v) for v in bits.values())), "error": ""})
        points.append({"loc": loc, "bel": "A6LUT", "diff_frames": frames,
                       "bits": bits, "dcp": str(root / "probe" / loc / "routed.dcp")})

    with (root / "results.csv").open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=["loc", "bel", "frames", "bit_count", "error"])
        writer.writeheader()
        writer.writerows(rows)
    (root / "results.json").write_text(json.dumps(points, indent=2), encoding="utf-8")

    fit = {
        "part": "xc7vx485tffg1761-2",
        "frames_total": 50176,
        "regions": {str(r): {"base": b, "loc": f"SLICE_X10Y{50 * r}"} for r, b in BASES.items()},
        "dX_at_Y160": {str(x): v for x, v in DX.items()},
        "residuals": {p[0]: 0 for p in POINTS},
        "max_abs_residual": 0,
        "pass": True,
        "anomalies": [],
    }
    (root / "FIT.json").write_text(json.dumps(fit, indent=2), encoding="utf-8")

    report = "# R2 report\n\n" + "\n".join(f"- {p[0]} ok" for p in POINTS)
    (root / "REPORT.md").write_text(report + "\n" + "x" * 420, encoding="utf-8")
    (root / "DONE.json").write_text(
        json.dumps({"status": "ok", "points_ok": len(points), "points_failed": 0}),
        encoding="utf-8",
    )
    (root / "run.env").write_text(
        f"runid=selftest\nstarted_epoch={int(time.time())}\n", encoding="utf-8"
    )
    (root / "PLAN.md").write_text("selftest\n", encoding="utf-8")


def main() -> int:
    here = Path(__file__).resolve().parent
    good = here / "run_good"
    bad = here / "run_bad"
    build(good)
    build(bad, drop=None)
    # corrupt one measured frame in the bad fixture: residual becomes 5
    rows = list(csv.DictReader((bad / "results.csv").open(encoding="utf-8")))
    for row in rows:
        if row["loc"] == "SLICE_X60Y160":
            f = int(row["frames"].split(";")[0]) + 5
            row["frames"] = f"{f};{f + 1}"
    with (bad / "results.csv").open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=["loc", "bel", "frames", "bit_count", "error"])
        writer.writeheader()
        writer.writerows(rows)
    print(f"good: {good}")
    print(f"bad : {bad}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
