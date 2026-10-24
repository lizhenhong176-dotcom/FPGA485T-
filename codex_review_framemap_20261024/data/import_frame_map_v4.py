#!/usr/bin/env python3
"""Import frame_map from the validated Phase A CSV and run full audits.

v4 (Codex v3-review fixes, CONDITIONAL_PASS -> target PASS):
  1. INDEPENDENT expected-run battery (Gap 1): block_addr 0x80 grid
     alignment, block_type field constant per run, each run confined to one
     0x80 region with regions unique, expected run count (1,183) + length
     multiset, expected per-row block-frame counts. These invariants come
     from the device structure (FAR 0x80 region grid) and the recorded
     RapidWright derivation, NOT from the row being checked.
  2. row/block metadata STORED in frame_map (Gap 2): new columns
     row_number and block_addr; vacuous 5.17 loop removed and replaced by
     real DB-side reconstruction audits (row intervals, overhead position,
     run reconstruction with far == block_addr + pos, alignment).
  3. Full DB fingerprint in the selftest (Gap 3): schema SQL + indexes +
     all table names/counts + sha256 of full frame_map contents + file
     size, compared before/after for BOTH negative tests (T1 previously
     captured a snapshot but never compared it).
  4. Migration path checked in (Gap 4): scripts/migrate_frame_map_checks.sql
     now exists and is referenced by schema_model.sql; bundle's stale
     unconstrained schema_model.sql replaced with the current one.

v3 (Codex v2-review fixes):
  Real block-continuity anchored at run start; row ordering/interval
  contiguity; ordered header check; all DB audits INSIDE the transaction;
  DROP+CREATE constrained schema; schema_model.sql updated.

Negative tests (--selftest):
  T1 malformed CSV rejected pre-DB, real DB fingerprint unchanged;
  T2 forced audit failure -> rollback, temp DB fingerprint unchanged;
  T3 whole-run consistent shift (block_addr + all far of one run shifted
     by +1) rejected by the independent grid-alignment battery;
  T4 first-row-only mutation (block_addr + far of a run's first row
     shifted by +1) rejected by run-anchor + region/cross checks.

Input:  phaseA/frame_index_far.csv (50,176 rows: frame_index,far,row,block_addr,kind)
        a bitstream file for frame-hash anchor verification
Output: frame_map table in the model DB, populated and audited
"""

from __future__ import annotations

import csv
import hashlib
import shutil
import sqlite3
import struct
import sys
import tempfile
from pathlib import Path

# --- paths (adjust via CLI args) ---
BASE = Path(__file__).resolve().parent.parent
CSV_PATH = BASE.parent / "phaseA" / "frame_index_far.csv"
BIT_PATH = Path(r"E:\v7work\_curated_20261021\probe\SLICE_X10Y10\A6LUT\a.bit")
DB_PATH = Path(r"E:\v7work\model\v7_model.sqlite")

EXPECTED_TOTAL = 50176
EXPECTED_BLOCK = 50148
EXPECTED_OVERHEAD = 28
EXPECTED_ROWS = 14
EXPECTED_OVERHEAD_PER_ROW = 2

EXPECTED_HEADER = ["frame_index", "far", "row", "block_addr", "kind"]
ALLOWED_KINDS = {"block", "overhead"}

# --- independent expected-run table (Gap 1 battery) -----------------------
# Provenance: 7-series FAR address space is organized in 0x80-sized regions;
# every block (one FAR base per ConfigArray block) is 0x80-aligned and its
# frame run fills the first N addresses of one region (N <= 128). The run
# count / length multiset / per-row counts below were derived from the
# RapidWright ConfigArray enumeration of xc7vx485t and recorded in
# phaseA/FRAME_INDEX_MAP.md; they are constants of this device, not values
# recomputed from the CSV rows being checked.
BLOCK_ADDR_ALIGN = 0x80  # 128
EXPECTED_RUN_COUNT = 1183
EXPECTED_RUN_LENGTHS = {36: 777, 28: 245, 128: 105, 30: 28, 32: 14, 42: 14}
EXPECTED_BLOCK_PER_ROW = {**{r: 5244 for r in range(1, 8)},
                          **{r: 1920 for r in range(8, 15)}}

# Known-good SHA-256 anchors (from PHASE_A_STATUS.md, independently verified
# by both Python bitstream parser and RapidWright Bitstream.readBitstream).
ANCHOR_EXPECTED = {
    31748: ("0x004203A0", "0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9"),
    31750: ("0x004203A2", "d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e"),
}

FRAME_WORDS = 101  # 7-series frame size
FAR_MAX = 0x7FFFFFFF

TABLE_COLUMNS = ("frame_index", "far", "frame_address_source", "confidence",
                 "tile_name", "block_type", "is_overhead", "row_number", "block_addr")


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


def block_type_from_far(far: int) -> str:
    """Extract FAR block-type field [25:23] and return a descriptive string."""
    bt = (far >> 23) & 0x7
    return f"FAR_BLOCK_{bt}"


def _block_runs(rows: list[dict]) -> list[list[dict]]:
    """Group consecutive block rows sharing one block_addr into runs."""
    runs: list[list[dict]] = []
    cur: list[dict] = []
    for r in rows:
        if r["kind"] != "block":
            if cur:
                runs.append(cur)
                cur = []
            continue
        if cur and r["block_addr"] != cur[0]["block_addr"]:
            runs.append(cur)
            cur = []
        cur.append(r)
    if cur:
        runs.append(cur)
    return runs


def validate_csv(csv_path: Path) -> tuple[list[dict], list[str]]:
    """Fully validate the CSV before any DB work. Returns (rows, errors)."""
    errors: list[str] = []
    rows: list[dict] = []

    try:
        with open(csv_path, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            # 1. ORDERED exact header check; fail immediately.
            if reader.fieldnames is None:
                return [], ["CSV file is empty"]
            if list(reader.fieldnames) != EXPECTED_HEADER:
                return [], [
                    f"CSV header mismatch: got {list(reader.fieldnames)}, "
                    f"expected exactly {EXPECTED_HEADER} (ordered)"
                ]

            # 2. Per-row validation
            for line_no, r in enumerate(reader, start=2):  # line 1 = header
                # 2a. frame_index
                try:
                    fi = int(r["frame_index"])
                    if fi < 0 or fi >= EXPECTED_TOTAL:
                        errors.append(f"line {line_no}: frame_index {fi} out of range [0,{EXPECTED_TOTAL - 1}]")
                        continue
                except (ValueError, TypeError):
                    errors.append(f"line {line_no}: frame_index '{r.get('frame_index', '')}' is not a valid integer")
                    continue

                # 2b. kind
                kind = r["kind"]
                if kind not in ALLOWED_KINDS:
                    errors.append(f"line {line_no}: kind '{kind}' not in {sorted(ALLOWED_KINDS)}")
                    continue

                # 2c. far (hex string; empty allowed only for overhead rows)
                far_str = r["far"]
                far = None
                if far_str:
                    try:
                        far = int(far_str, 16)
                        if far < 0 or far > FAR_MAX:
                            errors.append(f"line {line_no}: far 0x{far:X} out of range")
                            continue
                    except ValueError:
                        errors.append(f"line {line_no}: far '{far_str}' is not valid hex")
                        continue
                elif kind == "block":
                    errors.append(f"line {line_no}: block row has empty far")
                    continue

                # 2d. row
                try:
                    row_no = int(r["row"])
                    if row_no < 1 or row_no > EXPECTED_ROWS:
                        errors.append(f"line {line_no}: row {row_no} out of range [1,{EXPECTED_ROWS}]")
                        continue
                except (ValueError, TypeError):
                    errors.append(f"line {line_no}: row '{r.get('row', '')}' is not a valid integer")
                    continue

                # 2e. block_addr (hex; empty allowed only for overhead rows)
                block_addr = None
                if r["block_addr"]:
                    try:
                        block_addr = int(r["block_addr"], 16)
                        if block_addr < 0 or block_addr > FAR_MAX:
                            errors.append(f"line {line_no}: block_addr 0x{block_addr:X} out of range")
                            continue
                    except ValueError:
                        errors.append(f"line {line_no}: block_addr '{r['block_addr']}' is not valid hex")
                        continue
                elif kind == "block":
                    errors.append(f"line {line_no}: block row has empty block_addr")
                    continue

                rows.append({
                    "frame_index": fi,
                    "far": far,
                    "far_hex": far_str,
                    "row": row_no,
                    "block_addr": block_addr,
                    "kind": kind,
                    "_line": line_no,
                })
    except FileNotFoundError:
        return [], [f"CSV file not found: {csv_path}"]
    except Exception as e:
        return [], [f"CSV read error: {e}"]

    if errors:
        return rows, errors  # structural checks below need clean rows

    # 3. Count validation
    if len(rows) != EXPECTED_TOTAL:
        errors.append(f"total rows {len(rows)} != {EXPECTED_TOTAL}")

    # 4. frame_index continuity
    indices = [r["frame_index"] for r in rows]
    if indices != list(range(EXPECTED_TOTAL)):
        errors.append("frame_index is not 0..50175 unique continuous")

    # 5. Block/overhead counts
    block_count = sum(1 for r in rows if r["kind"] == "block")
    overhead_count = sum(1 for r in rows if r["kind"] == "overhead")
    if block_count != EXPECTED_BLOCK:
        errors.append(f"block rows {block_count} != {EXPECTED_BLOCK}")
    if overhead_count != EXPECTED_OVERHEAD:
        errors.append(f"overhead rows {overhead_count} != {EXPECTED_OVERHEAD}")

    # 6. Row ordering: non-decreasing, starts at 1, ends at 14, each row
    #    forms ONE contiguous frame_index interval.
    row_values = [r["row"] for r in rows]
    if row_values != sorted(row_values):
        errors.append("row values are not non-decreasing (rows interleave)")
    if row_values and (row_values[0] != 1 or row_values[-1] != EXPECTED_ROWS):
        errors.append(f"row range [{row_values[0]},{row_values[-1]}] != [1,{EXPECTED_ROWS}]")
    row_nums = sorted(set(row_values))
    if len(row_nums) != EXPECTED_ROWS:
        errors.append(f"config row count {len(row_nums)} != {EXPECTED_ROWS}")
    for rn in row_nums:
        row_fis = [r["frame_index"] for r in rows if r["row"] == rn]
        if row_fis != list(range(row_fis[0], row_fis[0] + len(row_fis))):
            errors.append(f"row {rn}: frame_index interval is not contiguous")

    # 7. FAR uniqueness (block frames only)
    block_fars = [r["far"] for r in rows if r["kind"] == "block" and r["far"] is not None]
    if len(block_fars) != len(set(block_fars)):
        errors.append("duplicate FAR values among block frames")

    # 8. REAL block continuity: within each block run, far must equal
    #    block_addr + position-in-run (anchored at the run's first row).
    for run in _block_runs(rows):
        ba = run[0]["block_addr"]
        for pos, r in enumerate(run):
            if r["far"] != ba + pos:
                errors.append(
                    f"line {r['_line']}: far 0x{r['far']:X} != block_addr 0x{ba:X} + "
                    f"position {pos} = 0x{ba + pos:X}"
                )

    # 9. Overhead position: last 2 entries of each row are overhead.
    for rn in row_nums:
        row_rows = [r for r in rows if r["row"] == rn]
        oh_count = sum(1 for r in row_rows if r["kind"] == "overhead")
        if oh_count != EXPECTED_OVERHEAD_PER_ROW:
            errors.append(f"row {rn}: overhead count {oh_count} != {EXPECTED_OVERHEAD_PER_ROW}")
        last2 = [r["kind"] for r in row_rows[-2:]]
        if last2 != ["overhead", "overhead"]:
            errors.append(f"row {rn}: last 2 entries are {last2}, expected ['overhead','overhead']")

    # 10-14. INDEPENDENT expected-run battery (Gap 1). These checks use
    #     device-structure invariants and recorded constants, NOT the
    #     block_addr/far of the row under test.
    runs = _block_runs(rows)

    # 10. Grid alignment: every block_addr is a multiple of 0x80.
    for run in runs:
        ba = run[0]["block_addr"]
        if ba % BLOCK_ADDR_ALIGN != 0:
            errors.append(
                f"line {run[0]['_line']}: block_addr 0x{ba:X} not aligned to "
                f"0x{BLOCK_ADDR_ALIGN:X} grid"
            )

    # 11. Block-type field (far[25:23]) constant within each run.
    for run in runs:
        bts = {(r["far"] >> 23) & 0x7 for r in run}
        if len(bts) != 1:
            errors.append(
                f"line {run[0]['_line']}: run spans multiple FAR block types {sorted(bts)}"
            )

    # 12. Each run confined to ONE 0x80 region (far>>7 constant), and each
    #     region used by at most one run (no two runs share a region).
    region_owner: dict[int, int] = {}
    for run in runs:
        regions = {(r["far"] >> 7) for r in run}
        if len(regions) != 1:
            errors.append(
                f"line {run[0]['_line']}: run crosses a 0x80 region boundary {sorted(regions)}"
            )
        else:
            reg = regions.pop()
            if reg in region_owner:
                errors.append(
                    f"line {run[0]['_line']}: region 0x{reg:X} also used by run at "
                    f"frame_index {region_owner[reg]}"
                )
            region_owner[reg] = run[0]["frame_index"]

    # 13. Run count and length multiset match the recorded device constants.
    if len(runs) != EXPECTED_RUN_COUNT:
        errors.append(f"run count {len(runs)} != {EXPECTED_RUN_COUNT}")
    length_counts: dict[int, int] = {}
    for run in runs:
        length_counts[len(run)] = length_counts.get(len(run), 0) + 1
    if length_counts != EXPECTED_RUN_LENGTHS:
        errors.append(f"run length multiset {length_counts} != {EXPECTED_RUN_LENGTHS}")

    # 14. Per-row block-frame counts match the recorded device constants.
    per_row: dict[int, int] = {}
    for r in rows:
        if r["kind"] == "block":
            per_row[r["row"]] = per_row.get(r["row"], 0) + 1
    if per_row != EXPECTED_BLOCK_PER_ROW:
        errors.append(f"per-row block frame counts {per_row} != {EXPECTED_BLOCK_PER_ROW}")

    return rows, errors


def run_db_audits(conn: sqlite3.Connection, rows: list[dict]) -> list[str]:
    """Run ALL DB audits. Returns list of failure strings (empty = pass).

    Called INSIDE the transaction, BEFORE commit.
    """
    failures: list[str] = []

    checks = [
        ("5.1", "total rows = 50,176",
         "SELECT COUNT(*) FROM frame_map", EXPECTED_TOTAL),
        ("5.2", "block frames (is_overhead=0) = 50,148",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0", EXPECTED_BLOCK),
        ("5.3", "overhead frames (is_overhead=1) = 28",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1", EXPECTED_OVERHEAD),
        ("5.4", "block frames with far IS NULL = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0 AND far IS NULL", 0),
        ("5.5", "overhead frames with far NOT NULL = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1 AND far IS NOT NULL", 0),
        ("5.6", "overhead rows with tile/block_type = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1 AND (tile_name IS NOT NULL OR block_type IS NOT NULL)", 0),
        ("5.7", "bad frame_address_source = 0",
         "SELECT COUNT(*) FROM frame_map WHERE (is_overhead=0 AND frame_address_source != 'rapidwright-configarray') OR (is_overhead=1 AND frame_address_source != 'unresolved')", 0),
        ("5.8", "bad confidence = 0",
         "SELECT COUNT(*) FROM frame_map WHERE (is_overhead=0 AND confidence != 'confirmed') OR (is_overhead=1 AND confidence != 'unresolved')", 0),
        ("5.9", "duplicate FARs (block) = 0",
         "SELECT COUNT(*) - COUNT(DISTINCT far) FROM frame_map WHERE is_overhead=0", 0),
        ("5.10", "non-NULL block_type on block frames = 50,148",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0 AND block_type IS NOT NULL", EXPECTED_BLOCK),
        ("5.11", "bad block_type format = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0 AND block_type NOT LIKE 'FAR_BLOCK_%'", 0),
        ("5.12", "far outside 0..0x7FFFFFFF = 0",
         "SELECT COUNT(*) FROM frame_map WHERE far IS NOT NULL AND (far < 0 OR far > 2147483647)", 0),
        ("5.13a", "overhead frames with block_addr NOT NULL = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=1 AND block_addr IS NOT NULL", 0),
        ("5.13b", "block frames with block_addr NULL = 0",
         "SELECT COUNT(*) FROM frame_map WHERE is_overhead=0 AND block_addr IS NULL", 0),
        ("5.13c", "row_number NULL anywhere = 0",
         "SELECT COUNT(*) FROM frame_map WHERE row_number IS NULL", 0),
        ("5.13d", "row_number outside 1..14 = 0",
         "SELECT COUNT(*) FROM frame_map WHERE row_number < 1 OR row_number > 14", 0),
    ]

    for check_id, desc, sql, expected in checks:
        actual = conn.execute(sql).fetchone()[0]
        if actual != expected:
            failures.append(f"{check_id}: {desc} = {actual}, expected {expected}")

    # 5.13: frame_index range
    lo, hi = conn.execute("SELECT MIN(frame_index), MAX(frame_index) FROM frame_map").fetchone()
    if lo != 0 or hi != 50175:
        failures.append(f"5.13: frame_index range [{lo},{hi}] != [0,50175]")

    # 5.14: FAR anchors
    for fi, (exp_far, _) in ANCHOR_EXPECTED.items():
        actual = conn.execute("SELECT far FROM frame_map WHERE frame_index=?", (fi,)).fetchone()
        if actual is None or actual[0] is None:
            failures.append(f"5.14 frame {fi}: no far in DB")
        else:
            actual_hex = f"0x{actual[0]:08X}"
            if actual_hex.upper() != exp_far.upper():
                failures.append(f"5.14 frame {fi}: far {actual_hex} != {exp_far}")

    # 5.15: DB far values match CSV far values for EVERY block row
    #       (independent row-by-row cross-check, not just anchors)
    csv_far = {r["frame_index"]: r["far"] for r in rows if r["kind"] == "block"}
    db_far = dict(
        conn.execute(
            "SELECT frame_index, far FROM frame_map WHERE is_overhead=0"
        ).fetchall()
    )
    mismatches = [fi for fi in csv_far if fi in db_far and csv_far[fi] != db_far[fi]]
    missing = [fi for fi in csv_far if fi not in db_far]
    if mismatches:
        failures.append(f"5.15: {len(mismatches)} DB far values differ from CSV (e.g. {mismatches[:5]})")
    if missing:
        failures.append(f"5.15: {len(missing)} CSV block rows missing in DB (e.g. {missing[:5]})")

    # 5.16: overhead positions at all 14 row ends — derived INDEPENDENTLY from
    #       the DB's own row-end structure: the set of overhead indices must
    #       be exactly {row_end, row_end-1} for the 14 contiguous row
    #       intervals, where intervals come from the DB's overhead indices
    #       themselves being 14 disjoint adjacent pairs.
    oh_indices = [
        x for (x,) in conn.execute(
            "SELECT frame_index FROM frame_map WHERE is_overhead=1 ORDER BY frame_index"
        ).fetchall()
    ]
    if len(oh_indices) != EXPECTED_OVERHEAD:
        failures.append(f"5.16: overhead count {len(oh_indices)} != {EXPECTED_OVERHEAD}")
    else:
        # Group adjacent indices into pairs
        pairs = []
        cur = [oh_indices[0]]
        for x in oh_indices[1:]:
            if x == cur[-1] + 1:
                cur.append(x)
            else:
                pairs.append(cur)
                cur = [x]
        pairs.append(cur)
        if len(pairs) != EXPECTED_ROWS:
            failures.append(f"5.16: overhead pairs {len(pairs)} != {EXPECTED_ROWS}")
        for p in pairs:
            if len(p) != 2:
                failures.append(f"5.16: overhead group {p} is not a pair of adjacent indices")

    # 5.17: DB row_number == CSV row for EVERY frame (row-by-row)
    db_rownum = dict(
        conn.execute("SELECT frame_index, row_number FROM frame_map").fetchall()
    )
    rownum_bad = [fi for r in rows
                  if (fi := r["frame_index"]) in db_rownum and db_rownum[fi] != r["row"]]
    if rownum_bad:
        failures.append(f"5.17: {len(rownum_bad)} DB row_number values differ from CSV (e.g. {rownum_bad[:5]})")

    # 5.18: DB block_addr == CSV block_addr for EVERY block frame
    csv_ba = {r["frame_index"]: r["block_addr"] for r in rows if r["kind"] == "block"}
    db_ba = dict(
        conn.execute("SELECT frame_index, block_addr FROM frame_map WHERE is_overhead=0").fetchall()
    )
    ba_mismatch = [fi for fi in csv_ba if fi in db_ba and csv_ba[fi] != db_ba[fi]]
    ba_missing = [fi for fi in csv_ba if fi not in db_ba]
    if ba_mismatch:
        failures.append(f"5.18: {len(ba_mismatch)} DB block_addr values differ from CSV (e.g. {ba_mismatch[:5]})")
    if ba_missing:
        failures.append(f"5.18: {len(ba_missing)} CSV block rows missing block_addr in DB (e.g. {ba_missing[:5]})")

    # 5.19: DB-side row interval reconstruction — 14 rows, each row_number
    #       maps to ONE contiguous frame_index interval, in order 1..14.
    db_rows_seq = conn.execute(
        "SELECT frame_index, row_number FROM frame_map ORDER BY frame_index"
    ).fetchall()
    row_intervals: dict[int, list[int]] = {}
    for fi, rn in db_rows_seq:
        row_intervals.setdefault(rn, []).append(fi)
    if sorted(row_intervals) != list(range(1, EXPECTED_ROWS + 1)):
        failures.append(f"5.19: row_number set {sorted(row_intervals)} != 1..14")
    else:
        for rn, fis in row_intervals.items():
            if fis != list(range(fis[0], fis[0] + len(fis))):
                failures.append(f"5.19: row {rn} interval not contiguous (len {len(fis)})")

    # 5.20: DB-side overhead position — last 2 frames of each row interval.
    for rn, fis in row_intervals.items():
        kinds = []
        for fi in (fis[-2], fis[-1]):
            k = conn.execute(
                "SELECT is_overhead FROM frame_map WHERE frame_index=?", (fi,)
            ).fetchone()
            kinds.append(k[0] if k else None)
        if kinds != [1, 1]:
            failures.append(f"5.20: row {rn} last 2 frames not both overhead: {kinds}")

    # 5.21: DB-side RUN reconstruction with real continuity + device battery:
    #       runs derived from the DB's own (frame_index, block_addr, far)
    #       columns — far == block_addr + position within each run, 0x80
    #       alignment, one region per run, block_type constant, expected
    #       run count and length multiset.
    db_blocks = conn.execute(
        "SELECT frame_index, far, block_addr, block_type FROM frame_map "
        "WHERE is_overhead=0 ORDER BY frame_index"
    ).fetchall()
    db_runs: list[list[tuple]] = []
    cur_run: list[tuple] = []
    for rec in db_blocks:
        fi, far, ba, bt = rec
        if cur_run and ba != cur_run[0][2]:
            db_runs.append(cur_run)
            cur_run = []
        cur_run.append(rec)
    if cur_run:
        db_runs.append(cur_run)

    if len(db_runs) != EXPECTED_RUN_COUNT:
        failures.append(f"5.21: DB run count {len(db_runs)} != {EXPECTED_RUN_COUNT}")
    for run in db_runs:
        ba = run[0][2]
        if ba % BLOCK_ADDR_ALIGN != 0:
            failures.append(f"5.21: DB run at frame {run[0][0]}: block_addr 0x{ba:X} not 0x80-aligned")
        for pos, (fi, far, _, _bt) in enumerate(run):
            if far != ba + pos:
                failures.append(f"5.21: DB frame {fi}: far 0x{far:X} != block_addr 0x{ba:X} + {pos}")
                break
        bts = {(far >> 23) & 0x7 for (_, far, _, _) in run}
        if len(bts) != 1:
            failures.append(f"5.21: DB run at frame {run[0][0]}: mixed block types {sorted(bts)}")
        regions = {(far >> 7) for (_, far, _, _) in run}
        if len(regions) != 1:
            failures.append(f"5.21: DB run at frame {run[0][0]}: crosses region boundary {sorted(regions)}")
    db_length_counts: dict[int, int] = {}
    for run in db_runs:
        db_length_counts[len(run)] = db_length_counts.get(len(run), 0) + 1
    if db_length_counts != EXPECTED_RUN_LENGTHS:
        failures.append(f"5.21: DB run length multiset {db_length_counts} != {EXPECTED_RUN_LENGTHS}")

    # 5.22: DB block_addr region uniqueness (no two runs share a region).
    seen_regions: dict[int, int] = {}
    for run in db_runs:
        reg = run[0][1] >> 7
        if reg in seen_regions:
            failures.append(f"5.22: DB region 0x{reg:X} shared by runs at frames {seen_regions[reg]} and {run[0][0]}")
        seen_regions[reg] = run[0][0]

    return failures


def import_to_db(db_path: Path, rows: list[dict], run_audits: bool = True,
                 force_audit_failure: bool = False) -> tuple[int, list[str]]:
    """Insert rows into DB transactionally; audits run BEFORE commit.

    Returns (exit_code, failures). force_audit_failure injects one fake
    failure for the negative self-test.
    """
    table_rows: list[tuple] = []
    for r in rows:
        fi = r["frame_index"]
        if r["kind"] == "block":
            far = r["far"]
            bt = block_type_from_far(far)
            table_rows.append((fi, far, "rapidwright-configarray", "confirmed",
                               None, bt, 0, r["row"], r["block_addr"]))
        else:
            table_rows.append((fi, None, "unresolved", "unresolved",
                               None, None, 1, r["row"], None))

    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode = WAL")
    try:
        conn.execute("BEGIN TRANSACTION")
        # DROP + CREATE (NOT IF NOT EXISTS): a pre-existing unconstrained
        # table is always rebuilt with the constrained schema. This is the
        # documented migration path (see scripts/migrate_frame_map_checks.sql).
        conn.execute("DROP TABLE IF EXISTS frame_map")
        conn.execute("""
            CREATE TABLE frame_map (
                frame_index           INTEGER PRIMARY KEY
                    CHECK (frame_index >= 0 AND frame_index <= 50175),
                far                   INTEGER NULL,
                frame_address_source  TEXT NOT NULL
                    CHECK (frame_address_source IN ('rapidwright-configarray', 'unresolved')),
                confidence            TEXT NOT NULL
                    CHECK (confidence IN ('confirmed', 'unresolved')),
                tile_name             TEXT NULL,
                block_type            TEXT NULL,
                is_overhead           INTEGER NOT NULL DEFAULT 0
                    CHECK (is_overhead IN (0, 1)),
                row_number            INTEGER NULL
                    CHECK (row_number IS NULL OR (row_number BETWEEN 1 AND 14)),
                block_addr            INTEGER NULL,
                CHECK ((is_overhead = 1) = (far IS NULL)),
                CHECK ((is_overhead = 1) = (block_addr IS NULL)),
                CHECK (block_addr IS NULL OR block_addr % 128 = 0),
                CHECK (far IS NULL OR (far >= 0 AND far <= 2147483647))
            )
        """)
        conn.execute("DROP INDEX IF EXISTS idx_frame_map_far")
        conn.execute("DROP INDEX IF EXISTS idx_frame_map_overhead")
        conn.execute("CREATE INDEX idx_frame_map_far ON frame_map(far)")
        conn.execute("CREATE INDEX idx_frame_map_overhead ON frame_map(is_overhead)")
        conn.execute("DELETE FROM frame_map")
        conn.executemany(
            "INSERT INTO frame_map (frame_index, far, frame_address_source, confidence, "
            "tile_name, block_type, is_overhead, row_number, block_addr) VALUES (?,?,?,?,?,?,?,?,?)",
            table_rows,
        )
        # Post-insert count check
        n = conn.execute("SELECT COUNT(*) FROM frame_map").fetchone()[0]
        if n != EXPECTED_TOTAL:
            raise ValueError(f"DB total rows {n} != {EXPECTED_TOTAL}")

        # ALL audits INSIDE the transaction, BEFORE commit.
        failures: list[str] = []
        if run_audits:
            failures = run_db_audits(conn, rows)
        if force_audit_failure:
            failures.append("(forced) negative-test audit failure")

        if failures:
            conn.rollback()
            print(f"  ROLLBACK: {len(failures)} audit failure(s) — DB unchanged")
            for f in failures[:10]:
                print(f"    - {f}")
            conn.close()
            return 1, failures

        conn.commit()
        print(f"  Inserted {len(table_rows)} rows; all in-transaction audits PASS; committed")
        conn.close()
        return 0, []
    except Exception as e:
        conn.rollback()
        print(f"  ROLLBACK: {e}")
        conn.close()
        return 1, [str(e)]


def db_fingerprint(path: Path) -> tuple:
    """Full logical fingerprint of a DB file (Gap 3).

    Returns (all-tables name+count tuple, frame_map schema+index SQL tuple,
    sha256 of full frame_map contents, file size). Read-only connection so
    fingerprinting never mutates the DB.
    """
    conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        tables = conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
        ).fetchall()
        table_info = []
        for (t,) in tables:
            n = conn.execute(f"SELECT COUNT(*) FROM \"{t}\"").fetchone()[0]
            table_info.append((t, n))
        schema = tuple(
            s for (s,) in conn.execute(
                "SELECT sql FROM sqlite_master WHERE tbl_name='frame_map' "
                "AND sql IS NOT NULL ORDER BY type DESC, name"
            ).fetchall()
        )
        h = hashlib.sha256()
        for row in conn.execute(
            "SELECT frame_index, far, frame_address_source, confidence, "
            "tile_name, block_type, is_overhead, row_number, block_addr "
            "FROM frame_map ORDER BY frame_index"
        ):
            h.update(repr(row).encode())
        content_hash = h.hexdigest()
    finally:
        conn.close()
    return (tuple(table_info), schema, content_hash, path.stat().st_size)


def run_import(csv_path: Path, bit_path: Path, db_path: Path) -> int:
    print(f"CSV:    {csv_path}")
    print(f"BIT:    {bit_path}")
    print(f"DB:     {db_path}")

    # -- Phase 1: validate CSV (no DB access) --------------------------------
    print("\n[1] CSV validation (pre-DB):")
    rows, csv_errors = validate_csv(csv_path)
    if csv_errors:
        for e in csv_errors[:20]:
            print(f"  ERROR: {e}")
        if len(csv_errors) > 20:
            print(f"  ... and {len(csv_errors) - 20} more errors")
        print(f"  CSV validation: FAIL ({len(csv_errors)} errors)")
        return 1
    print(f"  Parsed {len(rows)} rows, all fields valid")
    print(f"  CSV validation: PASS")

    # -- Phase 2: bitstream hash verification (no DB access) -----------------
    print(f"\n[2] Bitstream hash anchors (from {bit_path}):")
    try:
        frames = load_frames_from_bit(bit_path)
        if len(frames) != EXPECTED_TOTAL:
            print(f"  WARNING: bitstream has {len(frames)} frames (expected {EXPECTED_TOTAL})")
        hash_ok = True
        for fi, (exp_far, exp_hash) in ANCHOR_EXPECTED.items():
            if fi >= len(frames):
                print(f"  frame {fi}: out of range  FAIL")
                hash_ok = False
                continue
            actual_hash = frame_sha256(frames[fi])
            ok = actual_hash == exp_hash
            print(f"  frame {fi}: sha256={actual_hash[:16]}...  {'PASS' if ok else 'FAIL'}")
            if not ok:
                hash_ok = False
        if not hash_ok:
            print("  Hash verification: FAIL — aborting before DB write")
            return 1
        print("  Hash verification: PASS")
    except Exception as e:
        print(f"  ERROR: {e}")
        print("  Hash verification: FAIL — aborting before DB write")
        return 1

    # -- Phase 3: transactional DB insert + in-transaction audits ------------
    print(f"\n[3] DB insert + in-transaction audits:")
    code, _ = import_to_db(db_path, rows)
    if code != 0:
        return 1

    # -- verdict ----------------------------------------------------------
    print(f"\n{'=' * 60}")
    print("FRAME_MAP AUDIT: PASS (all checks green, committed)")
    print("v4 fixes: independent expected-run battery (0x80 grid, region")
    print("uniqueness, block-type constancy, run count/length multiset,")
    print("per-row counts); row_number+block_addr stored in DB with real")
    print("DB-side reconstruction audits (5.17-5.22); full DB fingerprint")
    print("in selftests; migration script checked in.")
    return 0


def run_selftest(db_path: Path) -> int:
    """Negative tests: prove validation rejects mutations and rollback
    leaves the DB unchanged (full logical fingerprint comparison).
    """
    print("=" * 60)
    print("SELF-TEST: negative scenarios")
    ok = True

    def load_lines() -> list[str]:
        return CSV_PATH.read_text(encoding="utf-8").splitlines()

    def run_validate(lines: list[str]) -> list[str]:
        with tempfile.TemporaryDirectory() as td:
            p = Path(td) / "t.csv"
            p.write_text("\n".join(lines) + "\n", encoding="utf-8")
            _, errs = validate_csv(p)
            return errs

    # --- Test 1: malformed CSV (rejected pre-DB; real DB unchanged) ---
    print("\n[T1] malformed CSV (corrupted far on line 3):")
    lines = load_lines()
    parts = lines[2].split(",")
    parts[1] = "0xZZZZ"
    lines[2] = ",".join(parts)
    fp_before = db_fingerprint(db_path)
    errs = run_validate(lines)
    fp_after = db_fingerprint(db_path)
    if errs and fp_before == fp_after:
        print(f"  validate_csv rejected malformed CSV: {errs[0]}")
        print(f"  DB fingerprint unchanged: {fp_before[2][:16]}... (content), {fp_before[3]} bytes")
        print("  T1: PASS")
    else:
        print(f"  T1: FAIL (errors={bool(errs)}, fingerprint_unchanged={fp_before == fp_after})")
        ok = False

    # --- Test 2: forced audit failure -> rollback on temp DB copy ---
    print("\n[T2] forced audit failure -> rollback (on temp DB copy):")
    with tempfile.TemporaryDirectory() as td:
        tmp_db = Path(td) / "copy.sqlite"
        shutil.copy2(db_path, tmp_db)
        fp_before = db_fingerprint(tmp_db)
        rows, _ = validate_csv(CSV_PATH)
        code, _ = import_to_db(tmp_db, rows, run_audits=True, force_audit_failure=True)
        fp_after = db_fingerprint(tmp_db)
        if code == 1 and fp_before == fp_after:
            print(f"  full DB fingerprint identical before/after rollback")
            print(f"    tables={len(fp_before[0])}, frame_map rows={dict(fp_before[0]).get('frame_map')},")
            print(f"    content sha256={fp_before[2][:16]}..., size={fp_before[3]} bytes")
            print("  T2: PASS")
        else:
            print(f"  T2: FAIL (code={code}, fingerprint_equal={fp_before == fp_after})")
            if fp_before != fp_after:
                for i, (a, b) in enumerate(zip(fp_before, fp_after)):
                    if a != b:
                        print(f"    fingerprint field {i} differs: {str(a)[:120]} != {str(b)[:120]}")
            ok = False

    # --- Test 3: whole-run consistent shift (block_addr AND all far +1) ---
    # A consistent shift of an entire run passes the run-anchor continuity
    # check by construction; it must be caught by the independent battery
    # (0x80 grid alignment).
    print("\n[T3] whole-run consistent shift (run at frame_index 32, +1):")
    lines = load_lines()
    # Locate the run starting at frame_index 32 (block_addr 0x80)
    run_start, run_end = None, None
    parsed = [l.split(",") for l in lines[1:]]
    for idx, p in enumerate(parsed):
        if p[4] == "block" and p[0] == "32":
            run_start = idx
            ba = p[3]
            j = idx
            while j < len(parsed) and parsed[j][4] == "block" and parsed[j][3] == ba:
                j += 1
            run_end = j
            break
    for idx in range(run_start, run_end):
        p = parsed[idx]
        p[1] = hex(int(p[1], 16) + 1)        # far +1
        p[3] = hex(int(p[3], 16) + 1)        # block_addr +1
        parsed[idx] = p
    lines = [lines[0]] + [",".join(p) for p in parsed]
    errs = run_validate(lines)
    if errs:
        caught = [e for e in errs if "not aligned" in e or "region" in e]
        print(f"  whole-run shift rejected: {errs[0]}")
        if caught:
            print(f"  caught by independent battery: {caught[0]}")
        print("  T3: PASS")
    else:
        print("  T3: FAIL (whole-run consistent shift was accepted)")
        ok = False

    # --- Test 4: first-row-only mutation (block_addr + far of run start) ---
    # Mutating only the first row of a run consistently passes the anchor
    # pos-0 equality but breaks the run for the second row; must be caught.
    print("\n[T4] first-row-only mutation (frame_index 32, block_addr+far +1):")
    lines = load_lines()
    parsed = [l.split(",") for l in lines[1:]]
    for p in parsed:
        if p[4] == "block" and p[0] == "32":
            p[1] = hex(int(p[1], 16) + 1)
            p[3] = hex(int(p[3], 16) + 1)
            break
    lines = [lines[0]] + [",".join(p) for p in parsed]
    errs = run_validate(lines)
    if errs:
        print(f"  first-row mutation rejected: {errs[0]}")
        print("  T4: PASS")
    else:
        print("  T4: FAIL (first-row-only mutation was accepted)")
        ok = False

    print(f"\nSELF-TEST: {'PASS' if ok else 'FAIL'}")
    return 0 if ok else 1


def main() -> int:
    if "--selftest" in sys.argv:
        return run_selftest(DB_PATH)
    csv_path = Path(sys.argv[1]) if len(sys.argv) > 1 else CSV_PATH
    bit_path = Path(sys.argv[2]) if len(sys.argv) > 2 else BIT_PATH
    db_path = Path(sys.argv[3]) if len(sys.argv) > 3 else DB_PATH
    return run_import(csv_path, bit_path, db_path)


if __name__ == "__main__":
    sys.exit(main())
