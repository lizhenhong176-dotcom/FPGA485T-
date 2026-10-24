# Independent literature-grounded review

You are a senior FPGA bitstream reverse-engineering reviewer. The user has five
Chinese MSc theses (extracted text in `lit/`) and wants an independent judgment:
**can the current technical route be optimized?**

Read the originals selectively; do not trust this packet alone. `LIT_DIGEST.md` is
the author's digest and may contain mistakes. `ROUTE_CONTEXT.md` is the current
project state (Xilinx Virtex-7 xc7vx485t, Vivado 2017.2, six LUT6 A3/A5 and B3/B5
pairs, gate/evidence work, frame-word formula, word-50 INIT experiment).

## What to judge

1. **Alignment**: which current choices are supported by the literature, and which
   are ad hoc or overclaimed? Check the digest against the actual texts.
2. **Frame map**: is it time to replace empirical frame-index probing with the
   analytical FAR + per-column minor-address + per-tile word-offset model from
   Ge? What exactly must be validated for 485T?
3. **Control-bit method**: when is pairwise XOR still valid? For LUT6 INIT it
   appears one-hot and literature says LUTs did not show control-bit reuse; for
   FF/MUX/CARRY/INT, should the project switch to Ge's `A x = B` Tikhonov solve
   and/or Li's path test? Give a concrete migration rule, not a vague suggestion.
4. **Coverage/independence**: current M2 has 2 transitions and one LUT anchor.
   What coverage matrix is minimally sufficient before STEP04 `segbits/pip_bits`?
5. **Verification**: Xiao's netlist consistency check vs the current bit-level
   gate. What is the minimum end-to-end acceptance test for this project?
6. **Automation**: Yuan/Luo automate measurement; the current M2 still uses
   hand-built directories. What should be automated first, and what should stay
   manual for scientific control?
7. **Risks**: control-bit reuse, unary multi-value PLP, pseudo-PIP/hint, word 50,
   FAR column types (BRAM/DSP), Vivado version differences, evidence leakage.

## Deliverable

- A prioritized plan (P0/P1/P2) with concrete file/schema/experiment changes.
- Explicit "keep / change / drop" for the current approach.
- Factual corrections to `LIT_DIGEST.md` or `ROUTE_CONTEXT.md` if any.
- A short answer to: is the current route fundamentally sound, or does it need a
  methodological pivot?

End with exactly one of:

```
VERDICT: KEEP_ROUTE
VERDICT: OPTIMIZE_ROUTE
VERDICT: PIVOT_ROUTE
```

followed by `P0:`, `P1:`, `P2:`, `CORRECTIONS:` and `NEXT_2_WEEKS:` bullets.
Use citations like `ge_hongyi.txt:2338-2421` when making a literature claim.
Do not edit files; read-only.
