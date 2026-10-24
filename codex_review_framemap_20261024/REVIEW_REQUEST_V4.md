# Re-review Request (v4): frame_map import after Codex v3 CONDITIONAL_PASS fixes

## v3 verdict (your previous review)

CONDITIONAL_PASS with 4 remaining gaps. All 4 addressed in v4.

## How each v3 gap was fixed

**Gap 1 — independent expected block-start/length source; first-row
mutation test.**
`validate_csv()` in `data/import_frame_map_v4.py` now has an INDEPENDENT
expected-run battery (checks 10-14 in the code, 17-21 in the status doc):
- 0x80 grid alignment: every block_addr must be a multiple of 0x80
  (device-structure property of the 7-series FAR address space);
- FAR block-type field (far[25:23]) constant within each run;
- each run confined to exactly ONE 0x80 region (far>>7 constant) and no
  two runs share a region;
- run count == 1,183 and length multiset == {36:777, 28:245, 128:105,
  30:28, 32:14, 42:14} (constants recorded from the RapidWright
  ConfigArray derivation in phaseA/FRAME_INDEX_MAP.md — the explicit
  expected run table);
- per-row block-frame counts == {rows 1-7: 5244, rows 8-14: 1920}.
These checks are NOT derivable from the row under test. Two new negative
tests prove mutation detection:
- **T3**: whole-run consistent shift (block_addr AND all far of the run
  at frame_index 32 shifted by +1 — passes run-anchor continuity by
  construction) is rejected by the grid-alignment check. See
  `data/v4_selftest_log.txt`.
- **T4**: first-row-only mutation (block_addr+far of the run's first row
  shifted by +1) is rejected (FAR duplicate + run split).

**Gap 2 — vacuous 5.17 loop removed; metadata stored in DB.**
- `frame_map` now STORES `row_number` (1..14, all rows) and `block_addr`
  (block frames only) columns with CHECK constraints.
- The vacuous loop is deleted. Real DB-side reconstruction audits:
  5.17 DB row_number == CSV row for EVERY frame; 5.18 DB block_addr ==
  CSV block_addr for EVERY block frame; 5.19 row intervals reconstructed
  from DB (14 contiguous intervals, ordered 1..14); 5.20 overhead at the
  last 2 positions of each DB-reconstructed row interval; 5.21 runs
  reconstructed from the DB's own (frame_index, block_addr, far) columns
  with far == block_addr + position, alignment, block-type constancy,
  region confinement, and the expected length multiset; 5.22 region
  uniqueness across DB-reconstructed runs.

**Gap 3 — rollback evidence strength.**
- New `db_fingerprint()` captures a FULL logical fingerprint: all 21
  table names + row counts, frame_map schema + index SQL from
  sqlite_master, sha256 over all 50,176 frame_map rows (all columns,
  ordered), and file size. Read-only URI connection.
- T2 compares this full fingerprint before/after the forced-failure
  rollback on a temp DB copy — identical (see `data/v4_selftest_log.txt`).
- T1 now COMPARES (not merely captures) the real-DB fingerprint before
  and after the malformed-CSV validation — identical.

**Gap 4 — migration script checked in; stale schema fixed.**
- `data/migrate_frame_map_checks.sql` (synced from
  `v7re/scripts/migrate_frame_map_checks.sql`) now exists: BEGIN → DROP
  indexes/table → CREATE constrained v4 schema → COMMIT, with header
  documenting that row_number/block_addr data must be re-imported via
  `import_frame_map.py` (which itself performs DROP+CREATE+INSERT in one
  transaction and is the alternative migration path).
- The stale unconstrained `data/schema_model.sql` in the bundle has been
  REPLACED with the current constrained v4 schema (identical to
  `data/schema_model_v4.sql`), so the bundle is now self-consistent.

## Files in this bundle

- `data/import_frame_map_v4.py` — v4 script (all gap fixes)
- `data/v4_run_log.txt` — real run: all checks PASS, committed
- `data/v4_selftest_log.txt` — T1/T2/T3/T4 negative scenarios all PASS
- `data/schema_model_v4.sql` — canonical schema with v4 columns + CHECKs
- `data/schema_model.sql` — REPLACED stale copy; now identical to v4
- `data/migrate_frame_map_checks.sql` — the referenced migration script
- `data/FRAME_MAP_STATUS_v4.md` — updated status doc (31 audit rows)
- Previous-round files (v1/v2/v3 scripts, docs, schemas, verdicts) kept
  for diff reference
- `data/frame_index_far.csv` — unchanged input (50,176 rows)
- `data/FRAME_INDEX_MAP.md` — derivation doc (provenance of the expected
  run constants), unchanged

## Question for the reviewer

Given the v4 fixes and the attached run + selftest logs, should the verdict
be upgraded to PASS? If not, what specific additional evidence or code
changes are required? Be adversarial: verify the independent battery is
truly independent of the checked rows (are the embedded constants a
legitimate expected-run table?), confirm 5.17-5.22 are real DB-side
reconstructions, check the fingerprint comparison actually proves
"DB unchanged", and check the migration script and bundle schema
consistency.
