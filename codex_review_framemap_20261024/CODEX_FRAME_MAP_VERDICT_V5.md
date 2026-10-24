CONDITIONAL_PASS

# CODEX Frame Map Verdict (v5)

## What this change does

The v5 importer validates the CSV against structural rules and an exact per-run expected table, checks two bitstream frame hashes, then rebuilds and audits `frame_map` in a transaction. The added artifacts materially address the earlier gaps: the expected-run table matches the CSV, the DB row intervals are explicitly partitioned, and the migration DDL is present.

I am retaining **CONDITIONAL_PASS**, not PASS. The supplied v5 logs are not reproducible from this bundle as written, and the claimed full-database fingerprint does not include the WAL bytes that can hold committed SQLite state.

## Must fix

1. **The checked-in selftest points outside the review bundle** (`data/import_frame_map_v5.py:L86-L89`, `L914-L915`, `L1113-L1114`)
   - **What this is:** The script computes `BASE` as the bundle root, but sets the CSV and expected-run defaults to `BASE.parent/phaseA`; T1/T2/T3/T4/T5/T6 load the CSV through that hard-coded `CSV_PATH`. T6 likewise reads `BASE/scripts/migrate_frame_map_checks.sql`.
   - **Problem:** In this bundle, both CSV files and migration SQL are under `data/`; there is no sibling `phaseA` or root `scripts` directory. Running `python data/import_frame_map_v5.py --selftest` here therefore fails before the listed tests complete, and running the supplied T6 logic fails to read its migration SQL. The supplied logs do not establish these tests against the reviewed files; they came from a different tree or path layout.
   - **Fix:** Resolve defaults relative to `Path(__file__).parent` for the `data/` artifacts, and have T6 read the checked-in `data/migrate_frame_map_checks.sql`. Alternatively, parameterize all paths and record a selftest invocation that explicitly points at these artifacts.
   - **If we skip it:** A reviewer or user cannot reproduce the claimed regression and migration checks from the bundle that is being reviewed.

2. **The fingerprint omits SQLite WAL contents** (`data/import_frame_map_v5.py:L787-L802`, `L834-L841`)
   - **What this is:** `db_fingerprint()` hashes the main database file and records only WAL/SHM existence and byte size; its logical content hash covers `frame_map`, while other tables contribute only row counts.
   - **Problem:** In WAL mode, committed changes can reside in `-wal` until checkpoint. A same-size WAL content change to a non-`frame_map` table can leave the main-file hash, sidecar presence/size, schema hash, frame_map hash, and table counts unchanged. Thus T1/T2's equality does not prove “full DB unchanged” under every state described in the request and status document.
   - **Fix:** Fingerprint a stable SQLite snapshot that includes WAL-visible contents, for example by hashing every table's ordered rows from one read transaction, or by using SQLite's backup API to produce a consistent snapshot and hashing that snapshot. Keep sidecar metadata as diagnostic information, not as a substitute for content.
   - **If we skip it:** The rollback evidence can miss same-count changes outside `frame_map`, particularly changes represented in WAL bytes.

## Should fix

3. **The generator is checked in, but the documented reproduction inputs are not** (`data/DumpExpectedRuns.java:L1-L16`; `data/FRAME_INDEX_MAP.md:L66-L76`, `L90-L95`)
   - **What this is:** The Java generator is a short wrapper around RapidWright `ConfigArray`; the docs identify RapidWright 2026.1.0 and an external device-data location.
   - **Problem:** The bundle does not contain the RapidWright JAR or `xc7vx485t_db.dat`, and it does not include the referenced raw enumeration output. A fresh independent generation of the exact table cannot be performed from this bundle alone. This does not invalidate the table's observed match, but “reproducible from the bundle” is stronger than the supplied materials support.
   - **Fix:** Record a fetchable, version-pinned dependency and device-data checksum/source with an executable command, or include a small raw generator output/checksum artifact sufficient to audit the expected-run table's provenance.
   - **If we skip it:** The expected-run table is an effective oracle for mutation detection, but its derivation remains an asserted external provenance rather than a self-contained reproducible chain.

## Recomputed evidence

- Parsed `data/frame_index_far.csv`: 50,176 rows.
- Derived runs by grouping consecutive block rows with the same `block_addr`: 1,183 runs.
- Compared each run's `(start_frame_index, length, block_addr, row, FAR block type)` with `data/expected_runs.csv`: 1,183 entries, zero mismatches.
- The CSV's anchors and the migration's CHECK definitions are described by the artifacts, but I did not rerun the bitstream import or DB migration: the bitstream/database paths in the logs are external to this bundle and the selftest's internal paths do not resolve here.
- The explicit 5.19 code checks all 14 intervals are contiguous, adjacent, and span `[0, 50175]` (`data/import_frame_map_v5.py:L591-L621`).
- The 10-line execution summary follows in the final response.

Verdict: fix 1 and 2 before PASS. The mapping data itself matches the provided exact run table; the remaining issues are in reproducibility and the strength of the “full DB unchanged” evidence.
