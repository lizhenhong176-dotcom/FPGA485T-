# S10 — INT PIP 全芯片解码 + 反向走线（v1 里程碑）

日期：2026-10-30 深夜。接 S9（CSP IMUX 消歧）之后，目标：仅凭比特流
（`s8_v0.bit`，无 DCP、无网表）恢复 6 根输入网在 INT 阵列中的完整走线，
并与 Vivado ROUTE 真值（`route_I0..I5.txt`）逐 token 对账。

## 核心发现：INT 行字的「半带 +1」规则

**INT tile 的行字 = `2*(Y%50) + (1 if (Y%50) >= 25 else 0)`**

- 证据 A（外部）：本地 artix7 `prjxray_ref\artix7\xc7a200t\tilegrid.json`
  中每个 INT 实例的 `bits.CLB_IO_CLK.offset`：Y0-24 → 2Y；Y25-49 → 2Y+1
  （gy 在带内第 25 行处跳一格，gy235→233）。artix7 与 V7 同构。
- 证据 B（V7 实测）：SW6 中继 PIP 位恰在 X16Y27→w55、X18Y31→w63、
  X20Y35→w71、X22Y39→w79、X24Y43→w87、X26Y47→w95、X28Y51(band1)→w2，
  全部与该公式一致；旧公式（只用 2Y）在这些位置全部落空——这就是
  上一轮走线「undriven-origin」断裂的根因。
- 由此 prjxray segbits 的 `bit>=32 → 第二字`（parity）规则含义明确：
  cell 字 = tile 行字 + parity。

## 帧基址（列→块）

- X 有 CLB 列：INT 的帧基址 = `clb_blocks[(gc, band)]`（INT_L 在 CLB 列
  东 1 格、INT_R 西 1 格，与 CLB 共享 36 帧列块）。
- X 无 CLB 列（BRAM/接口夹缝中的 INT，如 X11/X14/X20/X26）：使用 28 帧
  接口块 = 前一 CLB 块基址 + 36（CLB 块间距 64 ⇒ 中夹 28 帧）。
  实测锚点：31963/31965 w46 = INT_L_X14Y23 的 SW6 中继位。

## 结果

1. **全芯片解码**（`s8_int_pips_v2.json`）：仅 157 个非零帧 → 119 个激活
   INT PIP（48×SW6BEG0 中继、19×NE6BEG0、7×WW4BEG1 等）。解码在 2.5 秒内
   完成（非零帧预过滤）。
2. **反向走线**（`s8_walk_in_v3.json`，脚本 `int_walk_v1.py`）：从 CSP 给
   出的 IMUX 源线出发，PIP 源优先、tileconn 起点近者优先 + DFS 回溯。
   6 根输入网全部走通到 IO 入口边界（undriven root）。
3. **对账（与 route_I*.txt 逐 token）**：
   - A1/A2/A3/A5/A6：**fabric 段 token 序列完全一致**（去掉 route 串里的
     IO 侧入口 launch token 与 `{` 杂项后逐一对上；例如 A2 = 9×SW6BEG0 +
     1×WW4BEG1 + 1×WW2BEG0，A3 含 LV_L18 跨带长竖线段）。
   - A4：sink 半段（X12Y16 中继 → WW4@X10Y12 → SR1 → IMUX_L11）一致，
     入口半段抓了 1 个多余 SW6 中继、漏 1 个早段 WW4BEG1 / SS6 入口——
     原因是入口区 PIP 与输出网共享、且 IO 侧连接（INT_INTERFACE↔INT）
     不在 tileconn 库中（已验证：tileconn 无任何 INT_INTERFACE 对）。

## 已知盲区（下一步）

- IO 入口段：INT_INTERFACE_L/IOI 侧的 PIP 与 tileconn 未入静态库，
  6 根网的「第一跳」launch（SS6BEG0/NW2BEG0/WW4BEG0 等 token）无法
  从比特流恢复——需要补 IO 列的 28 帧块解码或 tileconn 扩充。
- A4 的入口分支错误：需要全局多网 PIP 不相交求解（6 输入 + 3 输出网
  联合），或补 IO 侧数据后自然消解。
- 输出网（o/o2/o3，LOGIC_OUTS 起点）尚未反向走线（正向：CLB→IO）。

## 产物

- `int_walk_v1.py`：解码+走线一体脚本（本报告全部可复现）。
- `s8_int_pips_v2.json`：119 激活 PIP（tile/type/fam/src/X/Y）。
- `s8_walk_in_v3.json`：6 输入网完整节点链（sink→root）。
- `s8_all_frames.json`：157 非零帧 × 101 字（解析自 s8_v0.bit）。
