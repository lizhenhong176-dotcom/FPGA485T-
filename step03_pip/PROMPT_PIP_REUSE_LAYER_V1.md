# PROMPT_PIP_REUSE_LAYER_V1

> 生成方式：按 AGENTS.md 规定，经 `prompt-optimizer` MCP（`http://127.0.0.1:8081/mcp`，
> server `prompt-optimizer-mcp-server 0.1.0`）的 `optimize-user-prompt` 工具产出，非手写。
> 调用参数见本文件末尾「调用记录」。
> 用途：驱动《PIP 复用发生在哪一层 / family 是什么》技术解释文档（`PIP_REUSE_LAYER_EXPLAINED.md`）。

---

# 任务
撰写一份面向具备数字电路基础、但不了解本项目术语的读者的技术解释文档，主题为：在 xc7vx485t（Virtex-7，VC707）比特流逆向项目中，“PIP 复用”发生在哪一层、family 是什么、以及 family 为何与复用强绑定。文档以 E:\v7work\model\v7_law.sqlite 数据库的实测数据为唯一事实来源。

# 数据基准（以数据库实测为准）
- 数据源：E:\v7work\model\v7_law.sqlite，表 law_cells，列 tile_type / family / src_wire / frame_off / bit / sense / parity / src_index。
- 实测规模约束：INT_L 与 INT_R 各 172 个 family，各 12,164 行。
- 所有涉及数量的陈述必须可由该表查询复现；凡未实际查询验证的，标注“未测”。

# 必须逐条核对并裁决的数字清单
对讨论中出现的以下说法逐条与数据库实测比对，明确指出“一致 / 不一致 / 未测”，不一致处给出实测值与差异原因：
1. IMUX_L40 的 10 个 cell 的 frame_off 是 0..9 还是 16..25。
2. 对应的 bit 序列具体取值。
3. 每个 cell 被多少个 src 共用，讨论给出的 [4,4,4,4,4,4,6,6,18,18] 是否正确。
4. 每个源（src）置几位。
5. 形状组合是 5 类还是 7 类。
6. 跨族共享是否为零。
7. 每 feature 平均置位数：2.45 与 3.347 哪个正确，二者统计口径差异在哪。

# 结论标注规则
- 每条结论必须标注【硬件事实】/【数据事实】/【推断】三者之一。
- 未实际验证的内容一律写“未测”，禁止编造数据、禁止模糊量化（如“大约”“可能较多”）。

# 必须解释的电路与编码原理
1. 分级 one-hot 的电路原因：以 pass transistor 栅极分组驱动解释。
2. 位宽公式：说明为什么 (9,20) 需要 4+5=9 位而非 ceil(log2 20)=5 位。
3. 多层编码为何使“单个 1”不携带可解释信息。

# 统计口径论证
- 解释为什么统计必须使用 (frame_off, parity, bit) 三元组。
- 给出漏掉 parity 时会观察到的假象，并以 IMUX_L0 与 IMUX_L4 的实例说明。

# 分层叙述结构
按“配置 SRAM 位 → mux pass transistor 栅极 → 目标 wire（family）”三层展开，明确结论：复用的是物理位，既不是连线也不是 wire。

# 输出要求
1. 必须包含一张“讨论中的说法 vs 数据库实测”核对表，逐行对应上述数字清单。
2. 术语首次出现时给出英文名与 Xilinx 侧对应名。
3. 文档为详细技术解释文档，结构清晰、结论可追溯。

---

## 调用记录

```
POST http://127.0.0.1:8081/mcp
Mcp-Session-Id: 1f5fe936-a118-4b7e-80ca-dbf46a3999df
{"jsonrpc":"2.0","id":2,"method":"tools/call",
 "params":{"name":"optimize-user-prompt",
           "arguments":{"prompt":"<原始 8 条要求，见 _mcp_opt_raw.json 未压缩前的调用脚本>"}}}
```

原始输入（8 条硬要求）摘要：
1. 以 `E:\v7work\model\v7_law.sqlite` 表 `law_cells` 实测为准；
2. 逐条核对 IMUX_L40 的 frame_off / bit 序列 / 每 cell 共用 src 数 / 每源置位数 / 形状组合数 / 跨族共享 / 每 feature 平均置位；
3. 三色标注 + 未测写"未测"；
4. 分级 one-hot 的电路原因与 4+5=9 位宽；
5. 为何统计必须用 `(frame_off, parity, bit)` 三元组；
6. 三层叙述（SRAM 位 → 栅极 → 目标 wire）；
7. 说法 vs 实测核对表；
8. 面向有数字电路基础、不熟悉本项目术语的读者。
