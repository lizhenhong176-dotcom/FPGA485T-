# M2 - PIP / route semantics

Status: **gate revised 2026-10-22**. Exact single-PIP differential is not required
because Vivado 2017.2 cannot produce it on this fabric.

## Why the old gate was retired

Original gate: two bitstreams differing by exactly one PIP.

Evidence collected on `xc7vx485tffg1761-2`:

- PIP objects have no `IS_ENABLED` property.
- `IS_EXCLUDED_PIP` and `IS_TEST_PIP` are read-only.
- `set_property ROUTE` requires a complete legal wire path; removing one node is rejected.
- Full scan of the 115 routing tile templates (35,126 PIP definitions) found
  **0 parallel PIP pairs**: no `(source wire, sink wire)` pair is served by two
  different PIPs.

Therefore a one-PIP alternative route cannot be requested through normal Vivado
routing, and the old gate is retired.

## Revised gate: minimal controlled difference (MCD)

A pair qualifies when all of the following hold:

1. Both designs are identical except **one site input pin** (or one BEL pin).
2. The route change is at most **2 PIP substitutions**:
   one INT mux PIP and/or one site PIP. `pip_symdiff <= 4` edges is allowed.
3. At least one non-auxiliary data bit differs; word 50 (ECC/aux) is excluded.
4. The bit difference is reproducible on a rerun.
5. The diff is classified into INT-mux substitution vs site-PIP substitution.

Corpus acceptance:

- at least **5 MCD pairs**;
- at least **3 tile families**;
- every pair has `pip_substitutions <= 2`, `pip_symdiff <= 4`, and >=1 data bit;
- replay on held-out routes must reproduce the recorded data bits.

`scripts/check_m2_gate.py` validates a `pairs/` directory against this contract.
It reports progress and exits non-zero until the corpus is complete.

## First accepted sample: `m2_mcd_0001`

`pin_a3` vs `pin_a5`, same two-LUT OR design, only LUT B input changes A3 -> A5.

- 2 PIP substitutions (4 edges in symmetric difference); INT mux and site PIP are coupled because each A1..A6 pin has exactly one site PIP
  - INT mux: `INT_R_X7Y11/INT_R.NR1END0->>IMUX1` vs `...->>IMUX8`
  - site PIP: `CLBLM_R_X7Y11/CLBLM_R.CLBLM_IMUX1->CLBLM_M_A3` vs `...IMUX8->CLBLM_M_A5`
- 8 diff frames: 31732,31735,31736,31737,31738,31739,31740,31741
- 3 non-aux data bits, all in word 22: `(22,2)`, `(22,3)`, `(22,9)`
- word 50 bits are ECC/aux and excluded.

Machine-readable record: `data/m2/pairs/m2_mcd_0001.json`.

## Next corpus expansion

Vary one input at a time across A1..A6, then LUT C/D inputs, then slices and
tile families. For each pair record the actual `pips.txt` route, the diff frames,
the non-aux bits, and whether the change is INT mux, site PIP, or both.

Do not flip candidate bits in a bitstream until the corpus separates INT-mux
bits from site-PIP bits and a held-out replay succeeds.


## Separating INT-mux bits from site-PIP bits

`CLBLM_R` has exactly one site PIP per LUT input pin:

- `CLBLM_IMUX1 -> CLBLM_M_A3`
- `CLBLM_IMUX2 -> CLBLM_M_A2`
- `CLBLM_IMUX4 -> CLBLM_M_A6`
- `CLBLM_IMUX7 -> CLBLM_M_A1`
- `CLBLM_IMUX8 -> CLBLM_M_A5`
- `CLBLM_IMUX11 -> CLBLM_M_A4`

There is no second site PIP feeding the same pin, and no shared IMUX source across
two pins. Therefore changing one LUT input pin necessarily changes one INT mux PIP
and one site PIP together. The 3 bits in `m2_mcd_0001` cannot yet be assigned
individually to those two PIPs.

### Attempted INT-only separation: negative result

Tried to keep pin A3 and site PIPs fixed while forcing an alternate INT route:

```tcl
set_property ROUTE { CLBLM_M_A CLBLM_LOGIC_OUTS12 NR1BEG0 IMUX1 CLBLM_M_A3 } [get_nets n1]
route_design
```

`get_property ROUTE` and `get_pips` reported the alternate route, and the build
succeeded. However, `pin_a3` vs the forced variant had **0 differing frames**:
the `.bit` hashes differ only because the `.bit` ASCII header contains build
date/time. The frame data is identical.

Conclusion: `set_property ROUTE` is an annotation on the routed net, not a
physical routing constraint; `route_design` does not honor it as a new path.
`route_design -seed` is unsupported in 2017.2, `AlternateRoutability` is not a
valid directive, and `Explore`/`MoreGlobalIterations` reproduced the original
route exactly.

Therefore this simple one-net design cannot produce an INT-only pair by route
property editing. Do not use the forced-ROUTE experiment as evidence.

### Revised separation strategy

1. Expand the MCD corpus over pins/tiles and use **linear algebra over bit
   incidence** instead of demanding a clean one-PIP pair.
2. To get an INT-only observation, add controlled **congestion or a second legal
   sink** so the router chooses a different upstream path; record the extra
   placement/load bits and exclude their frames explicitly.
3. Keep bitstream candidate-bit flipping out of the loop until the corpus has a
   held-out replay.



