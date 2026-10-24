PASS

# CODEX Frame Map Verdict (v6)

## What this change does

The v6 importer validates the complete 50,176-row CSV, checks two frame hashes from the bundled bitstream, compares all 1,183 reconstructed runs with the expected-run table, and inserts the constrained `frame_map` inside one transaction with in-transaction audits. It also makes the selftest bundle-relative, builds a selftest database when no external DB is available, and fingerprints a SQLite backup snapshot so committed WAL contents are included.

## Review result

PASS. I reran `V7RE_SELFTEST_DB=none python data/import_frame_map_v6.py --selftest`; T1-T6 all passed. I also reran the full import with `data/frame_index_far.csv`, `data/a_bitstream.bit`, and a fresh temporary database; CSV validation, both bitstream anchors, the 50,176-row insert, and all audits passed.

I independently recomputed the supplied claims. `data/frame_index_far.csv` has SHA-256 `77A4655FB8C327DB7CE7C8B9FE63D6A08AB6512EA07CAF0D0401258FBFDD0A46`; grouping its rows gives 1,183 runs, and every `(start, length, block_addr, row, block_type)` matches `data/expected_runs.csv`. The bundled bitstream hash is `F3F50BD637D26A25AEB8BF39EC9C8CB9EE2C69E820667CEA0F6ED658C929C6E7`, matching `data/FRAME_INDEX_MAP.md`.

The prior V5 must-fix gaps are closed: artifact resolution prefers the script directory (`data/import_frame_map_v6.py:94-120`), the selftest constructs its own DB (`data/import_frame_map_v6.py:1218-1238`), T6 reads the sibling migration SQL (`data/import_frame_map_v6.py:1153-1207`), and `db_fingerprint()` hashes a read-only SQLite backup snapshot (`data/import_frame_map_v6.py:817-888`). The provenance concern is reduced to a documented, version-pinned, checksummed RapidWright JAR and device-data source with executable generator commands (`data/FRAME_INDEX_MAP.md:84-99`); those external inputs are not needed for the bundle import itself.

## Remaining limitations

The importer still validates the expected-run CSV structurally rather than cryptographically pinning its file hash, and the RapidWright generator inputs are fetched externally. Those are provenance/auditability limitations, not a demonstrated correctness or rollback failure in this self-contained review bundle. The expected-run table is checked against the independently recomputed CSV runs, and the importer’s negative relocation test demonstrates that the exact table is load-bearing.

Verdict: Ship.

