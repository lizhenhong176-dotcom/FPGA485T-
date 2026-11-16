# S6 — FF / AOUTMUX-A5Q / AFFMUX / F8 / FF-type markers (2026-10-28)

Scope: BEL-bit next battlefield approved by user: FF CE/SR/CLK muxes, F8AMUX, FF types.
Anchor: SLICE_X10Y20 (CLBLM_R, SLICEM_X0 site), column base frame 31716, word 40/41 (w41 = parity), LUT INIT frames 31750/31751 w40/90.

## Verified laws (persisted in v7_law.sqlite / v7_verified, 38 rows)

| feature | bits (frame_off, w40) | evidence |
|---|---|---|
| AOUTMUX.O5  | {6,11}   | a_o5 (S5) |
| AOUTMUX.XOR | {8}      | b_xor (S5b) |
| AOUTMUX.CY  | {6,8}    | b_cy (S5b) |
| AOUTMUX.F7  | {6,7}    | a_f7 (S5) |
| AOUTMUX.O6  | ∅        | a_o6 — V7 deviation (artix7 has 30_11) |
| AOUTMUX.A5Q | ∅        | see e_both below — V7 deviation (artix7 has 30_07) |
| BOUTMUX.F8  | {22,23}  | d_f8: 4×LUT6+2×MUXF7+1×MUXF8, post-synth `foreach` LOC; = artix7 exact |
| AFFMUX.AX   | {1}      | d_ffx (port→D) |
| AFFMUX.O6   | {3}      | b_a5q (LUT O6→D) |
| AFFMUX.O5   | {0,3}    | d_fo5 (LUT6_2 O5→D) |
| AFFMUX.XOR  | {2}      | d_ffxor (CARRY4 O[0]→D) |
| AFF.ZRST    | {12} @off30 | FDRE/FDCE-family or LD latch → set; FDSE (set-family) → clear; Q-usage irrelevant |
| AFF.ZINI    | {3} @off31 | set ⇔ FDRE INIT=0 (sense INVERTED vs artix7 ZINI 31_03) |
| AFF FF marker | bit16 @ (0,41) | edge-FF (FDRE/FDSE) set; LD latch clear |
| LD latch bits | {0} @ (30,41) + {19} @ (1,41) | d_fdld; FDRE-family instead sets {3,7,9} @ (1,41) |

## e_both — the decisive A5Q experiment

Design: LUT6 (INIT 5555, A6LUT) O6→o1 AND FDRE (AFF, D=LUT O6, INIT=0) Q→o2, both LOC SLICE_X10Y20.
Result: places and routes OK. Bit diff vs a_o6 = FF-presence bits (27 @0w40; 25,26,29 @1w40; 16 @0w41), AFFMUX.O6={3}, ZRST={12}, ZINI={3}@31, and two INT routing bits (31718 w40{5}, 31720 w40{6}) for o2. **No AOUTMUX change.**

Conclusion: on V7, LUT O6 and FF.Q can drive two slice outputs simultaneously without any AOUTMUX encoding — the FF.Q exit needs no CLB bit (dedicated/default path, ppip-style). Decode rule: AOUTMUX=∅ + FF present with Q used → output source A5Q; otherwise O6. b_a5q vs d_ffx (Q used vs dangling) differ only in AFFMUX code + routing — no "Q used" bit exists; Q-usage is recovered from INT routing (the Q output net routes to a LOGIC_OUTS wire).

## Corrections to S5

- (30,40,12) is **AFF.ZRST** (reset-family FF/latch marker), NOT AOUTMUX.A5Q. The S5 report section claiming A5Q={12} was wrong; artix7 raw `SLICEM_X0.AFF.ZRST 30_12` confirms. v7_law.sqlite clb_cells A5Q rows restored to artix7 shape; V7 deviation (bit7 never observed) recorded in v7_verified.
- A5Q/ZRST "evidence" from s5c ZINI control: bit12 stable across FDRE INIT 0/1 — consistent with ZRST, since INIT only flips ZINI (31,40,3).

## Remaining unknowns

- CARRY4 CY0 family (ACY0 30_15, BCY0 1_15, CCY0 (30,41,16), DCY0 (30,41,17)): never set in any design incl. carry-chains; semantics need a dedicated probe (likely LUT-dual-output/DI-path related).
- CE/SR/CLK inversion muxes: d_ceinv/d_srinv/d_ckinv produce multi-bit w41 diffs, no clean single-bit law yet.
- AFFMUX F7/CY codes untested on V7 (kept from artix7).
- SLICEL_X1 shape (30_5/31_7/9/10 vs X0's 30_6-11): the site_cells tables show X0/X1 have DIFFERENT bit positions — X1 (right site of tile) measurements not yet done for S5/S6 laws. All current verifications are SLICEM_X0 (left site).

Files: remote /opt/lzh/step03/s5 (s5_e_both.*, s6_*.{py,sh,tcl}, s5_d_* designs); local step03_pip (s6_words.json, s6_col.json, s6_e.json).
