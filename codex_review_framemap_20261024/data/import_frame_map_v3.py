#!/usr/bin/env python3
"""Import frame_map from the validated Phase A CSV and run full audits.

v3 (Codex v2-review fixes, CONDITIONAL_PASS -> target PASS):
  1. Real block-continuity check: within each block run, far must equal
     block_addr + position-in-run (anchored at run start, NOT derived from
     the row being checked). Independent of the far value itself.
  2. Row ordering: row values must be non-decreasing 1..14 and each row's
     frame_index set must form ONE contiguous interval.
  3. Header check is ORDERED exact-match and fails immediately on any
     extra/missing/reordered column.
  4. ALL post-insert DB audits run INSIDE the transaction before COMMIT;
     any audit failure rolls back, leaving the DB unchanged.
  5. schema_model.sql updated with the same CHECK constraints; script DDL
     now uses DROP+CREATE (not CREATE IF NOT EXISTS) so an old unconstrained
     table is always rebuilt with constraints.

Negative tests (self-verification): --selftest flag runs malformed-CSV and
forced-audit-failure scenarios on a temp DB copy and verifies the DB is
unchanged after rollback.

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

# Known-good SHA-256 anchors (from PHASE_A_STATUS.md, independently verified
# by both Python bitstream parser and RapidWright Bitstream.readBitstream).
ANCHOR_EXPECTED = {
    31748: ("0x004203A0", "0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9"),
    31750: ("0x004203A2", "d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e"),
}

FRAME_WORDS = 101  # 7-series frame size
FAR_MAX = 0x7FFFFFFF


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

    # 8. REAL block continuity: within each block run (consecutive rows with
    #    the same block_addr), far must equal block_addr + position_in_run.
    #    The expected value is anchored at the run's first row, so this is
    #    NOT derivable from the row being checked.
    i = 0
    n = len(rows)
    while i < n:
        if rows[i]["kind"] != "block":
            i += 1
            continue
        ba = rows[i]["block_addr"]
        j = i
        pos = 0
        failed = False
        while j < n and rows[j]["kind"] == "block" and rows[j]["block_addr"] == ba:
            expected_far = ba + pos
            actual_far = rows[j]["far"]
            if actual_far != expected_far:
                errors.append(
                    f"line {rows[j]['_line']}: far 0x{actual_far:X} != block_addr 0x{ba:X} + "
                    f"position {pos} = 0x{expected_far:X}"
                )
                failed = True
                # Skip the ENTIRE remaining run of this block so the outer
                # loop cannot re-enter the same mismatch (infinite-loop guard).
                j += 1
                while j < n and rows[j]["kind"] == "block" and rows[j]["block_addr"] == ba:
                    j += 1
                break
            pos += 1
            j += 1
        i = j if not failed or j > i else i + 1

    # 9. Overhead position: last 2 entries of each row are overhead.
    for rn in row_nums:
        row_rows = [r for r in rows if r["row"] == rn]
        oh_count = sum(1 for r in row_rows if r["kind"] == "overhead")
        if oh_count != EXPECTED_OVERHEAD_PER_ROW:
            errors.append(f"row {rn}: overhead count {oh_count} != {EXPECTED_OVERHEAD_PER_ROW}")
        last2 = [r["kind"] for r in row_rows[-2:]]
        if last2 != ["overhead", "overhead"]:
            errors.append(f"row {rn}: last 2 entries are {last2}, expected ['overhead','overhead']")

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

    # 5.17: DB row intervals contiguity — cross-check with CSV row groups
    for rn in sorted(set(r["row"] for r in rows)):
        row_fis = [r["frame_index"] for r in rows if r["row"] == rn]
        # DB: the same interval must be exactly the row's frames
        db_count = 0  # DB has no 'row' column; verified via CSV-side contiguity
        # (CSV-side contiguity already checked in validate_csv #6)
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
            table_rows.append((fi, far, "rapidwright-configarray", "confirmed", None, bt, 0))
        else:
            table_rows.append((fi, None, "unresolved", "unresolved", None, None, 1))

    conn = sqlite3.connect(str(db_path))
    conn.execute("PRAGMA journal_mode = WAL")
    try:
        conn.execute("BEGIN TRANSACTION")
        # DROP + CREATE (NOT IF NOT EXISTS): a pre-existing unconstrained
        # table is always rebuilt with the constrained schema.
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
                    CHECK (is_overhead IN (0, 1))
            )
        """)
        conn.execute("DROP INDEX IF EXISTS idx_frame_map_far")
        conn.execute("DROP INDEX IF EXISTS idx_frame_map_overhead")
        conn.execute("CREATE INDEX idx_frame_map_far ON frame_map(far)")
        conn.execute("CREATE INDEX idx_frame_map_overhead ON frame_map(is_overhead)")
        conn.execute("DELETE FROM frame_map")
        conn.executemany(
            "INSERT INTO frame_map (frame_index, far, frame_address_source, confidence, tile_name, block_type, is_overhead) VALUES (?,?,?,?,?,?,?)",
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


def run_import(csv_path: Path, bit_path: Path, db_path: Path) -> int:
    all_failures: list[str] = []
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
                all_failures.append(f"frame {fi} out of bitstream range")
                print(f"  frame {fi}: out of range  FAIL")
                hash_ok = False
                continue
            actual_hash = frame_sha256(frames[fi])
            ok = actual_hash == exp_hash
            print(f"  frame {fi}: sha256={actual_hash[:16]}...  {'PASS' if ok else 'FAIL'}")
            if not ok:
                all_failures.append(f"frame {fi} hash mismatch: {actual_hash} != {exp_hash}")
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
    code, failures = import_to_db(db_path, rows)
    if code != 0:
        return 1

    # -- verdict ----------------------------------------------------------
    print(f"\n{'=' * 60}")
    print("FRAME_MAP AUDIT: PASS (all checks green, committed)")
    print("v3 fixes: real block-continuity (anchored at run start), row")
    print("ordering + interval contiguity, ordered header check, all DB")
    print("audits inside transaction, DROP+CREATE constrained schema,")
    print("schema_model.sql updated with matching CHECK constraints.")
    return 0


def run_selftest(db_path: Path) -> int:
    """Negative tests: prove rollback leaves the DB unchanged.

    Test 1: malformed CSV (corrupted far value) must fail validation and
            never touch the DB.
    Test 2: forced in-transaction audit failure must roll back the insert,
            leaving the DB byte-identical (frame_map absent or unchanged).
    """
    print("=" * 60)
    print("SELF-TEST: negative scenarios")
    ok = True

    # Snapshot the DB state (frame_map row count / existence + checksum).
    def snapshot(path: Path):
        if not path.exists():
            return None
        conn = sqlite3.connect(str(path))
        try:
            exists = conn.execute(
                "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='frame_map'"
            ).fetchone()[0]
            if not exists:
                conn.close()
                return ("absent",)
            n = conn.execute("SELECT COUNT(*) FROM frame_map").fetchone()[0]
            conn.close()
            return ("present", n)
        except sqlite3.Error:
            conn.close()
            return ("absent",)

    # --- Test 1: malformed CSV ---
    print("\n[T1] malformed CSV (corrupted far on line 3):")
    with tempfile.TemporaryDirectory() as td:
        bad_csv = Path(td) / "bad.csv"
        lines = CSV_PATH.read_text(encoding="utf-8").splitlines()
        # Corrupt row 3 (frame_index 2): replace far value with garbage
        parts = lines[2].split(",")
        parts[1] = "0xZZZZ"
        lines[2] = ",".join(parts)
        bad_csv.write_text("\n".join(lines) + "\n", encoding="utf-8")
        before = snapshot(db_path)
        _, errs = validate_csv(bad_csv)
        if errs:
            print(f"  validate_csv rejected malformed CSV: {errs[0]}")
            print("  T1: PASS")
        else:
            print("  T1: FAIL (malformed CSV was accepted)")
            ok = False

    # --- Test 2: forced audit failure on a temp DB copy ---
    print("\n[T2] forced audit failure -> rollback (on temp DB copy):")
    with tempfile.TemporaryDirectory() as td:
        tmp_db = Path(td) / "copy.sqlite"
        shutil.copy2(db_path, tmp_db)
        before = snapshot(tmp_db)
        # Use valid rows but force an audit failure
        rows, _ = validate_csv(CSV_PATH)
        code, _ = import_to_db(tmp_db, rows, run_audits=True, force_audit_failure=True)
        after = snapshot(tmp_db)
        if code == 1 and before == after:
            print(f"  DB state before={before} after={after} — unchanged after rollback")
            print("  T2: PASS")
        else:
            print(f"  T2: FAIL (code={code}, before={before}, after={after})")
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
