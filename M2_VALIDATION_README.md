# M2 held-out validation

## CLBLL_L Y40 (target SLICE_X8Y41)

Model fitted from Y10/Y20/Y30:

```
word = 2 * target_row + (1 if target_row >= 25 else 0)
```

For target row 41 this predicts word 83. The pair `data/m2/validation/clbll_l_y40/a3`
and `.../a5` was built after that prediction.

Result:

- route: `CLBLL_IMUX1 -> CLBLL_LL_A3` vs `CLBLL_IMUX8 -> CLBLL_LL_A5`
- `pip_symdiff=4`
- diff frames: 31696,31699,31700,31701,31702,31703,31704,31705
- data bits: `(83,2),(83,3),(83,9)`

This matches the prediction exactly.

## CLBLL_L Y30 (target SLICE_X8Y31)

Observed `(63,2),(63,3),(63,9)`. The naive `2*row` model predicted word 62;
the corrected model (skip word 50 at row >= 25) predicts 63 and matches.

## Caveat

The word model has only been fitted inside one clock region (X0Y0) and one
tile family (CLBLL_L). It must be re-measured at the row-50 /
clock-region boundary and for CLBLM_L / CLBLM_R before it is used as a
general frame-word map.
