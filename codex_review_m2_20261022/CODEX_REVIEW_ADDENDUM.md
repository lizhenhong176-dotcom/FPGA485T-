# Codex 审阅复核说明（非 Codex 原文）

- Codex CLI: `0.163.0-alpha.10.2`，模型 `gpt-6.1-sol`
- 原始报告: `CODEX_REVIEW.md`（7,515 B）
- 审阅副本: `E:\DEEPSEEK\FPGA比特流逆向\codex_review_m2_20261022`
- 审阅提示词: `REVIEW_PROMPT_EN.md`

## 1. 打包限制导致的误报

审阅副本为了控制体积，打包时排除了 `*.bit`、`*.bin`、`*.dcp`。因此 Codex 报告中的 P0“JSON 声明的 bitstream 路径不存在、无法复算”是**审阅副本的限制**，不是 Linux 原始工程的缺失。原始工程里 5 对证据文件都存在。

## 2. 对 5 对 bitstream 的独立重算

在 Linux 上运行 `verify_m2.py`（只读），逐对重新解析 `.bit`、计算 frame diff 与 bit diff：

| pair | family | frames | declared diff | non-word50 bits | SHA A/B |
|---|---|---|---:|---:|---|
| 0001 | CLBLM_R | 50176/50176 | 8/8 | 3/3 | match / match |
| 0002 | CLBLL_L | 50176/50176 | 8/8 | 3/3 | **mismatch / mismatch** |
| 0003 | CLBLM_L | 50176/50176 | 8/8 | 3/3 | match / match |
| 0004 | CLBLL_L | 50176/50176 | 8/8 | 3/3 | match / match |
| 0005 | CLBLM_L | 50176/50176 | 8/8 | 3/3 | match / match |

- `diff_frames` 与 `data_bits`（排除 word 50）在 5 对上全部与真实 bitstream 重算结果一致。
- 0002 的整文件 SHA 不一致，但 frame 内容与 JSON 一致；这与 `.bit` 头含时间戳、重跑后 header 改变相符。说明整文件 SHA 不能作为稳定的 frame 证据，应记录规范化 frame hash。
- 每对还存在 6–9 个 word 50 差异位；当前 JSON 将其排除。Codex 对“word 50 是 ECC/aux 尚未证明”的质疑成立。

## 3. 复核后仍然成立的关键问题

1. `scripts/check_m2_gate.py:55-84` 只检查 JSON 数量、id、tile_family 和字段格式；不检查证据文件、不检查独立性、不重算 diff。因此 `M2 GATE PASS` 只是“形式门禁通过”。
2. 5 对全部是 `B.A3 -> B.A5`；family 有 3 个，但控制变量只有一种 transition。0002 与 0004 的 `diff_frames` 完全相同，进一步说明“多 family”不能自动等于独立证据。
3. 0002 的整文件 SHA 已失效；其余 pair 的 SHA 也没有配套的规范化 frame hash。
4. `bitstream/frames.py::diff_frame_indices` 只比较 `min(len(a), len(b))`，长度不一致时不会报错；本次 5 对长度都相等，但门禁应显式断言。
5. Y30/Y40 是同一 clock region 内的局部验证；Y50/Y51 和跨 clock-region 未测，不能据此宣称 word 模型全局成立。
6. “INT mux 与 site PIP 必然耦合”只对当前 CLBLM_R 几何成立，不能外推到所有 tile family/sink。
7. 构建日志存在 `NSTD-1` / `UCIO-1` 未约束 I/O 警告（如 Y30 a3），应纳入 bitstream 生成控制项。

## 4. 我的结论

- **位级数据本身可复算**：5 对 frame diff 和 non-word50 位与 JSON 一致，不是伪造数据。
- **Codex 的 REJECT 主要打在“M2 GATE/独立性”上，是方法学拒绝，不是数据造假判定**。
- 当前更准确的表述是：**CONDITIONAL PASS**——位级结果成立，但 M2 门禁尚未证明 5 对是独立控制变量，word 50 与边界 row 未验证，0002 SHA 需修正。
- 在补做“非 A3→A5 transition、Y50/Y51 边界、规范化 frame hash、evidence 校验”之前，不应把 M2 作为 STEP04 的最终准入证据。
