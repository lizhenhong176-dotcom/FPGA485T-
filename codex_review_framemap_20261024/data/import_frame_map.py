#!/usr/bin/env python3
"""Import frame_map from the validated Phase A CSV and run full audits.

Input:  phaseA/frame_index_far.csv (50,176 rows: frame_index,far,row,block_addr,kind)
        a bitstream file for frame-hash anchor verification
Output: frame_map table in the model DB, populated and audited
"""

from __future__ import annotations

import csv
import hashlib
import sqlite3
import struct
import sys
from pathlib import Path

# --- paths (adjust via CLI args) ---
BASE = Path(__file__).resolve().parent.parent
CSV_PATH = BASE.parent / "phaseA" / "frame_index_far.csv"
BIT_PATH = Path(r"E:\v7work\_curated_20261021\probe\SLICE_X10Y10\A6LUT\a.bit")
DB_PATH = Path(r"E:\v7work\model\v7_model.sqlite")

EXPECTED_TOTAL = 50176
EXPECTED_BLOCK = 50148
EXPECTED_OVERHEAD = 28

# Known-good SHA-256 anchors (from PHASE_A_STATUS.md, independently verified
# by both Python bitstream parser and RapidWright Bitstream.readBitstream).
ANCHOR_EXPECTED = {
    31748: ("0x004203A0", "0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9"),
    31750: ("0x004203A2", "d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e"),
}

FRAME_WORDS = 101  # 7-series frame size


def frame_sha256(frame: list[int]) -> str:
    """SHA-256 of a single 101-word frame (big-endian, raw 404 bytes)."""
    h = hashlib.sha256()
    for w in frame:
        h.update(struct.pack(">I", w))
    return h.hexdigest()


def load_frames_from_bit(path: Path) -> list[list[int]]:
    """Minimal bitstream frame extractor (same logic as bitstream/frames.py)."""
    sys.path.insert(0, str(BASE))
    from bitstream.frames import load_frames
    return load_frames(path)


def parse_far_hex(s: str) -> int | None:
    if not s or s.strip() == "":
        return None
    return int(s, 16)


def block_type_from_far(far: int) -> str:
    """Extract FAR block-type field [25:23] and return a descriptive string."""
    bt = (far >> 23) & 0x7
    return f"FAR_BLOCK_{bt}"


def main() -> int:
    csv_path = Path(sys.argv[1]) if len(sys.argv) > 1 else CSV_PATH
    bit_path = Path(sys.argv[2]) if len(sys.argv) > 2 else BIT_PATH
    db_path = Path(sys.argv[3]) if len(sys.argv) > 3 else DB_PATH

    failures: list[str] = []
    print(f"CSV:    {csv_path}")
    print(f"BIT:    {bit_path}")
    print(f"DB:     {db_path}")

    # -- 1. parse CSV ------------------------------------------------------
    rows: list[dict] = []
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for r in reader:
            rows.append(r)

    total = len(rows)
    block_rows = [r for r in rows if r["kind"] == "block"]
    overhead_rows = [r for r in rows if r["kind"] == "overhead"]

    print(f"\n[1] CSV parsed: {total} rows, {len(block_rows)} block, {len(overhead_rows)} overhead")

    if total != EXPECTED_TOTAL:
        failures.append(f"total rows {total} != {EXPECTED_TOTAL}")
    if len(block_rows) != EXPECTED_BLOCK:
        failures.append(f"block rows {len(block_rows)} != {EXPECTED_BLOCK}")
    if len(overhead_rows) != EXPECTED_OVERHEAD:
        failures.append(f"overhead rows {len(overhead_rows)} != {EXPECTED_OVERHEAD}")

    # frame_index must be 0..50175, unique, continuous
    indices = sorted(int(r["frame_index"]) for r in rows)
    if indices != list(range(EXPECTED_TOTAL)):
        failures.append("frame_index is not 0..50175 unique continuous")

    # -- 2. build table rows -----------------------------------------------
    table_rows: list[tuple] = []
    for r in rows:
        fi = int(r["frame_index"])
        kind = r["kind"]
        if kind == "block":
            far = parse_far_hex(r["far"])
            if far is None:
                failures.append(f"block row {fi} has empty far")
                far = 0
            bt = block_type_from_far(far)
            table_rows.append((fi, far, "rapidwright-configarray", "confirmed", None, bt, 0))
        else:
            # overhead: far = NULL, per schema decision
            table_rows.append((fi, None, "unresolved", "unresolved", None, None, 1))

    # -- 3. create table in DB ---------------------------------------------
    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode = WAL")
    conn.execute("""
        CREATE TABLE IF NOT EXISTS frame_map (
            frame_index           INTEGER PRIMARY KEY,
            far                   INTEGER NULL,
            frame_address_source  TEXT NOT NULL,
            confidence            TEXT NOT NULL,
            tile_name             TEXT NULL,
            block_type            TEXT NULL,
            is_overhead           INTEGER NOT NULL DEFAULT 0
        )
    """)
    conn.execute("DROP INDEX IF EXISTS idx_frame_map_far")
    conn.execute("DROP INDEX IF EXISTS idx_frame_map_overhead")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_frame_map_far ON frame_map(far)")
    conn.execute("CREATE INDEX IF NOT EXISTS idx_frame_map_overhead ON frame_map(is_overhead)")
    conn.execute("DELETE FROM frame_map")
    conn.executemany(
        "INSERT INTO frame_map (frame_index, far, frame_address_source, confidence, tile_name, block_type, is_overhead) VALUES (?,?,?,?,?,?,?)",
        table_rows,
    )
    conn.commit()
    print(f"\n[2] Inserted {len(table_rows)} rows into frame_map in {db_path}")

    # -- 4. audit checks ----------------------------------------------------
    print("\n[3] Audit checks:")

    # 4.1 total row count
    n = conn.execute("SELECT COUNT(*) FROM frame_map").fetchone()[0]
    ok = n == EXPECTED_TOTAL
    print(f"  4.1 total rows = {n} (expect {EXPECTED_TOTAL})  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"DB total rows {n} != {EXPECTED_TOTAL}")

    # 4.2 frame_index range
    lo, hi = conn.execute("SELECT MIN(frame_index), MAX(frame_index) FROM frame_map").fetchone()
    ok = lo == 0 and hi == 50175
    print(f"  4.2 frame_index range = [{lo},{hi}]  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"frame_index range [{lo},{hi}] != [0,50175]")

    # 4.3 block frames: far IS NOT NULL
    n_null_block = conn.execute(
        "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0 AND far IS NULL"
    ).fetchone()[0]
    ok = n_null_block == 0
    print(f"  4.3 block frames with far IS NULL = {n_null_block} (expect 0)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"{n_null_block} block frames have NULL far")

    # 4.4 overhead frames: far IS NULL
    n_null_oh = conn.execute(
        "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1 AND far IS NOT NULL"
    ).fetchone()[0]
    ok = n_null_oh == 0
    print(f"  4.4 overhead frames with far NOT NULL = {n_null_oh} (expect 0)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"{n_null_oh} overhead frames have non-NULL far")

    # 4.5 no overhead row has tile_name or block_type
    n_oh_tile = conn.execute(
        "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1 AND (tile_name IS NOT NULL OR block_type IS NOT NULL)"
    ).fetchone()[0]
    ok = n_oh_tile == 0
    print(f"  4.5 overhead rows with tile/block_type = {n_oh_tile} (expect 0)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"{n_oh_tile} overhead rows have tile_name or block_type")

    # 4.6 source and confidence values
    n_bad_source = conn.execute(
        "SELECT COUNT(*) FROM frame_map WHERE (is_overhead=0 AND frame_address_source != 'rapidwright-configarray') OR (is_overhead=1 AND frame_address_source != 'unresolved')"
    ).fetchone()[0]
    ok = n_bad_source == 0
    print(f"  4.6 bad frame_address_source = {n_bad_source} (expect 0)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"{n_bad_source} rows have wrong frame_address_source")

    n_bad_conf = conn.execute(
        "SELECT COUNT(*) FROM frame_map WHERE (is_overhead=0 AND confidence != 'confirmed') OR (is_overhead=1 AND confidence != 'unresolved')"
    ).fetchone()[0]
    ok = n_bad_conf == 0
    print(f"  4.7 bad confidence = {n_bad_conf} (expect 0)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"{n_bad_conf} rows have wrong confidence")

    # 4.8 overhead count
    n_oh = conn.execute("SELECT COUNT(*) FROM frame_map WHERE is_overhead=1").fetchone()[0]
    ok = n_oh == 28
    print(f"  4.8 overhead count = {n_oh} (expect 28)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"overhead count {n_oh} != 28")

    # 4.9 block count
    n_blk = conn.execute("SELECT COUNT(*) FROM frame_map WHERE is_overhead=0").fetchone()[0]
    ok = n_blk == 50148
    print(f"  4.9 block count = {n_blk} (expect 50148)  {'PASS' if ok else 'FAIL'}")
    if not ok:
        failures.append(f"block count {n_blk} != 50148")

    # 4.10 FAR anchor check: frame 31748 -> 0x4203A0, frame 31750 -> 0x4203A2
    for fi, (exp_far, _) in ANCHOR_EXPECTED.items():
        actual = conn.execute(
            "SELECT far FROM frame_map WHERE frame_index=?", (fi,)
        ).fetchone()
        if actual is None or actual[0] is None:
            failures.append(f"frame {fi}: no far in DB")
            print(f"  4.10 frame {fi}: no far in DB  FAIL")
        else:
            actual_hex = f"0x{actual[0]:08X}"
            ok = actual_hex.upper() == exp_far.upper()
            print(f"  4.10 frame {fi}: far={actual_hex} (expect {exp_far})  {'PASS' if ok else 'FAIL'}")
            if not ok:
                failures.append(f"frame {fi}: far {actual_hex} != {exp_far}")

    conn.close()

    # -- 5. bitstream frame-hash anchor verification ------------------------
    print(f"\n[4] Bitstream frame-hash anchors (from {bit_path}):")
    try:
        frames = load_frames_from_bit(bit_path)
        if len(frames) != EXPECTED_TOTAL:
            print(f"  WARNING: bitstream has {len(frames)} frames (expected {EXPECTED_TOTAL})")
        for fi, (exp_far, exp_hash) in ANCHOR_EXPECTED.items():
            if fi >= len(frames):
                failures.append(f"frame {fi} out of bitstream range")
                print(f"  frame {fi}: out of range  FAIL")
                continue
            actual_hash = frame_sha256(frames[fi])
            ok = actual_hash == exp_hash
            print(f"  frame {fi}: sha256={actual_hash[:16]}...  {'PASS' if ok else 'FAIL'}")
            print(f"    expect:      {exp_hash[:16]}...")
            if not ok:
                failures.append(f"frame {fi} hash mismatch: {actual_hash} != {exp_hash}")
    except Exception as e:
        print(f"  ERROR: {e}")
        failures.append(f"bitstream hash verification failed: {e}")

    # -- verdict ------------------------------------------------------------
    print(f"\n{'='*60}")
    if failures:
        print(f"FRAME_MAP AUDIT: FAIL ({len(failures)} failures)")
        for f in failures:
            print(f"  - {f}")
        return 1
    print("FRAME_MAP AUDIT: PASS (all checks green)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
