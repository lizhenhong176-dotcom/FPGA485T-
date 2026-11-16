# S12 输出网正向走线（bitstream-only）

日期：2026-10-31
目标：从 .bit 单独出发，恢复 s8_v0 设计 3 根输出网（o / o2 / o3）从 CLB 出口到 IO 的走线，
并与 Vivado ROUTE 真值（route_out_o/o2/o3.txt）逐 token 对账。

## 1. 新增解码能力：夹缝列 INT tile

`int_walk_v1.py` 的 tile_block 规则改为通用式：

- INT_L_Xn 在 CLB 列 → 用自己的 CLB 块基址；
- 否则（BRAM/接口/IO 中心夹缝列）→ **西侧最近 CLB 列块 + 36**（INT_L）/ **+68**（INT_R）。

据此 die-center 列 INT_L_X32 / INT_R_X33 在 band0 得到 base 32568 / 32600，
band1 得 27322 / 27354（与 S10b 实测一致）。

结果：激活 INT PIP 由 119 → **152**，新增 33 个，含关键 NN6BEG0←NE6END0 / NN6BEG0←NN6END0 /
NE2BEG0←NN6END0 / NN2BEG0←NN6END0 全部落在 INT_L_X32Y39..58 —— 正是输出网走向 IO 的那一段。

## 2. 三条输出网对账

| 网 | 种子（解码） | 真值 BEG 序列 | 解码走线 BEG | 前缀匹配 |
|---|---|---|---|---|
| o (LUT O6→o) | INT_L_X6Y11 EE4BEG0←LOGIC_OUTS_L12 | EE4×3, NE6×7, NN6×3, NE2 | EE4×3, NE6×7, NN6×2(→第3经 X32Y51) | **10/14** |
| o2 (FF Q) | INT_L_X6Y11 NE6BEG0←LOGIC_OUTS_L4 | NE6×12, EE2, BYP_ALT0, BYP_BOUNCE0 | NE6×12, EE2 | **13/13 全等** |
| o3 | INT_R_X31Y51 NE2BEG0←LOGIC_OUTS8 | NE2, NN6, NN2, BYP×2 | NE2 | 1/3 |

要点：

- **o2 的 fabric 段 13/13 token 完全一致**（NE6 中继 ×12 + EE2），这是输出方向的首个全等样本。
- o 的 EE4×3 + NE6×7 + NN6 全部由解码 PIP 命中；缺 NE2 之后 WR1BEG1 一段（见 §3）。
- o3 的种子 NE2BEG0←LOGIC_OUTS8 已被解出（此前被误标为"IO 入口"），说明 o3 的 LUT2
  (o3_OBUF_inst_i_1) 落在东侧 CLBLM_R/L 列；后续 NN6/NN2 中继也已解出但属其它网位池。

## 3. 缺口：IO 侧收尾段

真值尾部 token 为 `WR1BEG1 → IMUX_L34 → IOI_OLOGIC0_D1 → LIOI_OLOGIC0_OQ → LIOI_O0`。
其中：

- WR1BEG1←NE2END0：artix7 `all_cells.json` 中存在该组，但位级判定未激活；
- BYP_ALT0 / BYP_BOUNCE0：组位于 frame_off 16..24（INT 的 byp mux 区），同样未激活；
- IMUX_L34 / IOI_OLOGIC*：属 INT_INTERFACE / IOI tile，当前 all_cells 只含 INT_L/INT_R 两类。

结论：BYP/WR1 类是 **INT tile 内的 byp mux 位池**（off 16..24），其位与 IMUX 位池同域，
存在跨族共享 → 需要与 IMUX 同样的 CSP 联立判定；IMUX_L34 段需要补 INT_INTERFACE_L/R 的
segbits 才能解。

## 4. 副作用与后续

152 个 PIP 让输入侧 6 网的反向走线出现分支噪声（A1 仅 5 节点即 undriven），
说明贪心走线已到极限，必须升级为 **INT PIP 全局 CSP**（每个配置位/每条 PIP 恰好归属一根网），
这也是 S13 的主任务。

产物：`s8_int_pips_v2.json`（152 PIP）、`s8_walk_out.json`、
`route_out_o/o2/o3.txt`（Vivado 真值）、`walk_out.py`（正向走线）。
