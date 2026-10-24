# CODEX Frame Map Verdict (v3)

## Verdict

**CONDITIONAL_PASS**

The v3 importer validates the supplied CSV, passes the recorded anchor checks, and runs the insert audits before commit. It fixes the ordered-header check, adds useful row and DB checks, and the forced-audit path does roll back. It does not yet support PASS because two of the claimed independence properties are still vacuous or only partially independent, and the negative tests do not prove the rollback claims they print.

## Per-gap fix assessment

### Gap 1: Block-continuity anchor independence and header checks

**Partially fixed.** The header comparison is now ordered exact equality and returns before parsing on mismatch. For rows after the first row of a consecutive `block_addr` run, `far == run_start_block_addr + position` is independent of that checked row's `far`, and the failed-run jump prevents re-entering the same run.

The run's first expected value is still `rows[i]["block_addr"] + 0`; there is no independent expected block start or run length. A first-row pair with both `block_addr` and `far` changed consistently can pass, so this does not fully replace the v2 tautology with an external anchor. `block_addr` range checking is otherwise present.

### Gap 2: Row ordering/contiguity and DB-side field checks

**Partially fixed.** CSV row monotonicity, 1..14 bounds, contiguous frame-index intervals, block-type checks, FAR range checks, and the all-block-row FAR comparison are implemented. The supplied CSV passes them.

The advertised DB row-interval audit (`5.17`) performs no DB query or assertion: it assigns `db_count = 0` and relies on the CSV-side check. The imported DB schema has no `row`, `block_addr`, or `kind` columns, so those fields cannot be audited after insertion. This remains a coverage gap for the claimed DB-side audit completeness.

### Gap 3: Audits inside the transaction

**Fixed for the implemented DB audits.** `DROP`, `CREATE`, insert, the post-insert count check, `run_db_audits()`, and the forced failure all occur between `BEGIN TRANSACTION` and `commit()`. The success message is printed only after commit. CSV parsing and bitstream hashes intentionally occur before DB mutation and are not post-insert audits.

### Gap 4: Schema/DDL consistency

**Mostly fixed, with a migration-documentation defect.** `schema_model_v3.sql` contains the same frame-map columns and CHECK constraints as the importer's CREATE statement; the importer uses `DROP TABLE` plus `CREATE TABLE`, so its own import path rebuilds an old unconstrained table. However, the schema comment names `scripts/migrate_frame_map_checks.sql`, which is absent from the bundle, and the older `data/schema_model.sql` remains unconstrained. The claimed project-wide schema update is therefore not reproducible from the checked-in files as supplied.

### Gap 5: Malformed-CSV and audit-failure evidence

**Partially fixed.** T1 demonstrably changes a block FAR to `0xZZZZ` and `validate_csv()` rejects it before DB work. T2 demonstrably forces an in-transaction audit failure and observes rollback with the same table existence and row count.

Neither test proves the stronger “DB unchanged”/“byte-identical” claim: the snapshot only records `(present|absent, row_count)`, and T1 captures `before` but never compares it. A rollback that changed schema, indexes, values, or other tables could pass these tests.

## Remaining gaps / required actions

1. Add an independent expected block-start/length source (or an explicit expected run table) and test a mutated first-row `block_addr`/`far` pair; the current run-start anchor alone is not sufficient.
2. Remove the vacuous `5.17` loop and either store the required row/block metadata in `frame_map` or perform a real DB-side reconstruction/query that asserts row intervals and all imported metadata.
3. Make the rollback selftest compare a full database fingerprint (schema SQL, indexes, table contents, and relevant file state) before and after; compare the pre-DB snapshot in T1 as well.
4. Check in the referenced migration script, or correct the schema documentation, and update `data/schema_model.sql` if it remains a supported canonical schema.

These are material integrity/evidence gaps, so the result remains CONDITIONAL_PASS rather than PASS. No evidence in the supplied run shows a wrong anchor or wrong row in the supplied CSV.

## Model and command used

- Model: `gpt-6.1-sol`
- Command requested: `codex exec --model gpt-6.1-sol --sandbox danger-full-access`
- Review actions: read `REVIEW_REQUEST_V3.md`, `CODEX_FRAME_MAP_VERDICT_V2.md`, all supplied text files under `data/`, inspected the v3 importer, schema, run log, and selftest log, validated `data/frame_index_far.csv` with `validate_csv()` (50,176 rows, 0 errors), and ran `python data/import_frame_map_v3.py --selftest` (T1/T2 PASS).
