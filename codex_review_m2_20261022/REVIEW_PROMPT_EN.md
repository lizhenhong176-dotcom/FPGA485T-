You are an independent third-party reviewer. Perform a strictly READ-ONLY review of the current M2 experiment results in this directory. Do not modify files, do not run Vivado, do not generate bitstreams, and do not run anything that writes outside this review directory.

Read at least:
- README.md, ARCHITECTURE.md
- steps/M0_MODEL.md, steps/M1_ADDRESS.md, steps/M2_PIP.md, steps/M2_CORPUS.md
- data/m2/pairs/m2_mcd_0001.json ... 0005.json
- data/m2/validation/README.md and the top.xdc, pips.txt, build.log under data/m2/validation/clbll_l_y30 and clbll_l_y40
- data/m2/fam/clbll_l/* and data/m2/fam/clblm_l/* (top.xdc, pips.txt, build.log)
- data/m2/negative/A1_A3_NEGATIVE.md
- scripts/check_m2_gate.py (or wherever the gate script is)

Review questions:
1. Is the M2 GATE PASS actually justified? Are the 5 pairs independent, or do they repeat the same experiment, post-select results, argue circularly, or treat the same A3->A5 relocation as independent evidence?
2. Are each pair's route_a/route_b, pip_symdiff, diff_frames and data_bits consistent with pips.txt, build.log and the JSON? Is the role of the bitstream SHA understood correctly? Is excluding word 50 justified, and could it delete real data bits?
3. Is the word model word = 2*target_row + (target_row >= 25 ? 1 : 0) supported by the data? Were Y30/Y40 genuinely held out, or fitted after seeing results? How strong is the Y40 prediction? Are boundary conditions (row 50, clock-region boundaries) sufficient?
4. Is the claim "INT mux and site PIP are necessarily coupled, so no single-PIP pair can be produced" correct? Are there better separation experiments (second sink, congestion, another tile family, different LUT input combinations)? Is the current evidence sufficient for bit flipping?
5. Could the recorded frame/word/bit differences include placement, clock-region, CRC/aux or bitstream-header artifacts? Does the current diff method have false positives or misses?
6. Give actionable STEP04 (frame-bit / segbits) advice: the minimum next experiment, required controls, and acceptance criteria.

Output in Chinese:
- Overall verdict: ACCEPT / CONDITIONAL ACCEPT / REJECT, with reasons.
- P0 (blocking), P1 (important), P2 (improvement) issue list. Every item must cite a specific file and line number or a command output; do not merely restate the docs.
- Additional experiments in priority order; for each give purpose, inputs, and pass/fail criteria.
- A directly executable minimum next-step checklist (max 10 items).
- Explicitly separate "supported by evidence", "reasonable hypothesis only", and "not yet verified".

Do not modify any file. Do not run Vivado or write a bitstream.
