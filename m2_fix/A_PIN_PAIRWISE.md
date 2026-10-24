# A-pin pairwise validation

This is a zero-build validation: it compares the `pips.txt` of the six
existing A-pin experiments under `data/m2/fam/clbll_l/pin_a*`.

```
       A1  A2  A3  A4  A5  A6
A1      -  10   7   6   7  10
A2          -   9  10   9   6
A3              -   7   4   9
A4                  -   7  10
A5                      -   9
A6                          -
```

Only **A3/A5 = 4** passes the `pip_symdiff <= 4` criterion.  The next closest
pair is A1/A4 = 6.  A2/A4 is 10, not the 4 predicted by the routing graph.

This confirms, with real routed PIPs rather than graph predictions, that:

- the routing graph's `branch_pips=4` is necessary but not sufficient;
- there is no second usable A-pin pair in this geometry;
- B-side is separately blocked by `LOCK_PINS` (see
  `data/m2/negative/B3_B5_NEGATIVE.md`).

Do not add A1/A4, A2/A3, A2/A6 or A4/A5 to `data/m2/pairs/`; they all fail the
existing gate.
