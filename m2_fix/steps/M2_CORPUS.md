# M2 corpus status (2026-10-22)

`scripts/check_m2_gate.py` is now an **evidence gate**, not only a JSON-shape
check.  It reports:

```
pairs=6 families=3 input_transitions=2 mux_signatures=4 valid=6 failed=0
M2 GATE PASS
```

`M2 GATE PASS` means the six pairs are internally consistent, recomputable and
cover two logical pin transitions.  The gate still prints the independence
counters explicitly; do not treat the label as proof that every topology is
covered.

## What the gate checks

For every pair the gate now:

1. Requires the six evidence paths (`bitstream_a/b`, `pips_a/b`,
   `route_log_a/b`) to exist.
2. Requires `pips.txt` to be byte-for-byte the declared `route_a/route_b`
   (ignoring blank lines), so the route is not a hand-written summary.
3. Loads both bitstreams (50176 frames each), asserts equal frame counts, and
   recomputes `diff_frames` and the non-word-50 `data_bits`.
4. Compares the recorded `aux_bits` with the actual word-50 differences.
5. Verifies `frame_sha256_a/b` against a canonical hash of the 101-word frame
   payload.  Whole-file `.bit` SHA-256 is checked only as a warning because
   Vivado rewrites the header timestamp.
6. Rejects duplicate ids, duplicate route experiments and duplicate pips.
7. Normalizes mux encodings (`...->>IMUX_L1` -> `IMUX_L1`) and requires at
   least two distinct mux encodings.
8. If `sink_pin_a` / `sink_pin_b` are present, parses the final `ROUTE=` line
   and requires it to end at that sink pin; any `CRITICAL WARNING` in the
   build log fails the pair.  This is what makes a silent `LOCK_PINS` fallback
   (requested B3, routed B1) a hard error.

## Pairs

| id | tile family | site(s) | route change | frames | data bits (word,bit) |
|---|---|---|---|---|---|
| m2_mcd_0001 | CLBLM_R | SLICE_X7Y10 -> X7Y11 | A3 -> A5 | 31732,31735-31741 | (22,2),(22,3),(22,9) |
| m2_mcd_0002 | CLBLL_L | SLICE_X8Y10 -> X8Y11 | A3 -> A5 | 31696,31699-31705 | (22,2),(22,3),(22,9) |
| m2_mcd_0003 | CLBLM_L (SLICEM) | SLICE_X28Y40 -> X28Y41 | A3 -> A5 | 32112,32115-32121 | (83,2),(83,3),(83,9) |
| m2_mcd_0004 | CLBLL_L | SLICE_X8Y20 -> X8Y21 | A3 -> A5 | 31696,31699-31705 | (42,2),(42,3),(42,9) |
| m2_mcd_0005 | CLBLM_L (SLICEL) | SLICE_X29Y40 -> X29Y41 | A3 -> A5 | 32112,32115-32121 | (83,1),(83,10),(83,11) |
| m2_mcd_0006 | CLBLL_L | SLICE_X8Y10 -> X8Y11 | **B3 -> B5** | 31696,31697,31700-31705 | (22,4),(22,11) |

Every pair has `pip_substitutions=2` and `pip_symdiff=4`: one
`NR1END0->IMUX_Lx` substitution plus one site-PIP substitution. Word 50 is
excluded as ECC/aux and its actual bit set is now recorded as `aux_bits`.

`m2_mcd_0006` is the first non-A3/A5 transition.  It uses the same
`SLICE_X8Y10 -> SLICE_X8Y11` geometry but the B6LUT sink.  Both B3 and B5 use
`LOCK_PINS {I0:A3/A5 ...}` (the BEL-pin namespace for every 6LUT is A1-A6, not
B1-B6), and the routes share
`CLBLL_LL_A -> LOGIC_OUTS12 -> NR1BEG0` before diverging at
`NR1END0->IMUX_L17` vs `IMUX_L24`.  The pair has 8 diff frames and only two
data bits, `(22,4)` and `(22,11)`.

The four distinct mux encodings are `IMUX1/IMUX8` (CLBLM_R),
`IMUX_L1/IMUX_L8` (CLBLL_L and CLBLM_L A-pins), `IMUX_L0/IMUX_L9`
(CLBLM_L SLICEL) and `IMUX_L17/IMUX_L24` (CLBLL_L B-pins).  The corpus now has
two logical transitions: A3/A5 and B3/B5.

## Hash correction and frame hashes

`m2_mcd_0002` had a stale whole-file `bitstream_a_sha256` (and the old JSON did
not carry frame hashes at all). The five pair files were refreshed from the
actual `/data/lzh/v7re/data/m2/.../design.bit` files:

- `frame_count = 50176` for all five;
- `frame_sha256_a/b` is the authoritative hash;
- `aux_bits` records the word-50 differences;
- `bitstream_a_sha256` / `bitstream_b_sha256` are refreshed provenance only.

The refreshed `m2_mcd_0002` A-side whole-file hash is
`57b0a2538e4edd4fb4170f2b6b8db76a95e09412b80f3c21db74917bf64f97b6`.
The old `4e85...` value came from an earlier build; the frames are identical,
which is exactly why the frame hash, not the `.bit` SHA, is now used.
For the same pair, `design.bit` and `design_run1.bit` both hash to
`8c3faa90d0e7aa5c154cfbbd048b1e06dd356f459af34edbc41684150e2fa22e` at the
frame-payload level, even though their whole-file hashes differ.

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
  `design.bit` had zero differing frames, confirming reproducibility. Compare
  frame hashes, not whole-file hashes.

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
evidence. This is why a second logical transition cannot be added by simply
reusing `pin_a1`.

## Negative result: A2 / A4 / A6

`A2`, `A4` and `A6` were built on the same `SLICE_X8Y10 -> X8Y11` geometry.
All three completed, but none is MCD-compatible against A3:

| variant | pips | symdiff vs A3 | shared upstream |
|---|---:|---:|---|
| A2 | 5 | 9 | none (`AMUX -> OUTS20 -> NL1BEG1 -> NL1END1 -> IMUX_L2`) |
| A4 | 5 | 7 | only `CLBLL_LL_A -> OUTS12` |
| A6 | 5 | 9 | none (`AMUX -> OUTS20 -> NR1BEG2 -> NR1END2 -> IMUX_L4`) |

A3->A5 is special here because both sink pins share `NR1END0` and differ only
at the final `IMUX_L1/L8` + site PIP. A2/A4/A6 each take a different upstream
branch, so they fail `pip_symdiff <= 4` and are kept only as negative evidence
under `data/m2/fam/clbll_l/pin_a2`, `pin_a4`, `pin_a6`. See
`data/m2/negative/A2_A4_A6_NEGATIVE.md`.

## B-side correction

The earlier B3/B5 attempts used `LOCK_PINS {I0:B3 ...}` on a B6LUT and failed
with `invalid device pin 'B3'`.  That was a **BEL-pin namespace error**, not a
device limitation: all four 6LUT BELs expose pins named `A1..A6`, so a B6LUT
sink must be constrained as `I0:A3` (or `I0:A5`).  With that correction B3 and
B5 both route cleanly and form valid pair `m2_mcd_0006`.

The old fallback builds (`data/m2/fam/clbll_l/b3`, `b5`) and the initial
A6LUT attempt are kept as negative history, but the B-side conclusion is now
positive.  See `data/m2/negative/B3_B5_NEGATIVE.md` and the corrected builds
under `data/m2/fam/clbll_l/b3_fix` and `b5_fix`.

## Next

1. **Second clock-region boundary:** build the same A3/A5 controlled transition
   at `SLICE_X8Y101 -> X8Y102` (or another row-100 boundary) and check whether
   the changed data word resets to 2, with the same 8-frame pattern.  The
   existing `data/m2/validation/clbll_l_y51` already shows a word-2 reset at
   the first boundary; one more independent boundary is needed before claiming
   a clock-region rule.
2. **Word-50 classification:** build three bitstreams with identical LOC/BEL
   and route constraints: two identical, one with exactly one LUT `INIT` bit
   changed.  If word 50 follows the INIT change it is data/ECC-dependent; if it
   stays invariant under INIT but changes with routing it is route metadata.
3. **Component attribution:** separate the INT-mux bit from the site-PIP bit
   (linear incidence over the corpus; a clean one-PIP pair is still impossible
   on this fabric).
4. **Held-out replay:** extend replay to the new B3/B5 geometry before any
   bit-flipping experiment; do not weaken `pip_symdiff <= 4`.
