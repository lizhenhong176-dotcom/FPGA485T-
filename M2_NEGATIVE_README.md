# Negative M2 evidence: A1 vs A3

`data/m2/fam/clbll_l/pin_a1` and `data/m2/fam/clblm_l/pin_a1` are A1 variants
of the two-LUT OR design.

Compared with the accepted A3 variants, A1 routes through a different upstream
INT path:

- A1: `LOGIC_OUTS_L12 -> NL1BEG_N3 -> NR1BEG3 -> IMUX_L7 -> ..._A1`
- A3: `LOGIC_OUTS_L12 -> NR1BEG0 -> NR1END0 -> IMUX_L1 -> ..._A3`

The route symmetric difference is 7 edges, and the bit difference is 16 data
bits. This violates the M2 MCD contract (`pip_symdiff <= 4`) and is not a valid
pair. It is kept only as evidence that A1 does not share the A3/A5 trunk.

Do not add these directories to `data/m2/pairs/`.
