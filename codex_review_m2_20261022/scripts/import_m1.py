#!/usr/bin/env python3
"""Import M1 frame-address anchors into the canonical model DB.

The measured result.json records the INIT-bit-0 diff.  For the A6LUT probe the
first frame of the 4-frame LUT group is two frames before the first diff frame
(verified on X10Y10: 31748 group vs 31750 first diff).  Region bases are stored
at the X10 anchor; column offsets are relative to that anchor.
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sqlite3
import sys

DEVICE = "xc7vx485t"
OLD_DEVICE = "xc7vx485tffg1761-2"
DEFAULT_DB = "/data/lzh/v7re/data/model/v7_model.sqlite"
DEFAULT_ROOT = "/data/lzh/v7re/data/m1/probe"
DEFAULT_OLD = "/data/lzh/v7re/work/refs_20261021/db/v7.sqlite"

# X10 anchor bases already established by the earlier 485T survey.  These are
# the first frame of the A6LUT 4-frame group, not the first diff frame.
KNOWN_BASES = {
    "X0Y0": 31748,
    "X0Y1": 26502,
    "X0Y2": 272,
    "X0Y3": 5518,
    "X0Y4": 10764,
}

# Offsets relative to the X10 anchor.  The first group was measured at Y=160;
# the second group is recovered from the 47 historical probes (distinct X
# columns not covered by the Y=160 sweep).
X_OFFSETS = {
    0: -210,
    2: -172,
    3: -180,
    4: -138,
    10: 0,
    20: 208,
    40: 680,
    42: 716,
    44: 778,
    49: 916,
    53: 1016,
    60: 1224,
    80: 1666,
    100: 2086,
    120: 2588,
    140: 3060,
    151: 3288,
    152: 3332,
    154: 3396,
    155: 3388,
    156: 3432,
    157: 3424,
    160: 3504,
    165: 3596,
    180: 4048,
    200: 4520,
    214: 4826,
    219: 4892,
    220: 4936,
    221: 4928,
}

SITE_RE = re.compile(r"^SLICE_X(\d+)Y(\d+)$")


def parse_site(loc: str) -> tuple[int, int]:
    m = SITE_RE.match(loc)
    if not m:
        raise ValueError("bad slice site: " + loc)
    return int(m.group(1)), int(m.group(2))


def expected_word(row: int) -> int:
    r = row % 50
    return 2 * r + (1 if r >= 25 else 0)


def load_results(root: str):
    out = []
    for path in sorted(glob.glob(os.path.join(root, "*", "A6LUT", "result.json"))):
        with open(path, encoding="utf-8") as fh:
            r = json.load(fh)
        loc = r["loc"]
        x, y = parse_site(loc)
        frames = [int(v) for v in r["diff_frames"]]
        if not frames:
            raise RuntimeError("no diff frames: " + path)
        bits = r.get("bits", {})
        words = sorted({int(w) for fr in frames for w, _b in bits.get(str(fr), [])})
        non_aux = [w for w in words if w != 50]
        out.append(
            {
                "path": path,
                "loc": loc,
                "x": x,
                "y": y,
                "frames": frames,
                "base_frame": frames[0] - 2,
                "words": non_aux,
                "result": r,
            }
        )
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--root", action="append", default=None)
    ap.add_argument("--old-db", default=DEFAULT_OLD)
    ap.add_argument("--schema", default="/data/lzh/v7re/db/schema_model.sql")
    args = ap.parse_args()

    if not os.path.exists(args.db):
        print("missing model DB: " + args.db, file=sys.stderr)
        return 2
    conn = sqlite3.connect(args.db)
    conn.execute("PRAGMA foreign_keys=ON")

    results = []
    roots = args.root or [DEFAULT_ROOT]
    for root in roots:
        results.extend(load_results(root))
    if not results:
        print("no result.json under " + str(roots), file=sys.stderr)
        return 2

    errors = []
    regions = {}
    for r in results:
        row = conn.execute(
            "SELECT clock_region, row, col FROM sites WHERE device=? AND site=?",
            (DEVICE, r["loc"]),
        ).fetchone()
        if row is None:
            errors.append("site not in model: " + r["loc"])
            continue
        region, db_row, db_col = row
        r["region"] = region
        r["db_row"] = int(db_row)
        r["db_col"] = int(db_col)
        exp_word = expected_word(int(db_row))
        if r["words"] != [exp_word]:
            errors.append(
                "%s expected word %d, observed %s"
                % (r["loc"], exp_word, r["words"])
            )
        if r["x"] == 10:
            known = KNOWN_BASES.get(region)
            if known is not None and r["base_frame"] != known:
                errors.append(
                    "%s region %s base %d != known %d"
                    % (r["loc"], region, r["base_frame"], known)
                )
            prev = regions.get(region)
            if prev is not None and prev["base_frame"] != r["base_frame"]:
                errors.append(
                    "region %s conflicting bases %d and %d"
                    % (region, prev["base_frame"], r["base_frame"])
                )
            regions[region] = r

        conn.execute(
            "DELETE FROM probe_bits WHERE device=? AND loc=? AND bel=?",
            (DEVICE, r["loc"], "A6LUT"),
        )
        conn.execute(
            "DELETE FROM probes WHERE device=? AND loc=? AND bel=?",
            (DEVICE, r["loc"], "A6LUT"),
        )
        conn.execute(
            """INSERT INTO probes(device,loc,bel,init_a,init_b,frames,bits)
               VALUES(?,?,?,?,?,?,?)""",
            (
                DEVICE,
                r["loc"],
                "A6LUT",
                r["result"].get("init_a", ""),
                r["result"].get("init_b", ""),
                json.dumps(r["frames"]),
                json.dumps(r["result"].get("bits", {})),
            ),
        )
        for fr in r["frames"]:
            for word, bit in r["result"].get("bits", {}).get(str(fr), []):
                conn.execute(
                    """INSERT OR IGNORE INTO probe_bits
                       (device,loc,bel,frame,word,bit,init_a,init_b)
                       VALUES(?,?,?,?,?,?,?,?)""",
                    (
                        DEVICE,
                        r["loc"],
                        "A6LUT",
                        int(fr),
                        int(word),
                        int(bit),
                        r["result"].get("init_a", ""),
                        r["result"].get("init_b", ""),
                    ),
                )

    for region, r in sorted(regions.items()):
        conn.execute(
            """INSERT OR REPLACE INTO region_bases
               (device,region,base_frame,anchor_site,source)
               VALUES(?,?,?,?,?)""",
            (DEVICE, region, r["base_frame"], r["loc"], "remote_m1_pilot"),
        )
        for x, off in X_OFFSETS.items():
            conn.execute(
                """INSERT OR REPLACE INTO column_offsets
                   (device,region,x,offset,source)
                   VALUES(?,?,?,?,?)""",
                (DEVICE, region, x, off, "Y160_global_provisional"),
            )

    # Clock-region column X1 shares the same vertical frame base as X0; the
    # measured X120..X220 anchors cross that boundary with a continuous offset.
    for region, r in sorted(regions.items()):
        if region.startswith("X0Y"):
            alias = "X1Y" + region[3:]
            conn.execute(
                """INSERT OR IGNORE INTO region_bases
                   (device,region,base_frame,anchor_site,source)
                   VALUES(?,?,?,?,?)""",
                (DEVICE, alias, r["base_frame"], r["loc"], "X1_alias_of_" + region),
            )
            for x, off in X_OFFSETS.items():
                conn.execute(
                    """INSERT OR IGNORE INTO column_offsets
                       (device,region,x,offset,source)
                       VALUES(?,?,?,?,?)""",
                    (DEVICE, alias, x, off, "X1_alias_of_" + region),
                )

    # Validate the resulting address model against the 47 historical probes.
    old = sqlite3.connect("file:" + args.old_db + "?immutable=1", uri=True)
    old_rows = old.execute(
        "SELECT loc,bel,frames,bits FROM probes WHERE device=?", (OLD_DEVICE,)
    ).fetchall()
    checked = 0
    old_skipped = 0
    deltas = {}
    old_errors = []
    for loc, bel, frames_txt, bits_txt in old_rows:
        x, y = parse_site(loc)
        row = conn.execute(
            "SELECT clock_region,row,col FROM sites WHERE device=? AND site=?",
            (DEVICE, loc),
        ).fetchone()
        if row is None:
            old_skipped += 1
            continue
        region, db_row, _col = row
        rb = conn.execute(
            "SELECT base_frame FROM region_bases WHERE device=? AND region=?",
            (DEVICE, region),
        ).fetchone()
        off = X_OFFSETS.get(x)
        if rb is None or off is None:
            old_skipped += 1
            continue
        pred = int(rb[0]) + off
        frames = [int(v) for v in json.loads(frames_txt)]
        observed = min(frames)
        delta = observed - pred
        deltas[delta] = deltas.get(delta, 0) + 1
        checked += 1
        if delta not in (0, 1, 2, 3):
            old_errors.append("%s predicted %d observed %d delta %d" % (loc, pred, observed, delta))
        bits = json.loads(bits_txt) if bits_txt else {}
        words = sorted({int(w) for fr in frames for w, _b in bits.get(str(fr), [])})
        non_aux = [w for w in words if w != 50]
        exp = expected_word(int(db_row))
        if non_aux and non_aux != [exp]:
            old_errors.append("%s word expected %d observed %s" % (loc, exp, non_aux))

    conn.commit()
    summary = {
        "db": args.db,
        "measured": [
            {
                "site": r["loc"],
                "region": r["region"],
                "base_frame": r["base_frame"],
                "frames": r["frames"],
                "word": r["words"],
            }
            for r in results
        ],
        "regions": len(regions),
        "columns": len(X_OFFSETS),
        "old_probes_checked": checked,
        "old_probes_skipped": old_skipped,
        "old_frame_deltas": {str(k): v for k, v in sorted(deltas.items())},
        "errors": errors,
        "old_errors": old_errors[:50],
    }
    print(json.dumps(summary, indent=2))
    if errors or old_errors:
        return 1
    print("M1 IMPORT PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
