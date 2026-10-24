你是一次独立的第三方实验审阅。请只读审阅 `v7re` 项目当前的 M2 实验成果，不要修改任何文件，不要运行 Vivado，不要生成 bitstream。

必读材料：
- `README.md`, `ARCHITECTURE.md`
- `steps/M0_MODEL.md`, `steps/M1_ADDRESS.md`, `steps/M2_PIP.md`, `steps/M2_CORPUS.md`
- `data/m2/pairs/m2_mcd_0001.json` ... `0005.json`
- `data/m2/validation/README.md` 及 `data/m2/validation/clbll_l_y30/*`、`clbll_l_y40/*` 的 `top.xdc`、`pips.txt`、`build.log`
- `data/m2/fam/clbll_l/*`、`data/m2/fam/clblm_l/*` 的 `top.xdc`、`pips.txt`、`build.log`
- `data/m2/negative/A1_A3_NEGATIVE.md`

审阅重点：
1. `check_m2_gate.py` 的 M2 GATE PASS 是否真的成立？5 对样本是否独立，是否存在同一实验重复计数、事后挑选（post-hoc selection）、循环论证或把“同一次 A3->A5 换位置”当作独立证据的问题。
2. 每个 pair 的 `route_a/route_b`、`pip_symdiff`、`diff_frames`、`data_bits` 是否与 `pips.txt` / `build.log` / JSON 自洽；bitstream SHA 的作用是否被正确理解；排除 word 50 是否合理、是否可能误删真实数据位。
3. 文档中的 word 模型 `word = 2*target_row + (target_row >= 25 ? 1 : 0)` 是否被数据支持？Y30/Y40 是真正的 held-out 预测，还是看到结果后才拟合？Y40 的“预测成功”证据强度如何？边界条件（row 50 / clock-region）是否足够。
4. “INT mux 与 site PIP 必然耦合、无法产生单 PIP 对”这一结论是否成立？是否还有其它可分离实验（例如第二 sink、congestion、不同 tile family、LUT 输入组合）值得做？如果要做 bit flipping，当前证据是否足够。
5. 记录的 frame/word/bit 是否可能包含布局、clock region、CRC/aux 或 bitstream header 的伪差异；当前 diff 方法有没有漏检/误检。
6. 对 STEP04（frame-bit / segbits）的可执行建议：下一步最小实验、需要的控制变量、验收标准。

输出格式（中文）：
- 总结论：接受 / 有条件接受 / 拒绝，并说明理由。
- P0（阻断性）、P1（重要）、P2（改进）问题清单；每条必须引用具体文件与行号或命令输出，不要只复述文档。
- 需要补做的实验，按优先级排序；每条写清目的、输入、判定标准。
- 一份可以直接执行的 minimum next-step checklist（不超过 10 条）。
- 明确区分“已被证据支持”“只是合理假设”“尚未验证”。

不要修改任何文件。不要运行 Vivado 或写 bitstream。
