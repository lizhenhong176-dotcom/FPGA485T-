# FRAME_MAP_STATUS — Phase A frame address map

**Date**: 2026-10-24 (v2, post Codex review fixes)
**Status**: COMPLETE (all checks PASS in v2 import script)
**Codex review**: v1 verdict CONDITIONAL_PASS → v2 fixes applied; re-review pending

## What was built

`frame_map` table in the model DB (`v7_model.sqlite`): 50,176 rows mapping
bitstream payload index (0..50175) to FAR (frame address register) values.

| Metric | Value |
|---|---|
| Total rows | 50,176 |
| Block frames (far confirmed) | 50,148 |
| Overhead frames (far NULL) | 28 |
| frame_index range | [0, 50175], unique, continuous |
| Source (block frames) | `rapidwright-configarray` |
| Source (overhead) | `unresolved` |
| Confidence (block frames) | `confirmed` |
| Confidence (overhead) | `unresolved` |

## FAR resolution for the 28 overhead frames

Per the Codex high-model review (verdict: PARTIAL, report at
`codex_review_overhead_20261022/CODEX_OVERHEAD_VERDICT.md`), the exact FAR
values for the 28 overhead frames (2 per config row, 14 rows) **are not
recoverable via the RapidWright public API as currently documented**.
`ConfigRow.getExtraFrameCount()` exposes the frame count but the FAR of those
positions is not stored in the device data. `FAR.incrementFAR()` produces
plausible sequential values, but there is no independent confirmation channel
within the current toolset: the bitstream does not embed per-frame FAR
writes, and Vivado's `report_property` on frames does not expose the frame
address. This is a limitation of the available evidence, not a proven
impossibility — a future channel (e.g. an ICAP readback capture or a
prjxray-style frame-map for a 7-series part) could still resolve them.

**Schema decision**: store `far=NULL, frame_address_source='unresolved',
confidence='unresolved'` for all 28 overhead rows. The CSV also records
speculative sequential FAR values for reference, but these are NOT imported
into the DB.

## Table schema (v2, with CHECK constraints)

```sql
CREATE TABLE IF NOT EXISTS frame_map (
    frame_index           INTEGER PRIMARY KEY      -- 0..50175
        CHECK (frame_index >= 0 AND frame_index <= 50175),
    far                   INTEGER NULL,            -- NULL for 28 overhead rows
    frame_address_source  TEXT NOT NULL
        CHECK (frame_address_source IN ('rapidwright-configarray', 'unresolved')),
    confidence            TEXT NOT NULL
        CHECK (confidence IN ('confirmed', 'unresolved')),
    tile_name             TEXT NULL,               -- NULL for all rows (Phase A scope)
    block_type            TEXT NULL,               -- FAR block type field [25:23]
    is_overhead           INTEGER NOT NULL DEFAULT 0
        CHECK (is_overhead IN (0, 1))
);
```

## Audit results (v2 import script, all PASS)

The v2 script performs, in order: (1) full CSV field validation with
row-numbered errors BEFORE any DB access; (2) bitstream hash-anchor
verification BEFORE the DB write (abort on mismatch); (3) transactional
insert (BEGIN → CREATE (with CHECK constraints) → DELETE → INSERT →
post-count check → COMMIT, rollback on any error); (4) read-only DB audits.

| # | Check | Result |
|---|---|---|
| 1 | CSV header columns exact | PASS |
| 2 | CSV per-row field validity (5,176 rows parsed clean) | PASS |
| 3 | frame_index 0..50175 unique continuous | PASS |
| 4 | 14 config rows, overhead at each row end (last 2 entries) | PASS |
| 5 | FAR uniqueness among block frames | PASS |
| 6 | Block continuity (block_addr + offset == far, no intra-block jumps) | PASS |
| 7 | Bitstream hash anchors 31748/31750 re-computed | PASS |
| 8 | DB total rows = 50,176 | PASS |
| 9 | Block/overhead counts 50,148/28 | PASS |
| 10 | NULL/provenance/overhead invariants (5.4–5.8) | PASS |
| 11 | Duplicate FARs = 0 | PASS |
| 12 | frame_index range [0,50175] | PASS |
| 13 | FAR anchors 0x004203A0 / 0x004203A2 | PASS |
| 14 | Overhead at all 14 row ends (post-insert DB check) | PASS |

Hash anchors were **re-run** (not cited from old conclusions) using
`E:\v7work\_curated_20261021\probe\SLICE_X10Y10\A6LUT\a.bit` parsed with the
project's `bitstream/frames.py` loader, and the check runs BEFORE the DB
write so a mismatch aborts the import.

**Audit scope note**: these audits verify structural integrity, ordering,
uniqueness, provenance consistency, and two hash anchors plus 6 prior
independent anchor validations (see `phaseA/FRAME_INDEX_MAP.md`). They do
NOT independently re-derive every one of the 50,148 FARs from a second
source — that would require a second independent frame-map source, which
is not currently available.

## Source artifacts

| Artifact | Path |
|---|---|
| Validated CSV (50,176 rows) | `phaseA/frame_index_far.csv` |
| Java dump generator | `phaseA/DumpFrameIndex.java` |
| Java anchor validator | `phaseA/FrameIndexMap.java` |
| Import + audit script | `v7re/scripts/import_frame_map.py` |
| Schema (frame_map added) | `v7re/db/schema_model.sql` |
| This status doc | `v7re/steps/FRAME_MAP_STATUS.md` |

## How frame_map was generated

RapidWright `ConfigArray` on `xc7vx485t` enumerates 14 config rows →
1,183 blocks → 50,148 frames, each with a confirmed FAR. The bitstream has
50,176 configuration frames. The 28-frame difference is 2 overhead frames
at the end of each of the 14 config rows. The payload order is:

```
frame_index = 0
for row in ConfigArray.getConfigRows():       # 14 rows
    for block in row.getBlocks():             # in row order
        for i in range(block.getFrameCount()):
            far = block.getAddress() + i      # confirmed FAR
            frame_index += 1
    # 2 overhead positions (far=NULL in DB)
    frame_index += 2
```

Validated against 6 independent anchors (see `phaseA/FRAME_INDEX_MAP.md`):
indices 274, 5520, 21364, 31712, 31748, 31750 all match exactly.

## Next steps

1. Codex re-review of the v2 import script + updated status doc (target:
   upgrade CONDITIONAL_PASS → PASS).
2. Sync `frame_map` table + updated schema to remote
   `/data/lzh/v7re/work/refs_20261021/model/v7_model.sqlite` (blocked on
   SSH key recovery).
3. Phase B: `site_frames` — bind specific sites/BELs to frame/word/bit
   using the frame_map FAR addresses.
