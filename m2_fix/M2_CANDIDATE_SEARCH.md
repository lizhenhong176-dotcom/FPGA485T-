# CLB sink-pin candidate search

Source data:

- routing DB: `/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db`
- PIP templates: `/data/lzh/v7re/work/refs_20261021/routing/out_routing/templates`
- script: `/data/lzh/v7re/scripts/search_shared_imux.py`
- generated: `candidates.json`, `candidates_all.json`, `CANDIDATES.md`

The routing DB does not store one precomputed path per sink pin.  The script
joins three sources:

```
site pin  --template PIP-->  CLBLL_IMUXn
CLBLL_IMUXn --tileconn-->  INT_L/INT_R IMUX_Ln
INT IMUX wire --reverse template PIPs-->  common upstream wire
```

For each pair of pins on the **same LUT** it finds the deepest common upstream
wire and reports `branch_pips = (len(path_a)-1)+(len(path_b)-1)+2`.  The LUT
letter is part of the site-pin name (`SLICE_X8Y10/B3` belongs to `B6LUT`), so
A3/B3 is not treated as a same-LUT pair.

## Result

`candidates=144`; all have `branch_pips=4`.  The shortlist still contains only
a small set of logical patterns: same-letter `2->4`, `3->5`, plus a few
`1->6`, `2->3`, `4->5`, `4->6` patterns.  There is no large hidden family of
four-PIP pairs.

The known-good pair `A3->A5` is recovered with LCA `NR1END0`, which is exactly
the path observed in the accepted corpus.  This is a sanity check on the
search, not proof that every predicted pair will route that way.

## Counter-example: predicted 4 is not sufficient

`A2->A4` is also predicted as `branch=4` with LCA `NR1END1`, but the actual
Vivado route for A2/A4 has `pip_symdiff=9` (see
`data/m2/negative/A2_A4_A6_NEGATIVE.md`).  The router chooses a different
upstream branch; the graph contains a legal four-PIP path but does not force
Vivado to use it.  Therefore every candidate still needs a `route_design`
preflight and an actual `pips.txt` symdiff check before any bitstream build.

## B-side pin names

Vivado `get_site_pins -of_objects [get_sites SLICE_X8Y10]` confirms that
`B1..B6`, `C1..C6` and `D1..D6` are valid site pins on the slice.  The earlier
`invalid device pin 'B3'` error came from assigning B pins to an **A6LUT**
BEL.  The correct test is `BEL B6LUT` with `LOCK_PINS {I0:B3 I1:B1 ...}`.

## Current experiment

`data/m2/fam/clbll_l/b3` and `b5` use:

```
lut_a: SLICE_X8Y10 / A6LUT
lut_b: SLICE_X8Y11 / B6LUT
B3: I0:B3 I1:B1 I2:B2 I3:B4 I4:B5 I5:B6
B5: I0:B5 I1:B1 I2:B2 I3:B3 I4:B4 I5:B6
```

This is the same `NR1END0` topology as A3/A5 but a distinct logical
transition.  It must pass the normal `pip_symdiff <= 4` preflight before it is
added to `data/m2/pairs/`.

## Next order

1. Preflight B3/B5 `pips.txt`; only build bitstreams if the actual symdiff is 4.
2. If B3/B5 fails, do not keep cycling A2/A4/A6; move to a different sink type
   (FF D, carry, or another BEL) or accept the corpus as conditional.
3. Test the word-50/clock-region boundary at Y50/Y51.
4. Record every candidate's predicted LCA, actual pips, and actual symdiff next
   to the negative results so future searches do not repeat the A2/A4 mistake.
