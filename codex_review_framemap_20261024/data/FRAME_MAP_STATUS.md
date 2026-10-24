# FRAME_MAP_STATUS — Phase A frame address map

**Date**: 2026-10-24
**Status**: COMPLETE (all 12 audit checks PASS)
**Codex review**: pending

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
values for the 28 overhead frames (2 per config row, 14 rows) **cannot be
recovered from the RapidWright public API**. `ConfigRow.getExtraFrameCount()`
exposes the frame count but the FAR of those positions is not stored in the
device data. `FAR.incrementFAR()` produces plausible sequential values, but
there is no independent confirmation channel: the bitstream does not embed
per-frame FAR writes, and Vivado's `report_property` on frames does not
expose the frame address.

**Schema decision**: store `far=NULL, frame_address_source='unresolved',
confidence='unresolved'` for all 28 overhead rows. The CSV also records
speculative sequential FAR values for reference, but these are NOT imported
into the DB.

## Table schema

```sql
CREATE TABLE IF NOT EXISTS frame_map (
    frame_index           INTEGER PRIMARY KEY,   -- 0..50175
    far                   INTEGER NULL,          -- NULL for 28 overhead rows
    frame_address_source  TEXT NOT NULL,         -- rapidwright-configarray | unresolved
    confidence            TEXT NOT NULL,         -- confirmed | unresolved
    tile_name             TEXT NULL,             -- NULL for all rows (Phase A scope)
    block_type            TEXT NULL,             -- FAR block type field [25:23]
    is_overhead           INTEGER NOT NULL DEFAULT 0
);
```

## Audit results (all PASS)

| # | Check | Result |
|---|---|---|
| 1 | Total rows = 50,176 | PASS |
| 2 | frame_index range [0, 50175] | PASS |
| 3 | Block frames with far IS NULL = 0 | PASS |
| 4 | Overhead frames with far NOT NULL = 0 | PASS |
| 5 | No overhead row has tile_name or block_type | PASS |
| 6 | frame_address_source values correct | PASS |
| 7 | confidence values correct | PASS |
| 8 | Overhead count = 28 | PASS |
| 9 | Block count = 50,148 | PASS |
| 10a | frame 31748 far = 0x004203A0 | PASS |
| 10b | frame 31750 far = 0x004203A2 | PASS |
| 11 | frame 31748 sha256 = 0441772f... | PASS (bitstream re-hash) |
| 12 | frame 31750 sha256 = d44f0364... | PASS (bitstream re-hash) |

Hash anchors were **re-run** (not cited from old conclusions) using
`E:\v7work\_curated_20261021\probe\SLICE_X10Y10\A6LUT\a.bit` parsed with the
project's `bitstream/frames.py` loader.

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

1. Codex high-model review of the generated frame_map (audit script + CSV +
   status doc).
2. Sync `frame_map` table + updated schema to remote
   `/data/lzh/v7re/work/refs_20261021/model/v7_model.sqlite`.
3. Phase B: `site_frames` — bind specific sites/BELs to frame/word/bit
   using the frame_map FAR addresses.
