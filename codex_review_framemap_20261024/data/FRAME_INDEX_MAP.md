# V485T frame index -> FAR map

## Verdict on `xc7vx485t.frameData`

`xc7vx485t.frameData` is part of Vivado 2017.2 `devint` device data
(`data/parts/xilinx/virtex7/devint/virtex7/xc7vx485t/`), paired with
`xc7vx485t.tile2bfd`. It is **not** a FAR/overhead address table.

Parsed structure:

- offset 0: `uint32 2365` protobuf-like block records, ending at offset 83317.
- offset 83317: `uint32 150380` (tile count).
- offset 83321: `uint32 130283`.
- offset 83325: `113220` length-prefixed protobuf tile records to EOF (2,904,640).

The 2365 records carry block/frame-data descriptors (block type, row,
column, frame range, bit range); the 113220 records map tile IDs to those
descriptors. No direct FAR values (`0x4203a0`, `0x420320`, frame index
31748/31712) occur in the file. Therefore frameData does not supply the
28 overhead FARs.

## Actual frame map

RapidWright `ConfigArray` gives 14 config rows, 1183 blocks and 50,148
block frames. The bitstream has 50,176 configuration frames. The missing
28 frames are **2 overhead frames at the end of each config row**:

```
frame_index = 0
for row in ConfigArray.getConfigRows():
    for block in row.getBlocks():
        for i in range(block.getFrameCount()):
            far = block.getAddress() + i
            frame_index += 1
    last = row.getBlocks()[-1]
    for k in (1, 2):
        far = last.getAddress() + last.getFrameCount() - 1 + k
        # kind = overhead
        frame_index += 1
```

The overhead FAR is the two addresses immediately after the last block of
the row (inside the row gap). Total = 50,176.

## Validation against independently measured anchors

| frame_index | derived FAR | expected | source |
|---:|---|---|---|
| 274 | `0x3a2` | `0x3a2` | X10Y130 group base 0x3a0 + 2 |
| 5520 | `0x203a2` | `0x203a2` | X10Y160 group base 0x203a0 + 2 |
| 21364 | `0x80520` | `0x80520` | CLBLL_L_X10Y303 base |
| 31712 | `0x420320` | `0x420320` | CLBLL_L_X6Y10 base |
| 31748 | `0x4203a0` | `0x4203a0` | CLBLM_R_X7Y10 base |
| 31750 | `0x4203a2` | `0x4203a2` | A6LUT INIT[0] anchor |

All six anchors match exactly. Example overhead rows:

```
5244,0x4ca0,1,0x4c80,overhead
5245,0x4ca1,1,0x4c80,overhead
5246,0x20000,2,0x20000,block
10490,0x24ca0,2,0x24c80,overhead
10491,0x24ca1,2,0x24c80,overhead
```

## Reproducibility and expected-run table (v5)

The full dump is reproducible: running `DumpFrameIndex.java` against
RapidWright **2026.1.0** re-emits `frame_index_far.csv` byte-identical
(sha256 `77A4655FB8C327DB7CE7C8B9FE63D6A08AB6512EA07CAF0D0401258FBFDD0A46`).

`DumpExpectedRuns.java` (same environment) enumerates the same ConfigArray
and emits `expected_runs.csv`: the exact per-run table with 1,183 entries
`run_id,start_frame_index,length,row,block_addr,block_type`. This is the
independent expected-run table used by `scripts/import_frame_map.py`
(check 15) to detect aligned run relocation/reassignment, which satisfies
every aggregate invariant (grid alignment, region uniqueness, run count,
length multiset, per-row counts).

Derived aggregates (recorded for cross-checking): run length multiset
{36:777, 28:245, 128:105, 30:28, 32:14, 42:14}; per-row block-frame
counts rows 1-7: 5,244 each, rows 8-14: 1,920 each.

### Pinned reproduction inputs (v6)

| Input | Version / checksum | Fetchable from |
|---|---|---|
| RapidWright standalone jar | `rapidwright-2026.1.0-standalone-lin64.jar`, sha256 `18F81833595EF8A5191A72F9431727E17602DE2FE4DDDBBA2D281358801A1FC9` | RapidWright release v2026.1.0 (github.com/Xilinx/RapidWright/releases) |
| Device data | `xc7vx485t_db.dat`, sha256 `53E16B36FE546BEA33E403B101427FD5A33481189FEA3B1D631344A25551F5C6` | RapidWright on-demand device download, installed at `~/.local/share/RapidWright/data/devices/virtex7/` |
| JDK | 17.0.8 (javac 17) | any JDK 17 |
| Anchor bitstream | `a.bit`, sha256 `F3F50BD637D26A25AEB8BF39EC9C8CB9EE2C69E820667CEA0F6ED658C929C6E7` | project experiment corpus (also bundled as `data/a_bitstream.bit`) |

Exact generator commands (run from the directory containing the .java
files, with the device data at the path above):

```
java -cp rapidwright-2026.1.0-standalone-lin64.jar;. DumpFrameIndex frame_index_far.csv
java -cp rapidwright-2026.1.0-standalone-lin64.jar;. DumpExpectedRuns expected_runs.csv
```

## Artifacts

- `phaseA/FrameIndexMap.java` - anchor lookup
- `phaseA/DumpFrameIndex.java` - full dump generator (reproducible)
- `phaseA/DumpExpectedRuns.java` - expected-run table generator
- `phaseA/frame_index_far.csv` - 50,176 rows:
  `frame_index,far,row,block_addr,kind`
- `phaseA/expected_runs.csv` - 1,183 runs (exact expected-run table)
- `phaseA/rw_frames_a3b.txt` - raw enumeration output with per-frame
  sha256 (a3/b bitstreams, 50,148 lines)
- `phaseA/FRAME_INDEX_MAP.md` - this note
