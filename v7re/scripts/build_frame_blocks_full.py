"""Build a complete configuration-block table for the whole device.

`far_bands` only covers `FAR_BLOCK_0` (1,078 blocks / 36,708 frames).  The other
13,440 frames belong to `FAR_BLOCK_1` and had no block table at all, so every
"device layout" figure silently covered 73.2% of the part.

This script derives the full table from `frame_map` (which carries a real FAR
per frame) by decoding the FAR fields and grouping consecutive frames into
blocks:

    block_key = (block_type, top_bottom, row, column)
    frames    = [min, max] of frame_index for that key

Classification by frames-per-block, calibrated in T3/T55/§172:

    36  CLB        (777 blocks, 111 columns)
    28  INT        (245 blocks, 35 columns)
    30  CLOCK      (28 blocks, 4 columns: 33/62/75/120)
    32  BOUNDARY   (14 blocks, 2 columns: 0/153)
    42  UNDETERMINED (14 blocks, 2 columns: 32/121)
    128 BT1        (105 blocks, 15 columns) -- all-zero in every sampled design

It also resolves the `far_bands.band` <-> `(top_bottom, row)` correspondence,
which `far_bands` itself does not state.

Usage:
    python v7re/scripts/build_frame_blocks_full.py --check
    python v7re/scripts/build_frame_blocks_full.py --apply
"""

from __future__ import annotations

import argparse
import collections
import json
import os
import sqlite3
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from bitstream.far import FarAddress  # noqa: E402

LAW_DB = r"E:\v7work\model\v7_law.sqlite"
MODEL_DB = r"E:\v7work\model\v7_model.sqlite"
OUT_JSON = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "steps",
    "frame_blocks_full.json",
)

# frames-per-block -> class name.  Calibrated per §172 (far_bands signatures).
CLASS_BY_SIZE = {
    36: "CLB",
    28: "INT",
    30: "CLOCK",
    32: "BOUNDARY",
    42: "UNDETERMINED",
    128: "BT1",
}

CLASS_NOTE = {
    "CLB": "CLB column block (111 of the 154 FAR columns)",
    "INT": "INT column block (35 columns); BRAM/DSP tiles share these blocks",
    "CLOCK": "clock column block: FAR columns 33/62/75/120",
    "BOUNDARY": "edge column block: FAR columns 0/153",
    "UNDETERMINED": "unclassified 42-frame column block: FAR columns 32/121",
    "BT1": "FAR_BLOCK_1: 105 blocks, 15 columns, all-zero in 36 sampled designs",
}

DDL = """
CREATE TABLE IF NOT EXISTS frame_blocks_full (
    block_id      INTEGER PRIMARY KEY,
    block_type    INTEGER NOT NULL,
    top_bottom    INTEGER NOT NULL,
    row_addr      INTEGER NOT NULL,          -- FAR row field (0..4 here)
    col_addr      INTEGER NOT NULL,          -- FAR column field
    start_frame   INTEGER NOT NULL UNIQUE,
    end_frame     INTEGER NOT NULL,
    n_frames      INTEGER NOT NULL,
    class         TEXT    NOT NULL,
    far_band      INTEGER,                   -- far_bands.band (FAR_BLOCK_0 only)
    clb_col       INTEGER,                   -- clb_blocks.grid_col (CLB blocks only)
    nonzero_designs INTEGER NOT NULL DEFAULT 0,  -- sampled designs with data
    note          TEXT
)
"""


def load_blocks(model_db: str) -> list[dict]:
    con = sqlite3.connect(model_db)
    rows = con.execute(
        "select frame_index, far from frame_map where far is not null order by frame_index"
    ).fetchall()
    con.close()

    groups: collections.OrderedDict[tuple[int, int, int, int], list[int]] = (
        collections.OrderedDict()
    )
    for fi, far in rows:
        a = FarAddress.decode(far)
        key = (a.block_type, a.top_bottom, a.row, a.column)
        groups.setdefault(key, []).append(fi)

    blocks = []
    for (bt, tb, row, col), frames in groups.items():
        blocks.append(
            {
                "block_type": bt,
                "top_bottom": tb,
                "row_addr": row,
                "col_addr": col,
                "start_frame": min(frames),
                "end_frame": max(frames),
                "n_frames": len(frames),
            }
        )
    blocks.sort(key=lambda b: b["start_frame"])
    return blocks


def attach_classes(blocks: list[dict]) -> None:
    for b in blocks:
        cls = CLASS_BY_SIZE.get(b["n_frames"])
        if cls is None:
            raise SystemExit(f"unclassified block size {b['n_frames']} at {b['start_frame']}")
        b["class"] = cls
        b["note"] = CLASS_NOTE[cls]
        # FAR_BLOCK_1 is the second FAR block type; never mix it with band maths.
        if b["block_type"] == 1 and cls != "BT1":
            raise SystemExit(f"FAR_BLOCK_1 block with size {b['n_frames']}")


def attach_far_bands(blocks: list[dict], law_db: str) -> dict:
    """Join FAR_BLOCK_0 blocks to far_bands by start_frame; derive band->(top,row)."""
    con = sqlite3.connect(law_db)
    bands = con.execute("select band, col, start_frame from far_bands").fetchall()
    con.close()
    by_start = {s: (band, col) for band, col, s in bands}

    band_to_toprow: dict[int, set] = collections.defaultdict(set)
    matched = 0
    for b in blocks:
        hit = by_start.get(b["start_frame"])
        if hit is None:
            if b["block_type"] == 0:
                raise SystemExit(f"FAR_BLOCK_0 block {b['start_frame']} missing from far_bands")
            continue
        band, col = hit
        b["far_band"] = band
        if b["col_addr"] != col:
            raise SystemExit(
                f"column mismatch at frame {b['start_frame']}: FAR {b['col_addr']} vs far_bands {col}"
            )
        band_to_toprow[band].add((b["top_bottom"], b["row_addr"]))
        matched += 1

    for band, pairs in band_to_toprow.items():
        if len(pairs) != 1:
            raise SystemExit(f"band {band} maps to several (top,row): {pairs}")
    return {band: sorted(pairs)[0] for band, pairs in sorted(band_to_toprow.items())}


def attach_clb_cols(blocks: list[dict], law_db: str) -> int:
    con = sqlite3.connect(law_db)
    rows = con.execute("select grid_col, base_frame from clb_blocks").fetchall()
    con.close()
    by_start = {fi: gc for gc, fi in rows}
    hit = 0
    for b in blocks:
        gc = by_start.get(b["start_frame"])
        if gc is not None:
            b["clb_col"] = gc
            hit += 1
    return hit


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write table + json")
    ap.add_argument("--check", action="store_true", help="dry-run only (default)")
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--model-db", default=MODEL_DB)
    ap.add_argument("--json", default=OUT_JSON)
    args = ap.parse_args()

    blocks = load_blocks(args.model_db)
    attach_classes(blocks)
    band_map = attach_far_bands(blocks, args.law_db)
    clb_hits = attach_clb_cols(blocks, args.law_db)

    # ---- self checks -------------------------------------------------------
    total_frames = sum(b["n_frames"] for b in blocks)
    t0 = [b for b in blocks if b["block_type"] == 0]
    t1 = [b for b in blocks if b["block_type"] == 1]
    by_class = collections.Counter(b["class"] for b in blocks)
    cols_by_class = collections.defaultdict(set)
    for b in blocks:
        cols_by_class[b["class"]].add((b["block_type"], b["col_addr"]))

    problems = []
    if total_frames != 50148:
        problems.append(f"frame total {total_frames} != 50148")
    if len(t0) != 1078:
        problems.append(f"FAR_BLOCK_0 blocks {len(t0)} != 1078")
    if len(t1) != 105:
        problems.append(f"FAR_BLOCK_1 blocks {len(t1)} != 105")
    if sum(b["n_frames"] for b in t1) != 13440:
        problems.append("FAR_BLOCK_1 frames != 13440")
    # contiguity: every block must be a run of consecutive frames, and blocks
    # must tile 0..50147 with no overlap
    for b in blocks:
        if b["end_frame"] - b["start_frame"] + 1 != b["n_frames"]:
            problems.append(f"non-contiguous block at {b['start_frame']}")
    # overhead frames (the 28 frames with far=NULL) legitimately sit between
    # blocks, so the contiguity test is "covered + overhead == 0..50175".
    con = sqlite3.connect(args.model_db)
    overhead = {r[0] for r in con.execute("select frame_index from frame_map where is_overhead=1")}
    con.close()
    covered = set()
    for b in blocks:
        covered.update(range(b["start_frame"], b["end_frame"] + 1))
    missing = (set(range(0, 50176)) - overhead) - covered
    extra = covered & overhead
    if missing:
        problems.append(f"{len(missing)} frames not in any block, first {min(missing)}")
    if extra:
        problems.append(f"{len(extra)} overhead frames claimed by a block")
    if by_class.get("CLB") != 777:
        problems.append(f"CLB blocks {by_class.get('CLB')} != 777")
    if len({c for _, c in cols_by_class["CLB"]}) != 111:
        problems.append("CLB column count != 111")
    if len({c for _, c in cols_by_class["BT1"]}) != 15:
        problems.append("BT1 column count != 15")

    print(f"blocks                {len(blocks)}  (type0 {len(t0)} / type1 {len(t1)})")
    print(f"frames                {total_frames}  (type0 {sum(b['n_frames'] for b in t0)}"
          f" / type1 {sum(b['n_frames'] for b in t1)})")
    print("by class              " + ", ".join(f"{k}={v}" for k, v in sorted(by_class.items())))
    print("columns per class     " + ", ".join(
        f"{k}={len({c for _, c in v})}" for k, v in sorted(cols_by_class.items())))
    print("band -> (top,row)     " + ", ".join(f"{k}->{v}" for k, v in band_map.items()))
    print(f"clb_col attached      {clb_hits}/777")
    print("problems              " + ("none" if not problems else "; ".join(problems)))

    if problems:
        print("FAIL")
        return 1

    if args.apply:
        con = sqlite3.connect(args.law_db)
        con.execute("DROP TABLE IF EXISTS frame_blocks_full")
        con.execute(DDL)
        con.executemany(
            "insert into frame_blocks_full (block_type, top_bottom, row_addr, col_addr,"
            " start_frame, end_frame, n_frames, class, far_band, clb_col, nonzero_designs, note)"
            " values (?,?,?,?,?,?,?,?,?,?,?,?)",
            [
                (
                    b["block_type"],
                    b["top_bottom"],
                    b["row_addr"],
                    b["col_addr"],
                    b["start_frame"],
                    b["end_frame"],
                    b["n_frames"],
                    b["class"],
                    b.get("far_band"),
                    b.get("clb_col"),
                    0,
                    b["note"],
                )
                for b in blocks
            ],
        )
        con.commit()
        con.close()
        payload = {
            "blocks": blocks,
            "band_to_top_row": {str(k): list(v) for k, v in band_map.items()},
            "summary": {
                "blocks": len(blocks),
                "frames": total_frames,
                "by_class": dict(sorted(by_class.items())),
                "columns_by_class": {
                    k: len({c for _, c in v}) for k, v in sorted(cols_by_class.items())
                },
            },
        }
        os.makedirs(os.path.dirname(args.json), exist_ok=True)
        with open(args.json, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=1)
        print(f"written               {args.law_db} (frame_blocks_full) + {args.json}")
    else:
        print("dry-run (use --apply to write)")
    print("PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
