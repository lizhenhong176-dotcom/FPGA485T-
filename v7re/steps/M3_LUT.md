# M3 — CLB LUT6 INIT mapping (status)

Date: 2026-10-22
Remote: `lzh@172.17.71.129`, `/data/lzh/v7re/data/fasm_shell`
Part: `xc7vx485tffg1761-2`
Tile: `CLBLM_R_X7Y10`, site `SLICE_X10Y10` (`SLICEM_X0`)

## Done

- All four LUT6 BELs (`A6LUT`, `B6LUT`, `C6LUT`, `D6LUT`) have a complete
  64-bit INIT -> physical-bit mapping.
- `db/segbits_clblm_r.db`: 256 lines, 256 unique segbit positions.
- `valall_report.json`: six arbitrary INIT values per BEL, **24/24 PASS**.
- `bit2fasm` now emits `INIT[63:0]` for any value at this tile; one-bit
  A/B differential remains exactly `INIT[0]` vs `INIT[1]`.
- 209 other set bits in the A/B bitstreams remain unknown (routing / other
  tiles), as expected for a LUT-only database.

## Bit layout

```text
frame index base 31748 (FAR 0x004203a0), 4 frames, words 20..23
A6LUT 2_655 .. 1_640
B6LUT 2_671 .. 1_656
C6LUT 2_687 .. 1_672
D6LUT 2_703 .. 1_688
```

Each LUT occupies a consecutive 16-bit group; all four are disjoint.

## Second tile type: CLBLL_L / SLICEL

- t3 `SLICE_X8Y10` (`CLBLL_L_X6Y10`, frame base 31712, FAR `0x00420320`, word base 20)
- t4 `SLICE_X16Y303` (`CLBLL_L_X10Y303`, frame base 21364, FAR `0x00080520`, word base 6)
- A6LUT one-hot maps normalize to **0/64 differences**; the LUT6 layout is tile-type invariant, only the row word offset moves.
- `db/segbits_clbll_l_rel.db`: 256 word-relative lines; t3 `bits.offset=20`, t4 `bits.offset=6`, one decoder for both.
- Validation with one DB: t3 A/B/C/D 6/6 each, t4 A 6/6, **30/30 PASS**, all `unknown=0`.
- Evidence: `/data/lzh/v7re/data/fasm_shell/CLB_RESULT.md` addendum, `db/segbits_clbll_l_rel.db`, `valt_*`, `valsb_*`, `valsc_*`, `valsd_*`.

## Next

- FF (FF_INIT / FF_CONFIG), CARRY4, F7/F8, LUT O6 mux, site PIPs.
- Apply the word-relative + `bits.offset` pattern to every new CLB tile row.
- Then CLB -> BEL/FASM netlist for a routed DCP.

## Evidence

- `E:\v7work\m2\clb_shell\CLB_RESULT.md`
- `E:\v7work\m2\clb_shell\segbits_CLBLM_R.db`
- `E:\v7work\m2\clb_shell\valall_report.json`
- `E:\v7work\m2\clb_shell\segbits_build_report.json`
