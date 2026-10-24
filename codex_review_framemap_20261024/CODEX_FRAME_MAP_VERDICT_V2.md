# CODEX Frame Map Verdict (v2)

## Verdict

**CONDITIONAL_PASS**

The supplied CSV passes the v2 validator and the supplied run log records the expected anchor hashes, counts, and row-end checks. The v2 changes materially address the original pre-DB validation and input-hash ordering concerns. They do not yet justify PASS because important validation claims are either missing or vacuous, the checked-in schema does not contain the claimed constraints, and the transaction does not cover the complete import-and-audit operation.

## Per-issue fix assessment

### P1-1: Import robustness

**Partially fixed.** `import_frame_map_v2.py` validates integer/hex/enumeration fields before opening the DB, verifies the two bitstream hashes before mutation, and rolls back errors raised during table creation/insertion. The bundled CSV independently reproduces `validate_csv()` with 50,176 rows and zero errors.

The fix is incomplete in three material ways:

1. The advertised `block_addr + offset == far` validation is vacuous. The code sets `offset = far - ba` and therefore the equation is true for every pair; it never checks an independently expected block offset or block length. `block_addr` also has no range/shape constraint beyond parseable hex.
2. The “exact header” check compares sets, so a reordered header is accepted; extra columns only add an error but parsing continues. Enforce ordered equality to the five-column header and reject immediately.
3. `CREATE TABLE IF NOT EXISTS` does not retrofit constraints onto an existing `frame_map` table. Thus a pre-existing unconstrained table can remain unconstrained even though the script's inline DDL has CHECKs.

### P1-2: Audit completeness

**Partially fixed.** Counts, FAR uniqueness, anchor checks, provenance/null invariants, and overhead-at-row-end checks are present. However, frame-index continuity does not validate row monotonicity or that each row is one contiguous interval. The row-end check derives its boundaries from the same CSV grouping that supplied the insert, so it is not an independent transaction-level audit. The script also does not verify block_type, far range, or per-row/block metadata in the resulting DB.

The claimed “block continuity” audit is therefore not evidence of continuity. Add an independent expected offset/length check and assert `row` is nondecreasing, each row has one contiguous frame-index interval, and DB row/order values match the CSV-derived expectations.

### P2-3: Schema CHECK constraints

**Not fixed in the project schema.** The inline CREATE statement in `import_frame_map_v2.py` has CHECKs, but `data/schema_model.sql` still declares `frame_map` without any CHECK constraints. The request explicitly asks for script/schema consistency; they are inconsistent. Update `schema_model.sql` and provide a migration/rebuild path for existing databases, then verify with `PRAGMA table_info`/`sqlite_master` on the target DB.

### P2-4: Status-document wording

**Fixed.** `FRAME_MAP_STATUS_v2.md` appropriately limits the overhead claim to the current RapidWright public API/toolset and explicitly states that all 50,148 FARs were not independently re-derived from a second source. The status document still names the old artifact paths (`phaseA/...`, `v7re/...`) rather than the files in this review bundle, which should be corrected for reproducibility, but the substantive scope correction is adequate.

## Remaining gaps / required actions

1. Make the CSV header check ordered and fail on any extra/missing column; validate every field's semantic relationship, including independent block offsets/lengths and `block_addr` bounds.
2. Add a real row-order/contiguity audit and DB-side checks for all imported fields, including `block_type` and the expected FAR values for every block row.
3. Move all post-insert audits into the transaction, or explicitly roll back/delete the new table on any audit failure. Do not report a successful commit before the audit gate.
4. Add the same CHECK constraints to `data/schema_model.sql` and test migration behavior when `frame_map` already exists without them.
5. Re-run the importer after these changes and attach a log showing a deliberate malformed CSV and a forced post-insert audit failure leave the database unchanged.

These are P1/P2 correctness and integrity issues, so the current result remains CONDITIONAL_PASS rather than PASS. No P0 evidence of a wrong anchor or wrong supplied CSV row was found.

## Model and command used

- Model: `gpt-6.1-sol`
- Command requested: `codex exec --model gpt-6.1-sol --sandbox danger-full-access`
- Review actions: read `REVIEW_REQUEST_V2.md`, all files under `data/`, inspected the v2 script/schema/run log, and executed the v2 `validate_csv()` against `data/frame_index_far.csv` (50,176 rows, 0 validator errors).
