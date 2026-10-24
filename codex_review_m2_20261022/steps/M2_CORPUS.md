# M2 corpus status (2026-10-22)

`scripts/check_m2_gate.py` now reports:

```
pairs=5 families=3 valid=5 failed=0
M2 GATE PASS
```

## Pairs

| id | tile family | site(s) | route change | frames | data bits (word,bit) |
|---|---|---|---|---|---|
| m2_mcd_0001 | CLBLM_R | SLICE_X7Y10 -> X7Y11 | A3 -> A5 | 31732,31735-31741 | (22,2),(22,3),(22,9) |
| m2_mcd_0002 | CLBLL_L | SLICE_X8Y10 -> X8Y11 | A3 -> A5 | 31696,31699-31705 | (22,2),(22,3),(22,9) |
| m2_mcd_0003 | CLBLM_L (SLICEM) | SLICE_X28Y40 -> X28Y41 | A3 -> A5 | 32112,32115-32121 | (83,2),(83,3),(83,9) |
| m2_mcd_0004 | CLBLL_L | SLICE_X8Y20 -> X8Y21 | A3 -> A5 | 31696,31699-31705 | (42,2),(42,3),(42,9) |
| m2_mcd_0005 | CLBLM_L (SLICEL) | SLICE_X29Y40 -> X29Y41 | A3 -> A5 | 32112,32115-32121 | (83,1),(83,10),(83,11) |

Every pair has `pip_substitutions=2` and `pip_symdiff=4`: one
`NR1END0->IMUX_Lx` substitution plus one site-PIP substitution. Word 50 is
excluded as ECC/aux.

## What the corpus already shows

- The three-bit difference is stable in **bit position** within a family/row
  pattern: CLBLL_L at Y10/Y20/Y30/Y40 all use bits 2,3,9 of their word.
- **Frame-word model:** for the CLBLL_L destination slice, the data word is

  ```
  word = 2 * target_row + (1 if target_row >= 25 else 0)
  ```

  This fits the measured Y11 -> 22, Y21 -> 42, Y31 -> 63 and Y41 -> 83.
  The +1 is consistent with skipping the reserved word 50 (ECC/aux); the exact
  behavior at the row-50/clock-region boundary still needs a test.
- CLBLM_L at SLICE_X28 (SLICEM) uses bits 2,3,9 of word 83; CLBLM_L at
  SLICE_X29 (SLICEL) uses bits 1,10,11 of word 83. Site type changes the bit
  encoding even though the tile family is the same.
- `m2_mcd_0002` was rerun for both A3 and A5; `design_run1.bit` vs the rebuilt
  `design.bit` had zero differing frames, confirming reproducibility. (.bit
  headers contain timestamps, so compare frames, not whole-file hashes.)

## Held-out validation

`data/m2/validation/clbll_l_y40` (SLICE_X8Y40 -> X8Y41, A3 -> A5) was built
after the model above. Predicted data bits were `(83,2),(83,3),(83,9)`.
Observed exactly those bits, with the same 8 diff frames and `pip_symdiff=4`.
`data/m2/validation/clbll_l_y30` (target row 31) observed `(63,2),(63,3),(63,9)`,
also matching the model. This is the first held-out replay success for the
site-PIP three-bit pattern and the word index.

## Negative result: A1 -> A3

A1 and A3 do **not** share the same upstream INT route. A1 uses
`LOGIC_OUTS_L12 -> NL1BEG_N3 -> NR1BEG3 -> IMUX_L7`, while A3 uses
`LOGIC_OUTS_L12 -> NR1BEG0 -> NR1END0 -> IMUX_L1`. The symmetric difference is
7 edges, not 4, and it changes 16 data bits. These pairs fail the MCD contract
and are not in `pairs/`. The A1 variants are kept under
`data/m2/fam/clbll_l/pin_a1` and `data/m2/fam/clblm_l/pin_a1` as negative
evidence.

## Next

1. Test the word map at the row-50 / clock-region boundary (Y50/Y51).
2. Add A2/A4/A6 changes to see whether they share the `NR1END0` path.
3. Separate the INT-mux bit from the site-PIP bit (linear incidence over the
   corpus; a clean one-PIP pair is impossible on this fabric).
4. Extend held-out replay to a different tile family and to a second pin
   transition before any bit-flipping experiment.
