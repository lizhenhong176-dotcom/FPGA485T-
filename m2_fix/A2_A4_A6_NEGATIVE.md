# Negative result: A2 / A4 / A6 are not MCD-compatible

Goal: find a non-`A3->A5` logical transition for the `CLBLL_L` two-LUT design,
using the same source/sink geometry (`SLICE_X8Y10` -> `SLICE_X8Y11`, A6LUT).

All three candidates built successfully (`design.bit`, 20,273,538 bytes), but
their routes are not minimal controlled differences against the existing A3
route.

Base A3 route (4 pips):

```
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12
INT_L_X6Y10/INT_L.LOGIC_OUTS_L12->>NR1BEG0
INT_L_X6Y11/INT_L.NR1END0->>IMUX_L1
CLBLL_L_X6Y11/CLBLL_L.CLBLL_IMUX1->CLBLL_LL_A3
```

## A2

```
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_A->>CLBLL_LL_AMUX
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_AMUX->CLBLL_LOGIC_OUTS20
INT_L_X6Y10/INT_L.LOGIC_OUTS_L20->>NL1BEG1
INT_L_X6Y11/INT_L.NL1END1->>IMUX_L2
CLBLL_L_X6Y11/CLBLL_L.CLBLL_IMUX2->CLBLL_LL_A2
```

Symdiff against A3: **9** (no shared pips). Reject.

## A4

```
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12
INT_L_X6Y10/INT_L.LOGIC_OUTS_L12->>NL1BEG_N3
INT_L_X6Y10/INT_L.NL1BEG_N3->>NL1BEG2
INT_L_X6Y11/INT_L.NL1END2->>IMUX_L11
CLBLL_L_X6Y11/CLBLL_L.CLBLL_IMUX11->CLBLL_LL_A4
```

Symdiff against A3: **7** (only the first `CLBLL_LL_A`/`OUTS12` edge is shared).
Reject.

## A6

```
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_A->>CLBLL_LL_AMUX
CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_AMUX->CLBLL_LOGIC_OUTS20
INT_L_X6Y10/INT_L.LOGIC_OUTS_L20->>NR1BEG2
INT_L_X6Y11/INT_L.NR1END2->>IMUX_L4
CLBLL_L_X6Y11/CLBLL_L.CLBLL_IMUX4->CLBLL_LL_A6
```

Symdiff against A3: **9** (no shared pips). Reject.

## B-side attempt

`B3`/`B5` on the A6LUT are invalid device pins:

```
CRITICAL WARNING: [Vivado 12-2497] Could not set property 'LOCK_PINS'
because 'invalid device pin 'B3''.
```

`B6LUT` with `B1/B3/B5` also failed:

```
CRITICAL WARNING: [Vivado 12-2497] Could not set property 'LOCK_PINS'
because 'invalid device pin 'B1''.
```

The resulting builds fell back to A2 and are not usable evidence; keep them
only as failed-attempt records, not in `data/m2/pairs/`.

## Conclusion

`A3->A5` is special in this geometry: it is the only pair observed so far
where both pins share the same upstream `NR1END0` and differ only at the final
`IMUX_L1/L8` + site PIP. A2/A4/A6 each take a different upstream branch, so
adding one of them would not satisfy the MCD contract.

A non-`A3->A5` transition must come from a different topology: a different
source pin/BEL, a different sink site, or a routing pattern where two input
pins share an upstream path. Do not weaken `pip_symdiff <= 4` just to get
transition diversity.
