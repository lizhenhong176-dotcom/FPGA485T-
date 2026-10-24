# CODEX Frame Map Verdict (v4)

## Verdict

**CONDITIONAL_PASS**

The v4 importer addresses the four v3 findings in code: it adds fixed run-shape assertions and mutation tests, stores row/block metadata for actual DB queries, compares pre/post fingerprints, and includes migration DDL plus an updated bundle schema. The selftest passes when rerun. I am not upgrading to PASS because the purported expected-run table has only asserted provenance, not auditable/reproducible provenance, and the fingerprint is not a full database-state fingerprint at the strength the request claims.

## Per-gap fix assessment

### Gap 1: Independent expected run starts/lengths and first-row mutation

**Partially fixed.** The code checks 0x80 alignment, constant FAR block type, per-run region confinement and uniqueness, expected run count (1,183), run-length multiset, and per-row block counts. These checks are independent of the value in the individual row in the narrow sense that they compare against literals rather than recomputing the expected value from that row. T3 exercises a whole-run shift and correctly catches the alignment violation. T4 is rejected, but by duplicate FAR detection; it does not demonstrate rejection by an independent expected start or run table.

The constants are not yet a credible, independently auditable expected-run table. `FRAME_INDEX_MAP.md` describes RapidWright ConfigArray enumeration and gives aggregate totals and six anchors, but this bundle contains no actual 1,183-entry expected-run table, raw enumeration output, or reproducible generator. The multiset and per-row totals are aggregates, not exact per-run starts. The 0x80 property may independently constrain starts, but permits any aligned start satisfying the other aggregates. Thus the battery detects classes of corruption, not arbitrary aligned run relocation/reassignment. The checked-in CSV remains the only supplied full mapping source.

### Gap 2: DB-side reconstruction checks 5.17-5.22

**Mostly fixed.** 5.17 and 5.18 now query stored `row_number` and `block_addr` and compare them row-by-row with validated CSV data. 5.19 groups actual DB rows by `row_number` and checks contiguous intervals; 5.20 queries the last two positions of each reconstructed interval; 5.21 derives runs from DB `frame_index`, `block_addr`, `far`, and `block_type` and checks continuity, alignment, type, region, count, and length multiset; 5.22 checks DB-run region uniqueness. These are non-vacuous DB reads and assertions.

Limits: 5.17/5.18 cross-check against CSV, so they verify insertion fidelity rather than independent correctness. 5.19 checks continuity within each row but does not directly assert that the 14 intervals abut or cover 0..50175; other global index and count checks partly cover this. It should additionally assert interval starts/ends are consecutive and endpoints are exact.

### Gap 3: Fingerprint and “DB unchanged” claim

**Partially fixed.** T1 now compares before/after fingerprints on the real DB, and T2 compares before/after on a copied DB after a forced in-transaction failure. Both comparisons passed in the rerun. The fingerprint includes all table names and counts, frame_map schema/index SQL, a hash of all frame_map rows, and main-file size.

This does not prove “full DB unchanged” as claimed: non-frame_map tables are represented only by counts, so same-count content changes are invisible; schema SQL for those tables/views/triggers and their indexes is omitted; database file size is a weak substitute for file contents; and SQLite WAL/SHM sidecars are not fingerprinted. T1 also only tests a pre-DB validation failure, which by control flow never opens the database for writing; that is useful but not rollback evidence. T2 is meaningful rollback coverage, but on a copy and with the stated logical fingerprint limitations.

### Gap 4: Migration script and bundle schema consistency

**Fixed for the bundled frame_map definition.** `migrate_frame_map_checks.sql` recreates the v4 table and indexes, and its frame_map columns and CHECK constraints match the importer DDL and both schema model files. `schema_model.sql` and `schema_model_v4.sql` are identical. The migration intentionally creates an empty table and documents re-import, which matches the added metadata being absent from the older table.

The migration script itself is destructive to the old frame_map data when run alone, but the header clearly warns that the table is rebuilt empty and requires re-import. The importer provides a transactional alternative. Its usage text names the project path `scripts/import_frame_map.py`, while the bundle only contains `data/import_frame_map_v4.py`; this does not invalidate DDL consistency, but weakens standalone reproducibility of the stated migration procedure. The request does not provide the actual project-side importer/schema, so only bundle consistency was verified.

## Remaining gaps / required actions

1. Check in an exact expected-run artifact (at minimum per-run expected `frame_index`, `block_addr`, and length), plus the raw RapidWright ConfigArray output or a reproducible generator/version/part identifier. Validate CSV runs against it, and mutate an aligned run start to show the exact-start assertion rejects it.
2. Strengthen the fingerprint to cover every table's contents and all schema objects (tables, indexes, views, triggers), and either hash the SQLite main file plus relevant WAL state consistently or describe it accurately as a logical frame_map fingerprint. Keep T2 as the rollback test; T1 establishes prevalidation non-mutation only.
3. In 5.19, explicitly assert row intervals are adjacent and span exactly 0..50175. (Current global checks reduce the impact but the reconstruction claim should assert its own full partition property.)
4. Make migration instructions executable from this bundle or clearly scope them to the external project tree; ideally run the migration against a disposable old-schema DB and verify re-import succeeds.

The v4 changes materially improve validation and the supplied CSV passes the implemented checks. The remaining issues concern independence and the strength/reproducibility of the evidence, so PASS is not yet justified.

## Model and command used

- Model: `gpt-6.1-sol`
- Command requested: `codex exec --model gpt-6.1-sol --sandbox danger-full-access`
- Review actions: read `REVIEW_REQUEST_V4.md`, `CODEX_FRAME_MAP_VERDICT_V3.md`, all files under `data/`; inspected the v4 importer, status/derivation docs, run and selftest logs, migration DDL, and schema files; compared `schema_model.sql` with `schema_model_v4.sql`; ran `python data/import_frame_map_v4.py --selftest` (T1/T2/T3/T4 PASS).
