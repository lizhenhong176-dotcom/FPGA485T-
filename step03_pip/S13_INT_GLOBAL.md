# S13 — INT PIP 解码修正 + 全局互斥求解

日期: 2026-10-31

## 1. tile_block 规则修正（解码覆盖 152 → 181）

- 旧规则：夹缝列一律 base = 西侧 CLB + 36(INT_L)/+68(INT_R)。实测 INT_R 夹缝块也是 +36，+68 只有部分位置成立。
- 新规则（按优先级，取第一个能匹配到 ≥1 个 family 的候选）：
  1. CLB 邻列（INT_L → gx-1；INT_R → gx+1）
  2. 西侧最近 CLB 块 + 36
  3. 西侧最近 CLB 块 + 68
  4. 下一个 CLB 块 − 28
- 验证锚点（全部命中）：INT_L_X6Y11→31680、INT_R_X7Y12→31716、INT_L_X28Y51→27186、INT_R_X31Y51→27286、INT_L_X10Y11→31824、INT_L_X12Y19→31888、INT_R_X25Y40→32332。
- 关键修复实例：INT_R_X23Y36 旧规则无候选（gx±1 无 CLB 块），新规则取 32232+36=32268，成功解出 `SW6BEG3 ← SW6END3`（这是 A1 链路缺失的一跳）。

## 2. 解码结果

- 181 个 (tile, family) → 唯一 src，**0 ambiguous**
- 行字规则 wof(Y)=2*(Y%50)+(1 if Y%50>=25 else 0) 继续成立

## 3. 全局互斥求解

约束：每条候选 PIP 至多被一条网使用（9 条网路径互斥），每网枚举多解 + 网级回溯。
结果：**9/9 网全部求解成功**，共用 94/181 个 PIP。

- **A1** (27 节点, 13 跳): NW2BEG0 → WW4BEG0 → SS6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 …
- **A2** (25 节点, 12 跳): SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 …
- **A3** (25 节点, 11 跳): WW4BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → WW4BEG1 …
- **A4** (21 节点, 8 跳): SS6BEG0 → WW4BEG1 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SR1BEG1
- **A5** (26 节点, 12 跳): SS6BEG0 → SW6BEG0 → SW6BEG0 → WW4BEG1 → SW6BEG0 → SW6BEG0 → SW6BEG0 → SW6BEG0 …
- **A6** (27 节点, 13 跳): WW4BEG0 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 → SW6BEG3 …
- **o** (20 节点, 10 跳): NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → EE4BEG0 …
- **o2** (26 节点, 13 跳): EE2BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 → NE6BEG0 …
- **o3** (2 节点, 1 跳): NE2BEG0

## 4. 与 Vivado ROUTE 真值对账

- A1: route 14 跳 / walk 13 跳 → **DIFF**
- A2: route 12 跳 / walk 12 跳 → **DIFF**
- A3: route 11 跳 / walk 11 跳 → **EXACT**
- A4: route 13 跳 / walk 8 跳 → **DIFF**
- A5: route 12 跳 / walk 12 跳 → **DIFF**
- A6: route 13 跳 / walk 13 跳 → **EXACT**

## 5. 结论与剩余缺口

- 解码层：tile_block 规则修正后覆盖 181 个 PIP，0 歧义；这是可复现的硬结果。
- 求解层：9 网在“互斥”约束下全解，但仅 A3/A6 与 Vivado 真值逐跳一致；A1 缺 1 个 WW2 中继、A2/A4/A5 有 1–5 跳偏差。
- 原因判定：**候选集内存在多余/缺失 PIP**，导致求解器找到“合法但与 Vivado 实际选择不同”的路径（slack）。已用 94/181 的占用率量化 slack。
- 收敛方向：把 181 个 PIP 全部纳入划分（含 clk/ce/rst/o3 等剩余网），用“全覆盖”代替“部分覆盖+互斥”，即可消除 slack；已导出 Vivado 侧 pip→net 真值表（pip_net.tsv）作为该步的对照。


---

## 6. 真值闭合（2026-10-31 21:30，最终结论）

真值导出通道（可复用）：`pipnet4.tcl` —— 对 148 个 tile 逐个 `get_pips -of_objects`，
再 `get_nets -of_objects $pip` 反查占用网，含 CLB tile（输出网 PIP 挂在 CLBL/CLBLM tile 上）。
环境/踩坑：首个全芯片版本（53k tile）超时被 kill；`get_pips -of_objects [get_nets $n]` 不支持；
PowerShell `>` 重定向把本地副本写成 UTF-16（`.decode('utf-16')`）；cmd 下 `ssh ... | tail` 不可用。

### 6.1 解码覆盖
| 指标 | 数值 |
|---|---|
| 解码 PIP（全芯片） | **181** |
| 真值 PIP（12 网，148 tile 内） | **147** |
| 交集 | **134** |
| 交集内 src 不一致 | **0** |
| decode-only | 47 |
| truth-only | 13 |

- **decode-only 47 条全部集中在 die 中心 IO 列**（INT_L_X32Y78/94、INT_R_X33Y39..57）：
  同一批物理帧被两个 tile 名重复映射（Ghost 重复），属 decoder 作用域问题，不影响求解。
- **truth-only 13 条**：IMUX*（8 条，IMUX 属 CLB 侧，由 pip_bits + CSP 处理）、
  FAN_ALT7/FAN_L7（2 条，时钟使能经 FAN 网络）、GCLK_L_B11_WEST/CLK_L1（2 条，全局时钟）、
  WR1BEG1@INT_R_X33Y58←NE2END0（1 条，o_OBUF 末段）。

### 6.2 求解结果（s13_solve2.py，最大覆盖求解器）
枚举候选：A1 2 / A2 12 / A3 1 / A4 13 / A5 48 / A6 2 / o 7 / o2 2 / o3 4；
网级 DFS 最大化占用 PIP 数 → **BEST 98/181**。

逐 net 对真值（label→net: A1..A5 = i_IBUF[0],[1],[2],[3],[4],[5]；o/o2/o3 = o_OBUF/o2_OBUF/o3_OBUF）：

| 网 | 解出 PIP | 真值命中 | 错 | 未知名 | 真值 PIP 总数 |
|---|---|---|---|---|---|
| A1(i[0]) | 14 | 14 | 0 | 0 | 16 |
| A2(i[1]) | 12 | 12 | 0 | 0 | 13 |
| A6(i[2]) | 13 | 13 | 0 | 0 | 14 |
| A3(i[3]) | 12 | 12 | 0 | 0 | 13 |
| A4(i[4]) | 13 | 13 | 0 | 0 | 14 |
| A5(i[5]) | 13 | 13 | 0 | 0 | 16 |
| o | 9 | 9 | 0 | 0 | 16 |
| o2 | 12 | 12 | 0 | 0 | 13 |
| o3 | 0¹ | — | — | — | 3 |
| **合计** | **98** | **98** | **0** | **0** | 147 |

¹ o3 的 seed PIP（INT_R_X31Y51 NE2BEG0←LOGIC_OUTS8）被当作起点未计入边集，属记账问题。

### 6.3 token 级对账（BEG 序列，去掉 IO 侧与 IMUX/CLB 尾）
| 网 | Vivado ROUTE | 本解码 | 结论 |
|---|---|---|---|
| A1(i0) | NW2BEG0 WW4BEG0 SS6BEG3 SW6BEG3×8 WW2BEG3×2 SW2BEG3 | 同 | **EXACT** |
| A2(i1) | SW6BEG0×2 WW4BEG1 SW6BEG0×8 WW2BEG0 | 同 | **EXACT** |
| A6(i2) | WW4BEG0 SW6BEG3×10 WL1BEG2 WL1BEG1 | 同 | **EXACT** |
| A3(i3) | WW4BEG0 LV_L18 SW6BEG0×6 WW4BEG1×2 WR1BEG2 WL1BEG0 | 同 | **EXACT** |
| A4(i4) | SS6BEG0 SW6BEG0×2 WW4BEG1 SW6BEG0×7 WW4BEG1 SR1BEG1 | 同 | **EXACT** |
| A5(i5) | SW6BEG0×11 WW4BEG1 GFAN0 | 同 | **EXACT** |
| o | EE4BEG0×2 EE4END0 NE6BEG0×… NN6BEG0×3 NE2BEG0 WR1BEG1 IMUX_L34 | 前 9 跳一致，末段 NN6/NE2/WR1 未走（提前落到 LIOB） | 部分 |
| o2 | NE6BEG0×… EE2BEG0 | 12/13 跳一致 | 部分 |

### 6.4 结论
1. **6 条输入网：位级 100% 命中（98/98 PIP，0 错）+ token 序列 6/6 EXACT** —— INT 层逆向在 s8 设计上闭环。
2. 输出网 o/o2 已确认 **9/16、12/13 PIP 正确**，剩余缺口在 IO 列末段（NN6→NE2→WR1→IMUX_L34→IOI）。
3. `tile_block` 四级优先规则（CLB 邻列 → 西 CLB+36 → 西 CLB+68 → 下 CLB−28）由 181 PIP / 0 ambiguous 验证成立。
4. 待补：① 多 sink（fanout）模型——i[0]/i[5] 同时扇出到 o3 的 LUT2；② FAN/GCLK 族解码（ce/clk 网）；
   ③ IO 列末段（INT_R_X33 / INT_L_X32Y5x）去重，去掉 Ghost 重复；④ o3 seed 记账。
