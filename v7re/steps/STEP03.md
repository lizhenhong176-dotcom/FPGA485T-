# STEP03 — PIP → bit mapping (fuzzing)

Status: **not started**. Skeleton only; the probe toolkit under `v7re/vivado/`
and `scripts/sweep_lut.py` is reusable.

## Target families, cheapest first

| family | probe | expected diff |
|---|---|---|
| `INT_L/R` local PIPs (`*BEG* -> *END*` short wires) | one routed net through a named PIP, two INIT-identical designs differing only in routing | small, local |
| `CLB` site-internal routing (F7/F8MUX, carry chain) | LUT pair + MUX select | inside CLB frames |
| `IOI` input/output delay + buffer | IOB design | I/O column frames |
| `BRAM`/`DSP` routing | instantiate one primitive, vary placement | block frames |

## Method (per PIP family)

1. Build a design that forces exactly one PIP of the family, freeze DCP
   (`v7re/vivado/probe.py` already does this for LUT probes).
2. Re-run place/route with the PIP enabled vs disabled; diff frames
   (`v7re/bitstream/frames.py`).
3. Record `(tile, wire_start, wire_end) -> [(frame, word, bit), ...]`.
4. Replay: enable the PIP in a fresh design, regenerate the bitstream, confirm
   the predicted bits flip and nothing else does.

## Acceptance

* every mapped PIP has at least two independent measurements (same result);
* replay check on a held-out design passes;
* unmapped PIPs are listed explicitly (never silently missing).
