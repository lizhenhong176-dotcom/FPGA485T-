VERDICT: OPTIMIZE_ROUTE

The route is fundamentally sound. The LUT6 result, topology database, Vivado preflight, and integrity gate are appropriate foundations. The methodological gap is that the project is treating a narrow LUT-input experiment as if it already established a general bitstream semantics model.

**Keep / change / drop**

- **Keep:** Vivado-generated differential experiments; minimal routed designs; topology/tileconn database; explicit frame hashes and auxiliary-bit filtering; LUT6 INIT one-hot mapping; preflight validation of every route.
- **Change:** replace empirical frame-index probing with FAR-derived addressing; make experiments matrix-driven; use pairwise XOR only under a demonstrated one-hot/no-reuse condition; add netlist-level acceptance tests.
- **Drop:** the implied generalization from two LUT-input transitions to FF/MUX/CARRY/INT semantics; any claim that word 50 is understood; any graph-plausible route treated as experimentally valid.

**P0**

- Add an analytical frame schema: `far_fields`, `block_type`, `top_bottom`, `row`, `column`, `minor`, `frame_words`, `tile_word_offset`. Ge describes FAR as block type, top/bottom, row, column, and minor fields (`ge_hongyi.txt:945-953`), and identifies 101 32-bit words per frame (`ge_hongyi.txt:945-950`).
- Validate the model specifically on xc7vx485t: at least one CLBLL, CLBLM, HCLK, INT, BRAM, and DSP column; both top and bottom halves; multiple rows and minors. Do not assume Artix/Kintex/Virtex equivalence without observed FAR/word agreement.
- For every generated experiment, record: Vivado version, device, placement, routing, logical option vector, FAR set, frame-word-bit diff, auxiliary diff, expected semantic change, and evidence status (`proven`, `inferred`, `uncertain`, `negative`).
- Establish a minimum coverage matrix before STEP04:

  | Resource | Required contexts |
  |---|---|
  | LUT6 | A/B LUTs, O5/O6, INIT 0→1 and 1→0, all six inputs, at least two sites |
  | FF | D, CE, SR, INIT, sync/async, polarity variants |
  | MUX/CARRY | each select/function value, neighboring dependent elements |
  | INT/PIP | several source/sink classes, bidirectional and pseudo-PIP candidates |
  | Columns | CLB/INT plus BRAM/DSP frame columns |

  One LUT anchor and two transitions are sufficient for an integrity smoke test, not for a `segbits/pip_bits` database.

**P1**

- Implement a migration rule for control bits:

  1. Use pairwise XOR only when repeated tests show the same option produces a stable bit set and value, no overlap with other options, and no context-dependent changes.
  2. For FF/MUX/CARRY/INT, collect a multi-sample design matrix and solve `A x = B` with Tikhonov regularization. Ge explicitly uses this formulation, normalization, a 0.95 threshold, and residual rejection (`ge_hongyi.txt:2389-2416`).
  3. If the residual remains high, or the same option changes value under placement/context changes, mark the option as reused or coupled and switch to Li’s path test. Li reports reuse in Virtex-5 FF/MUX/input-switch resources, while LUT lookup elements did not show the same reuse behavior (`li_yin.txt:3145-3208`).
  4. Never publish a control-bit mapping without storing sample count, context count, residual, polarity, and reuse-group id.

- Treat unary multi-value PLPs as a separate representation: one option may share a control vector with another option but use a different value. Pairwise XOR cannot distinguish that case; path tests observe correlated configuration elements and are required where direct control-bit attribution is ambiguous (`li_yin.txt:1935-2025`).
- Add explicit pseudo-PIP/hint handling. A changed bit is not a PIP merely because it appears in a route differential; require source/sink legality, repeated context tests, and a successful Vivado route/netlist interpretation.
- Automate first: parameterized design generation, placement constraints, Tcl/Vivado batch execution, bitstream parsing, FAR decoding, diff extraction, matrix assembly, and result provenance. Yuan’s contribution is specifically command-line plus Tcl automation to replace manual measurement (`yuan_cai.txt:91-100`). Keep manual review for experiment design, ambiguous coupling, negative controls, and final evidence adjudication.

**P2**

- Add Xiao-style netlist comparison: ordinary cell attributes, LUT-equivalent transformations, inter-site net endpoints, intra-site paths and RouteBEL LUTs, and illegal redundant-resource detection (`xiao_yang.txt:98-109`).
- Minimum end-to-end acceptance test: take a small design containing LUT, FF, one internal route, and one site-local route; reverse the generated bitstream; compare recovered physical netlist against the original; regenerate a bitstream from the recovered representation; require semantic equivalence and a stable round-trip diff outside documented metadata.
- Add negative controls: unchanged design pairs, unrelated placement changes, deliberately illegal PIPs, route-only changes, INIT-only changes, and version-mismatch runs.
- Keep word 50 as an observed data-bearing word. Do not label it ECC, metadata, or “data-adjacent” until its encoding and recomputation behavior are established.

**CORRECTIONS:**

- `LIT_DIGEST.md` overstates the literature when it says the analytical model is already validated for this Virtex-7 device. Ge’s text supports the general 7-series FAR/frame organization and CLB/HCLK layout, but xc7vx485t-specific validation is still required (`ge_hongyi.txt:945-978`, `ge_hongyi.txt:1721-1741`).
- The digest’s statement that “LUTs did not show control-bit reuse” must be scoped to Li’s tested Virtex-5 lookup-table cases, not treated as a universal Xilinx rule (`li_yin.txt:3145-3208`).
- Xiao’s reported 100% accuracy applies to 51 benchmark samples, not proof that a bit-level gate alone is sufficient (`xiao_yang.txt:98-109`).
- The current context correctly says word 50 is unproven; that uncertainty should remain explicit in all generated databases and reports.
- Luo’s offset strategy is an optimization after a reference position has been experimentally shown equivalent; it does not justify skipping representative measurements for each xc7vx485t resource class (`luo_jincheng.txt:2835-2868`).

**NEXT_2_WEEKS:**

- **Days 1–3:** implement FAR decoding and compare analytical addresses against all existing LUT diffs.
- **Days 4–6:** run the full LUT coverage matrix and two independent CLB sites.
- **Days 7–10:** add FF and one MUX/CARRY experiment family; collect enough samples for a first Tikhonov solve.
- **Days 11–12:** automate generator → Vivado → parser → evidence record.
- **Days 13–14:** build the first netlist round-trip comparator and publish only mappings that pass coverage, residual, and negative-control checks.