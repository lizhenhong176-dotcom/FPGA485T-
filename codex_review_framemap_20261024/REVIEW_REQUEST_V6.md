# REVIEW REQUEST V6 — frame_map import (post v5-review fixes)

## What changed since V5

All items from `CODEX_FRAME_MAP_VERDICT_V5.md` are addressed:

**Must-fix 1 (bundle-relative paths / reproducible selftest)**
- `data/import_frame_map_v6.py` resolves EVERY artifact via
  `_first_existing(script_dir_first, then project_tree)`: the CSV, the
  expected-run table, the migration SQL, and the anchor bitstream.
- The bundle now contains everything the importer needs:
  `data/frame_index_far.csv`, `data/expected_runs.csv`,
  `data/migrate_frame_map_checks.sql`, `data/a_bitstream.bit`
  (sha256 F3F50BD6...), plus `data/bitstream/` (the frame parser
  package) and `data/config.py` it imports.
- `--selftest` is self-contained: when no external model DB exists (or
  `V7RE_SELFTEST_DB=none` is set), it BUILDS its own DB from the bundle
  CSV through the normal transactional import path.
- Evidence, all produced from THIS bundle on this machine:
  - `v6_selftest_bundle_log.txt` — `python data/import_frame_map_v6.py
    --selftest` with `V7RE_SELFTEST_DB=none`: DB built from
    `data/frame_index_far.csv`, T1–T6 ALL PASS.
  - `v6_import_bundle_log.txt` — full import
    `python data/import_frame_map_v6.py data/frame_index_far.csv
    data/a_bitstream.bit <temp db>`: CSV validation PASS, bitstream hash
    anchors (from `data/a_bitstream.bit`) PASS, 50,176 rows committed.
  - T6 reads `data/migrate_frame_map_checks.sql` (sibling of the
    script), no external `scripts/` root.

**Must-fix 2 (WAL-inclusive fingerprint)**
- `db_fingerprint()` v6 no longer hashes only the main file. It takes a
  CONSISTENT SNAPSHOT with the SQLite backup API from a read-only
  connection — the backup includes WAL-visible committed contents — and
  hashes the SNAPSHOT FILE (byte representation of every table's
  contents and all schema objects). Logical layer added: row counts of
  all tables, hash of the complete sqlite_master object dump, frame_map
  content hash. Journal mode and WAL/SHM sidecar presence/size are
  recorded as diagnostics only, explicitly not a substitute for content.
  T1/T2 compare full fingerprint equality before/after (see
  `v6_selftest_log.txt`, project tree, and `v6_selftest_bundle_log.txt`,
  bundle).

**Should-fix 3 (pinned provenance chain)**
- `data/FRAME_INDEX_MAP.md` now records the pinned inputs with
  checksums and exact executable generator commands:
  - RapidWright 2026.1.0 standalone jar,
    sha256 `18F81833595EF8A5191A72F9431727E17602DE2FE4DDDBBA2D281358801A1FC9`
    (from github.com/Xilinx/RapidWright releases, v2026.1.0);
  - device data `xc7vx485t_db.dat`,
    sha256 `53E16B36FE546BEA33E403B101427FD5A33481189FEA3B1D631344A25551F5C6`
    (RapidWright on-demand device download path documented);
  - JDK 17; anchor bitstream sha256 `F3F50BD6...` (bundled).
  - `java -cp rapidwright-2026.1.0-standalone-lin64.jar;. DumpFrameIndex
    frame_index_far.csv` and the DumpExpectedRuns equivalent.

## Review materials (relative to this bundle root)

- `QUESTION.md` — original scope
- `data/import_frame_map_v6.py` — the v6 importer (CURRENT)
- `data/frame_index_far.csv`, `data/expected_runs.csv` — inputs
- `data/DumpExpectedRuns.java` — expected-run generator
- `data/a_bitstream.bit` — anchor bitstream (20 MB)
- `data/bitstream/`, `data/config.py` — parser package used by the importer
- `data/migrate_frame_map_checks.sql` — migration SQL
- `data/FRAME_INDEX_MAP.md` — derivation + pinned provenance
- `data/FRAME_MAP_STATUS_v6.md` — current status
- `v6_run_log.txt`, `v6_selftest_log.txt` — project-tree runs
- `v6_selftest_bundle_log.txt`, `v6_import_bundle_log.txt` — runs from
  THIS bundle
- `CODEX_FRAME_MAP_VERDICT.md` .. `CODEX_FRAME_MAP_VERDICT_V5.md` —
  previous verdicts

## Question for the reviewer

Given (a) the selftest and full import both run to completion from this
bundle alone (logs provided), and (b) the fingerprint now hashes a
backup-API snapshot that includes WAL-visible committed contents — does
the frame_map import now meet the bar for PASS? If not, name the
remaining gaps concretely with file+line evidence.

Evaluation guidance: adversarial, evidence-based; recompute from the
provided artifacts rather than trusting logs. You may rerun
`python data/import_frame_map_v6.py --selftest` and
`python data/import_frame_map_v6.py data/frame_index_far.csv
data/a_bitstream.bit <temp db>` yourself.
