# Phase A status: FAR / frame address layer

Date: 2026-10-22
Part: `xc7vx485tffg1761-2`
Bitstream sampled: `work/liccheck/top.bit` (20,273,538 bytes)

## Implemented

- `bitstream/far.py`
  - `FarAddress` dataclass with `decode()` / `encode()` / `to_dict()`.
  - 32-bit layout: minor `[6:0]`, column `[16:7]` (10 bits), row `[21:17]`,
    top/bottom `[22]`, block type `[25:23]`, reserved `[31:26]`.
  - Field-level only; no device tile map is implied.
- `scripts/audit_far.py`
  - Parses a `.bit`/`.bin`, reports sync offset, frame count, leftover words,
    every FDRI start and its tracked FAR, and decodes requested candidate FARs.
- `tests/test_far.py`
  - Literature base `0x00420400` -> block 0, top 1, row 1, col 8, minor 0.
  - `0x004203A0` -> block 0, top 1, row 1, col 7, minor 32.
  - Round-trip and field-range tests.
- Full test suite: 18 tests OK.

## Blocking discovery

`work/liccheck/top.bit` contains **one** FAR write, value `0x00000000`,
followed by a single 5,068,346-word FDRI payload. `parse_bit()` therefore returns:

```text
far_starts=[(0, 0)]
frames=50176 leftover=0
```

The packet stream does not carry a per-frame FAR. The existing `Bitstream.far_starts`
can only bind a FAR to an FDRI **start**, not to each 101-word frame. Consequently:

- `site_frames.far` cannot be filled from this bitstream by reading packet FARs.
- `frame_map` / `frame_words` cannot be populated from packet headers alone.
- Storing `frame_index` as payload order is valid, but it is not a FAR.

## Anchor validation

The plan's golden anchor is the **base** of the M3 four-frame group:
`frame 31748 / FAR 0x004203A0`. Direct inspection of
`data/fasm_shell/a.bit` and `b.bit` shows that frame 31748 is zero in both;
the only frame that differs between the two M3 variants is **31750**
(bits `(20,14)`, `(20,15)`, `(50,0)`, `(50,12)`).

Frame hashes validate both points:

```text
frame 31748  FAR 0x004203A0  sha256 = 0441772f66559a1c71f4559dc4405438fc9b8383ce1229139257a7fe6d7b8de9
frame 31750  FAR 0x004203A2  sha256 = d44f0364fa633f70021e4662b7da08ebd5c228c1d14e4982fdf1dd3ab209069e
```

For each point, Python `bitstream.frames.load_frames` and RapidWright
`Bitstream.readBitstream(...).configureArray().getFrame(FAR)` produced the
identical SHA-256. Therefore:

- `frame 31748 <-> 0x004203A0` (M3 group base) is confirmed;
- `frame 31750 <-> 0x004203A2` (the actual M3 difference) is confirmed.

The separate `0x00420400` value is a different frame (column 8, minor 0), not the
same base; it is not the M3 anchor.

Caveat: this validates the block-frame index mapping, not the FAR values of the
28 row-overhead frames. Those remain unresolved until an independent frame-address
table (not `ConfigArray`/`FAR.incrementFAR`) is available.


## Options

1. **Device frame map (recommended)** — obtain or derive a real 485T
   frame-address table (Vivado `frameData`, RapidWright/Project X-Ray device
   data), validate it on CLBLL/CLBLM/HCLK/INT at multiple rows and both halves,
   then map `frame_index -> far -> tile`.
2. **Frame-index-only Phase A** — add `frame_index` and `frame_address_source`
   fields, leave `far` NULL with an explicit `unresolved` status, and do not
   claim FAR coverage. This unblocks M3 import but not the FAR release criterion.

Recommendation: pursue option 1 before declaring Phase A complete; use option 2
only as an interim schema state so no experiment data is lost.

## RapidWright device data (option 1, in progress)

The full standalone jar and the 485T device database were obtained:

- `/data/lzh/tools/rapidwright-standalone.jar`
- `/data/lzh/tools/rapidwright-data/data/devices/virtex7/xc7vx485t_db.dat`
  (3,625,305 bytes, md5 `f22f180c1a803ef13e7022ff84c5d3ac`)
- `/data/lzh/tools/jdk-11.0.32.1+1`

The device loads as 365 rows x 412 columns and 150,380 tiles. `ConfigArray`
gives block/frame maps; e.g.:

```text
CLBLM_R_X7Y10  block CLB/CLBLM_RBOT(r=1,c=7)  base 0x00420380  36 frames
CLBLL_L_X6Y11  block CLB/CLBLL_LBOT(r=1,c=6)  base 0x00420310  36 frames
```

The 28-frame difference is explained by RapidWright row overhead:

- `ConfigArray.FRAME_OVERHEAD_COUNT_PER_ROW` is documented as
  "The number of extra frames at the end of a configuration row";
- `ConfigArray.getWordSize()` is 5,067,776 = 50,176 × 101, so the total size
  already includes the overhead;
- 14 config rows × 2 overhead = 28;
- 50,148 block frames + 28 = 50,176 bitstream frames.

Inserting two overhead frames after each row gives:

```text
total = 50,176
idx(0x00420380) = 31,716
idx(0x004203A0) = 31,748   # matches M3 frame 31748
```

The target block `CLBLM_R_X7Y10` is in the seventh config row; six preceding
rows contribute 6 × 2 = 12 overhead frames, exactly the earlier +12 shift from
31,736 to 31,748. This validates the **count and index**, but it does not prove
the overhead FAR values or any tile association.

## Codex closed-book review

Codex (high model) was given only the local javadoc excerpts and recorded API
outputs, with a no-network instruction. Verdict: **PARTIAL** (2026-10-22).

Confirmed:
- 50,176 − 50,148 = 28 = 14 × 2 is arithmetically exact;
- the javadoc wording supports "two extra frames at the end of each row";
- the insertion test reproduces 50,176 and places `0x004203A0` at 31,748;
- `word_size` is consistent with 50,176 frames × 101 words.

Not confirmed by the public API:
- that the overhead frames have `Frame` objects;
- that their FAR values are simply last block FAR + 1 / + 2;
- that they belong to any `Block` or tile;
- block types beyond `CLB` and `BRAM_CONTENT`;
- null/unconfigured frame export semantics.

Consequence: treat `frame_index -> FAR` as **block-frame index confirmed,
overhead FAR construction unverified**. The Codex high-model verdict is
**PARTIAL**, with the explicit schema decision:

- every payload position keeps `frame_index`;
- the 28 overhead positions get `far = NULL` and
  `frame_address_source = 'unresolved'`;
- any `last_block_far + 1 / + 2` hypothesis may exist only in a separate
  nullable candidate field (`confidence='inferred'`) and must not be used as a
  confirmed address or join key;
- no overhead frame is assigned to a tile, and Phase A must not claim complete
  FAR coverage.

Why the obvious candidate fails: `FAR.incrementFAR()` has no overhead-frame
state. A `RowBoundary` probe showed each configuration row's last block FAR
(e.g. `0x00004c9f`, `0x00424c9f`) is followed by a jump to the next row base
(`0x00020000`, `0x00800000`), not by `+1/+2`. `FAR.isLastFrameInRow()` is true at
those points, and the public `Frame`/`Block` model contains only the 50,148 block
frames. `ConfigArray`'s constructor already calls `createConfigArray()`, so
calling it again duplicates rows and invalidates any gap experiment; that also
explains the earlier 100,295-entry artifact.

## Next concrete checks

- M3 anchor validation is complete: frame 31748 / `0x004203A0` (group base)
  and frame 31750 / `0x004203A2` (actual difference) both have matching Python
  and RapidWright frame hashes.
- To settle the overhead FARs, obtain an independent 485T frame-address table
  (decoded Vivado `frameData`, documented Xilinx map, or a capture with FAR
  writes at each row boundary); then compare all 28 positions. Reusing
  `ConfigArray`, `FAR.incrementFAR`, or synthetic insertion cannot settle it.
- Populate `frame_map` with `frame_address_source` / `confidence` columns; only
  block frames may use confirmed FARs. Keep overhead `far` NULL.
