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

## Anchor inconsistency to resolve

The approved plan recorded "frame 31748 / FAR 0x004203A0" and separately used
`0x00420400` as the CLBLM_L_X8Y0 base. The codec shows these are different frames:

- `0x004203A0`: block 0, top 1, row 1, **column 7**, minor 32
- `0x00420400`: block 0, top 1, row 1, **column 8**, minor 0

They cannot both describe the same tile/base. The `0x004203A0` association with
frame 31748 is also unverified: there is no per-frame FAR in the bitstream.
Do not write either value into the model DB as a verified tile address until a
device frame map or an independent Tcl/RapidWright source confirms it.

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

However, the ordering does **not** yet match the bitstream:

- bitstream: 50,176 frames
- RapidWright `ConfigArray` sequence: 50,148 frames
- difference: 28 frames

The M2 anchor is consistent with a +12 frame offset: bitstream frame 31700
hashes to RapidWright frame 0x00420314 (index 31688) in
`work/refs_20261021/.../pin_a3/design.bit`. A uniform insertion of one dummy
frame after every 30-frame block makes the total 50,176 but moves the anchor to
31760, so that insertion rule is wrong. The 28 frames are not all at the end
and are not all 30-frame CMT blocks.

Consequence: `frame_map`/`site_frames` cannot be written yet. The next step is
to identify the exact 28 frame positions, then validate M3 frame 31748 against
`0x004203A0` and populate Phase A.

## Next concrete checks

- Verify whether Vivado 2017.2 `frameData` exposes a frame-address table.
- Check RapidWright 2026.1 for a 485T frame-address API.
- If neither yields a table, build a small **known-tile** experiment and use the
  literature frame-base/offset model to fit one anchor per column, then validate
  against a second tile and both top/bottom halves.
