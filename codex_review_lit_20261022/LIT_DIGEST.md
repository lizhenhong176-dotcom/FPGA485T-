# Digest of the five theses (for orientation; read the originals too)

## Ge Hongyi (UESTC 2024), Xilinx 7 series

Relevant sections: 3.2 frame model; 3.3.6 control-bit extraction (text lines
~2338-2421); 3.4 netlist reverse; experimental results ~2560-2660.

- 32-bit FAR: top/bottom, row, column; per-column frame groups (CLB 36 frames =
  26 routing + 10 CLB; BRAM 156; DSP 28). 101 words/frame.
- CLB column: 50 CLBs + one HCLK; each CLB gets 2 words, HCLK 1 word; the row
  offset is `2*row` plus the HCLK insertion. This independently explains the
  `word = 2*(row%50)+...` result in the current project.
- Fuzzing generates many PLP/IPP test designs with randomized/minimal config
  changes, extracts config options + flipped bit positions.
- Control-bit solve: build `A(m x n)` (sample x flipped bit, +1/-1) and
  `B(m x k)` (sample x config option, +1/-1), solve `A x = B` with Tikhonov:
  `x = (A^T A + Γ^T Γ)^-1 A^T B`, Γ=αI, α=n; normalize rows, threshold 0.95,
  residual rejects unsolved options. This handles non-orthogonal/reused bits.
- Reports full LUT/INT coverage, partial IOB/BRAM; ~12 h automated per device.

## Li Yin (UESTC), control-bit testing / PLP

Relevant sections: 3.3 path test and unary multi-value; 4.3 control-bit reuse
(text lines ~3143-3208).

- Automated control-bit test tool; PIP and PLP tests; offset-based extrapolation
  to same-type tiles.
- PLP "unary multi-value": multiple config options share the same control-bit
  vector with different control values; pairwise one-hot diff can misattribute.
- Path testing observes whole internal paths, using configuration-element
  correlation, to solve unary multi-value and paths with no direct control bit.
- On Virtex-5 SLICEL, many FF/MUX/input-switch bits are **reused** across config
  elements; the same option can have different control values under different
  test contexts. LUTs specifically showed no reuse and obeyed offset relations.
- Reuse filtering: vary surrounding placement/context, intersect control-bit
  sets, drop bits that change value; test same element at other positions and
  drop bits that violate offset; remove intersections between elements.

## Yuan Cai (UESTC), automation + hard cores

- Altera/Quartus netlist reverse; command-line executables + Tcl automate the
  mapping-database measurement, replacing manual operation; improves coverage
  and speed; validates by reversing ISCAS'85/89.
- Xilinx code reverse for hard cores (distributed RAM, SRL) via primitives.
- Lesson for this project: the experiment/DB pipeline should be driven by a
  parameterized generator + CLI/Tcl runner, not hand-built directories.

## Xiao Yang (UESTC), reverse-consistency verification

- Compares pre/post-reverse physical netlists element by element: ordinary Cell
  attributes; LUT cells after equivalent transformation; Nets outside a site by
  endpoints; Nets inside a site by path and RouteBEL LUT; checks illegal
  redundant resources.
- 51 OpenCORE/Trust-Hub/Trojan samples, 100% verification accuracy; found three
  bugs in F4PGA-XC-FASM2BELS.
- Lesson: a bit-level gate is not an end-to-end reverse check. A netlist-level
  comparator is the right final acceptance test.

## Luo Jincheng (UESTC), pin reverse + VersaTile

- I/O mapping test automation; solves "unit multi-value" for pin function
  without full netlist reverse; Spartan-6 single-ended/differential pins, 100%.
- Bit-level pin manipulation; VersaTile/ProASIC3 reverse via abstract model,
  control-bit-change feature extraction and UFL nets.
- Lesson: for I/O/BRAM/DSP, primitive/site-level semantics plus multi-value
  handling matter more than global XOR; automate the mapping test.

## Cross-cutting implications

- Analytical FAR/frame map is mature and should replace empirical frame search.
- For LUT6 one-hot INIT, pairwise XOR is acceptable (Li: LUTs showed no reuse).
- For FF/MUX/CARRY/INT, pairwise XOR is likely insufficient: use multi-sample
  design matrices and/or path tests; record control-value polarity, reuse groups,
  evidence count and residual confidence.
- Theses validate with netlist/code reverse, not just bit diffs.
