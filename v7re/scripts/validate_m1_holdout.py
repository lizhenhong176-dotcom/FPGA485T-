#!/usr/bin/env python3
"""Validate blind M1 holdout probes against the measured address model."""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sqlite3
import sys

DEVICE = "xc7vx485t"
SITE_RE = re.compile(r"^SLICE_X(\d+)Y(\d+)$")


def expected_word(row: int) -> int:
    r = row % 50
    return 2 * r + (1 if r >= 25 else 0)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default="/data/lzh/v7re/data/model/v7_model.sqlite")
    ap.add_argument("--root", default="/data/lzh/v7re/data/m1/holdout")
    ap.add_argument("--out", default="/data/lzh/v7re/data/m1/holdout_validation.json")
    args = ap.parse_args()

    conn = sqlite3.connect("file:" + args.db + "?immutable=1", uri=True)
    rows = []
    for path in sorted(glob.glob(os.path.join(args.root, "*", "*", "A6LUT", "result.json"))):
        with open(path, encoding="utf-8") as fh:
            result = json.load(fh)
        loc = result["loc"]
        m = SITE_RE.match(loc)
        if not m:
            rows.append({"site": loc, "path": path, "error": "bad site"})
            continue
        x, y = int(m.group(1)), int(m.group(2))
        site = conn.execute(
            "SELECT clock_region,row,col FROM sites WHERE device=? AND site=?",
            (DEVICE, loc),
        ).fetchone()
        if site is None:
            rows.append({"site": loc, "path": path, "error": "not in model"})
            continue
        region, db_row, _col = site
        base = conn.execute(
            "SELECT base_frame FROM region_bases WHERE device=? AND region=?",
            (DEVICE, region),
        ).fetchone()
        off = conn.execute(
            "SELECT offset FROM column_offsets WHERE device=? AND region=? AND x=?",
            (DEVICE, region, x),
        ).fetchone()
        if base is None or off is None:
            rows.append({"site": loc, "path": path, "error": "no base/offset"})
            continue
        frames = [int(v) for v in result["diff_frames"]]
        observed = min(frames)
        pred = int(base[0]) + int(off[0])
        delta = observed - pred
        bits = result.get("bits", {})
        words = sorted({int(w) for fr in frames for w, _b in bits.get(str(fr), [])})
        non_aux = [w for w in words if w != 50]
        exp = expected_word(int(db_row))
        rows.append(
            {
                "site": loc,
                "region": region,
                "x": x,
                "y": y,
                "pred_base": pred,
                "observed_min": observed,
                "delta": delta,
                "word_expected": exp,
                "word_observed": non_aux,
                "path": path,
            }
        )

    errors = [
        r
        for r in rows
        if "error" in r
        or r.get("delta") not in (0, 2)
        or r.get("word_observed") != [r.get("word_expected")]
    ]
    summary = {
        "db": args.db,
        "root": args.root,
        "count": len(rows),
        "ok": len(rows) - len(errors),
        "errors": errors,
        "rows": rows,
    }
    with open(args.out, "w", encoding="utf-8") as fh:
        json.dump(summary, fh, indent=2)
    print(json.dumps({k: summary[k] for k in ("count", "ok")}, indent=2))
    print("out:", args.out)
    for r in errors:
        print("ERR", r)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
