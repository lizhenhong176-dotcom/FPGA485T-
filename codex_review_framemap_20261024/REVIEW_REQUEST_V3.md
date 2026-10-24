# Re-review Request (v3): frame_map import after Codex v2 CONDITIONAL_PASS fixes

## v2 verdict (your previous review)

CONDITIONAL_PASS with 5 remaining gaps. All 5 addressed in v3.

## How each v2 gap was fixed

**Gap 1 — tautological block-continuity + header set-compare.**
`validate_csv()` in `data/import_frame_map_v3.py`:
- Block continuity now anchors at the RUN START: within each consecutive
  run sharing one `block_addr`, row at run position `pos` must have
  `far == block_addr + pos`. The expected value comes from the run's first
  row + position, not from the checked row's own far. An infinite-loop
  guard skips the whole failed run (a bug found by our own negative test:
  mismatch + `i = j` re-entered the same run forever; fixed and covered).
- Header check is now ORDERED exact equality with
  `["frame_index","far","row","block_addr","kind"]` and fails immediately
  (returns errors, no parsing).
- `block_addr` now range-validated (0..0x7FFFFFFF) like far.

**Gap 2 — row ordering/contiguity + DB-side field checks.**
- New CSV checks: row values non-decreasing, start 1 end 14, and each
  row's frame_index set must be ONE contiguous interval.
- New DB audits (inside the transaction): block_type non-NULL + format
  `FAR_BLOCK_%` on all 50,148 block rows; far range check; and 5.15 —
  DB far == CSV far cross-checked for EVERY block row (row-by-row dict
  compare, not just the 2 anchors).

**Gap 3 — audits run after commit.**
- `import_to_db()` now runs `run_db_audits(conn, rows)` INSIDE the
  transaction, BEFORE commit. Any failure → `conn.rollback()` → DB
  unchanged. The success message only prints after commit.
- Negative test T2 (`--selftest`): forces an audit failure on a temp DB
  copy and verifies the DB state is identical before/after (see
  `data/v3_selftest_log.txt`: `before=('present', 50176) after=('present',
  50176) — unchanged after rollback`).

**Gap 4 — schema_model.sql missing CHECK constraints.**
- `data/schema_model_v3.sql` (synced from `v7re/db/schema_model.sql`) now
  has the identical CHECK constraints. The script uses
  `DROP TABLE IF EXISTS` + `CREATE TABLE` (not IF NOT EXISTS), so an old
  unconstrained table is always rebuilt constrained — this is the
  migration path for existing DBs (documented in the schema comment).

**Gap 5 — malformed-CSV / audit-failure evidence.**
- `--selftest` runs both negative scenarios on demand:
  T1 corrupts far to `0xZZZZ` on line 3 → `validate_csv` rejects pre-DB;
  T2 forced audit failure → rollback, DB unchanged.
  Log: `data/v3_selftest_log.txt`.

## Files in this bundle

- `data/import_frame_map_v3.py` — v3 script (all gap fixes)
- `data/v3_run_log.txt` — real run: all checks PASS, committed
- `data/v3_selftest_log.txt` — T1/T2 negative scenarios PASS
- `data/schema_model_v3.sql` — schema with CHECK constraints (matches script DDL)
- `data/FRAME_MAP_STATUS_v3.md` — updated status doc
- Previous-round files (v1/v2 scripts, docs, schema) kept for diff reference
- `data/frame_index_far.csv` — unchanged input (50,176 rows)
- `data/FRAME_INDEX_MAP.md` — derivation doc, unchanged

## Question for the reviewer

Given the v3 fixes and the attached run + selftest logs, should the verdict
be upgraded to PASS? If not, what specific additional evidence or code
changes are required? Be adversarial: re-check the block-continuity anchor
logic (is it truly independent of the checked row?), the in-transaction
audit coverage (any check still outside?), the negative tests (do they
prove what they claim?), and schema/DDL consistency.
