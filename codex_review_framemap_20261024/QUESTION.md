# Review Request: frame_map (Phase A)

## Context

You are reviewing the `frame_map` table for a Virtex-7 (xc7vx485t) bitstream
reverse-engineering project. The table maps bitstream payload frame indices
(0..50175) to FAR (Frame Address Register) values.

## Claim

1. The bitstream has 50,176 configuration frames.
2. RapidWright `ConfigArray` on xc7vx485t enumerates 50,148 block frames
   (14 config rows → 1,183 blocks → frames) with confirmed FAR addresses.
3. The remaining 28 frames are 2 overhead frames at the end of each of the
   14 config rows.
4. For these 28 overhead frames, the exact FAR values are **unrecoverable**
   from the RapidWright public API (a prior Codex review confirmed this
   with verdict PARTIAL). The DB therefore stores `far=NULL,
   frame_address_source='unresolved', confidence='unresolved'` for these
   28 rows.
5. The mapping was validated against 6 independent anchors (frame indices
   274, 5520, 21364, 31712, 31748, 31750), all matching exactly.
6. A bitstream hash verification was re-run (not cited): frame 31748
   sha256=0441772f... and frame 31750 sha256=d44f0364... both match.

## Evidence files

- `frame_index_far.csv` — 50,176 rows (full dump from RapidWright
  ConfigArray + overhead insertion). Columns:
  `frame_index,far,row,block_addr,kind` (kind = block|overhead).
- `frame_index_far_sample.txt` — sample: first 100 rows, anchor area
  (rows 31740-31760), last 100 rows.
- `FRAME_INDEX_MAP.md` — the mapping derivation and 6-anchor validation.
- `import_frame_map.py` — import + audit script (creates frame_map table,
  inserts 50,176 rows, runs 12 audit checks, re-verifies hash anchors).
- `schema_model.sql` — updated schema (frame_map table added at end).
- `FRAME_MAP_STATUS.md` — status document with all audit results.

## Review questions

1. **Correctness of the frame count claim**: Is 50,148 block frames +
   28 overhead = 50,176 total consistent with a Virtex-7 485T bitstream?
   Is the 2-per-row overhead insertion consistent with the known 7-series
   architecture?

2. **CSV validation**: Read `frame_index_far_sample.txt`. Check:
   - Are frame_index values 0..50175, unique, continuous?
   - Are block frames' FARs monotonically increasing within each block?
   - Do the anchor rows (frame_index 31748 → far 0x4203a0, frame_index
     31750 → far 0x4203a2) appear correctly?
   - Are overhead rows correctly marked (kind=overhead)?

3. **Schema design**: Is the `frame_map` table schema appropriate?
   Are the field names, types, and constraints correct for this purpose?
   Is `far=NULL` for overhead rows the right decision given the PARTIAL
   Codex verdict on overhead FAR recovery?

4. **Audit completeness**: The audit script checks 12 conditions. Are there
   any missing checks that should be added?

5. **Import script quality**: Read `import_frame_map.py`. Check:
   - Does the CSV parsing handle edge cases (empty far, malformed hex)?
   - Is the block_type extraction from FAR bits [25:23] correct?
   - Are the SQL statements safe from injection (parameterized)?
   - Is the bitstream hash verification method correct (SHA-256 of
     big-endian 101-word frame data)?

6. **Status doc accuracy**: Read `FRAME_MAP_STATUS.md`. Are all claims
   accurate and properly scoped?

## Verdict format

Please provide a verdict of one of:
- **PASS** — all claims are correct, evidence is sufficient, no issues found
- **CONDITIONAL_PASS** — correct overall but with minor issues to fix
- **REJECT** — significant issues that must be addressed

For each issue found, specify severity (P0/P1/P2) and the exact fix needed.
