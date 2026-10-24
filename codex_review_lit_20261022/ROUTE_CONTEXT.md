# Current route context for review

## Target and environment

- Target: Xilinx Virtex-7 `xc7vx485tffg1761-2` (VC707-class), Vivado 2017.2 on Ubuntu 18.04.
- Final target: build `tilegrid.json`, `tile_type_*.json`, `segbits_*.db`, `ppips_*.db`,
  FAR/frame map, and finally FASM/bitstream round-trip.
- Topology/reference is complete for site->tile, tile types, wires and PIPs:
  `/data/lzh/v7re/work/refs_20261021/topology` and
  `/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db`.
- `v7_routing.db` has `tiles=150380`, `tile_types=115`, `conn_rules=36547`,
  `tileconn=804680`, `edges_exact=39,923,710`, but no per-sink path table.
  Paths must be composed from tile templates + `tileconn`, then verified by Vivado.

## What is already proven

- A minimal 7-series design builds reproducibly: 50,176 frames x 101 words x 32 bits.
- M2 corpus has 6 valid pairs / 3 families / 2 logical input transitions:
  A3->A5 and B3->B5, all on 4-PIP minimal routes, `pip_symdiff=4`.
- Gate (`check_m2_gate.py`) recomputes frame diffs, data bits, aux bits and frame
  hashes; `M2 GATE PASS`. It is a data-integrity gate, not a full SEMANTICS proof.
- LUT6 INIT is single-bit controllable; one INIT bit changes exactly one data bit
  `(22,15)` in frame 31712 and 7 bits in word 50.
- A3/A5 frame word follows `word = 2*(target_row % 50) + (1 if target_row%50 >= 25)`.
  Y51=2, Y125=51. This is a row-50 wrap, not a clock-region reset.
- Word 50 is NOT invariant metadata: it changes when LUT INIT changes and when
  routing changes. It is plausibly ECC/data-adjacent, but the mechanism is unproven.
- B3/B5 initially failed because `LOCK_PINS` uses BEL pin names. On `B6LUT`, the
  legal names are `A1..A6`; with those, B3/B5 route and validate.

## What is not solved

- `frame_map` / `frame_words` / `site_bits` / `pip_bits` are still empty in the DB.
  The parser currently discards FAR; frame indices are empirical.
- No full `segbits_*.db` for LUT/FF/CARRY/INT; only one LUT6 anchor + A-pin matrix.
- No site/BEL pin tables; `db/v7.sqlite sites.tile` is empty.
- STEP03 (PIP semantics) and STEP04 (frame-bit DB) are not started as databases.
- The M2 evidence is LUT-input only; no FF D/CE/SR, CARRY4, IOI or BRAM/DSP.
- There is no netlist-level reverse-consistency verification yet.
- Route search from `v7_routing.db` produced 144 graph-plausible pairs, but graph
  reachability is not sufficient: A2/A4 predicted 4, actual 10; only preflight
  `route_design` is trusted. No second family beyond CLBLL/CLBLM was validated.

## Questions for the reviewer

1. Given the five theses, which parts of this route are already aligned and which
   are methodologically weak?
2. Should the next step be (a) analytical FAR/frame map, (b) batch fuzzing with a
   design matrix / Tikhonov control-bit solve, (c) FF/CARRY sink experiments, or
   (d) netlist-level verification? Give an order and justify it.
3. Where does pairwise XOR stop being valid (control-bit reuse, unary multi-value
   PLP, pseudo-PIP/hint), and what is the minimum change to handle it?
4. Is the current "one transition + one anchor" evidence enough for STEP04, or is
   a coverage matrix required first?
5. What should be explicitly recorded as negative/uncertain so later work does not
   overclaim?
