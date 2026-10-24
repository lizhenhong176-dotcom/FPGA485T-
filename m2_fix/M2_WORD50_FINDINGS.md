## Word-index / word-50 update (2026-10-22)

These results supersede the earlier interpretation that Y51 was a clock-region
word reset.

### Row-50 periodicity, not a clock-region reset

The A3/A5 transition was re-run at two further boundaries:

| target | diff frames | changed data bits |
|---|---|---|
| `SLICE_X8Y51` (Y51) | 26450, 26453-26459 | `(2,2) (2,3) (2,9)` |
| `SLICE_X8Y125` (Y125) | 220, 223-229 | `(51,2) (51,3) (51,9)` |

Both pairs use the same 4-PIP route topology (`A -> LOGIC_OUTS12 -> NR1BEG0 ->
NR1END0 -> IMUX_L1/L8`) and the same `LUT6_2` `INIT=...FFFE` design.

The observed data word is:

```
word = 2 * (target_row % 50) + (1 if target_row % 50 >= 25 else 0)
```

This fits all measured rows: Y11->22, Y21->42, Y31->63, Y41->83, Y51->2,
Y99->83, Y125->51. It is a row-50 wrap, not evidence that clock regions reset
the word index. Y51/Y125 are validation-only boundary observations; they are
not six-pair M2 corpus members.

### X144 is not an MCD pair

`CLBLM_R` at X144/Y100 was attempted but A3 and A5 do not share the required
upstream: A3 routes via `NN2BEG0/SR1BEG_S0`, A5 via `NR1BEG0/BRKH`. The
`pip_symdiff` is >4. Recorded only as a negative; do not add it to `pairs/`.

### Word 50 follows a LUT INIT change

Three builds at the same `SLICE_X8Y10/A6LUT` source, `SLICE_X8Y11/B6LUT` sink,
A3 route and identical constraints:

- `base1` and `base2` have identical frame hashes
  (`8c3faa90...2fa22e`), i.e. reproducible bitstreams.
- `perturb` changes exactly one INIT bit (`64'hFFFFFFFFFFFFFFFE` ->
  `64'hFFFFFFFFFFFFFFFF` at the second INIT assignment).
- `base1` vs `perturb`: one differing frame `31712`; data bit
  `(22,15)`; word-50 bits `(50,0) (50,1) (50,2) (50,3) (50,9) (50,10) (50,12)`.
- Both routes are the same A3 4-PIP route.

Thus word 50 is not invariant metadata of the route. It changes when a LUT
configuration bit changes, consistent with data/ECC or other frame payload
metadata. It must not be described as simply "ECC/auxiliary, unrelated to
data" without this qualification.
