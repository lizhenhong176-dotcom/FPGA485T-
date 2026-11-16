# S7 跨 tile 位格式预测检验

日期: 2026-10-28（s7 首轮 + s7b 非退化复测）
方法: 4 个全新实例 × 2 个设计（LUT6 INIT / LUT6+FDRE），预测→Vivado 生成→实测比对。

## 目标实例

| 标 | Site | Tile | Site 实例 | B(列基帧) | 行字 w |
|---|---|---|---|---|---|
| A | SLICE_X3Y10 | CLBLM_L | SLICEL_X1 | 31544 | 20 |
| B | SLICE_X5Y10 | CLBLL_R | SLICEL_X1 | 31580 | 20 |
| C | SLICE_X0Y10 | CLBLL_R | SLICEL_X0 | 31508 | 20 |
| D | SLICE_X10Y300 | CLBLM_R | SLICEM_X0 | 21224 | 0（远端 clock region, band 6） |

设计 d1 = LUT6 A6LUT INIT=0x9E3779B97F4A7C15（非退化）→o；d2 = d1 + FDRE(AFF, D=lo6, Q→o2)。
（首轮 s7 用 INIT=0x5555 被综合化简为单输入方程并触发 PDCN-1569，作废，s7b 重测。）

## 结论

1. **地址层 4/4 完全可预测**（含远端 band、X1 位、4 种 tile 类型）：
   B 由 clb_blocks(grid_col, band) 给出，w=2*(Y%50)。INIT 字段全部落在预测帧 × 行字。

2. **字段层（artix7 site_cells 移植）4/4 精确**：
   - X0 site INIT: off 32–35；X1 site INIT: off 26–29（本块首次在 V7 上实测 X1 字段位置，CLBLM_L/CLBLL_R 均验证）。
   - AFFMUX.O6 / AFF.ZRST / AFF.ZINI 12/12 全中：
     X0: (30,3)/(30,12)/(31,3)；X1: (30,4)/(31,15)/(31,4)。
   - AOUTMUX O6/A5Q = ∅（V7 已知规律，X1 也未出现额外位）。

3. **LUT INIT 位级排列 ≠ 常量 —— pin-swap 依赖**（关键发现）：
   实测 38 位 INIT 图样在帧/字/位域上正确，但 index→(帧,位) 的置换随设计变化。
   对 720 个按位置换搜索：每个目标都存在唯一置换 38/38 完美命中，但 A/B/C/D
   四个置换互不相同 → 这是布局器 pin-swap 的签名（逻辑 I0–I5→物理 A1–A6 的
   映射由 placer 按布线选择，物理 INIT 随之重写）。
   - M3 库（X10Y10）之所以恒等成立：其探针设计的连通性固定了 pin map。
   - **对逆向（bit→netlist）无碍**：解码 INIT 需同时读 IMUX/PIP 路由位恢复 pin
     map（fasm2bels 的做法），INIT 字段 + pin map → 逻辑真值表，完全确定。
   - **对正向预测有碍**：预测一个新设计的比特必须固定 pin map（Vivado
     `set_property LOCK_PINS` / DONT_TOUCH 不能替代）。

## 复现

- 生成: `python s7b_gen.py`（预测 s7b_predictions.json + 8 组 .v/.xdc）
- 远端: `/opt/lzh/step03/s7/s7b_run.sh`（vivado s7b_build.tcl ×8 + s7b_dump.py）
- 实测: `s7b_bits.json`；比对脚本（本文件同目录，720 置换搜索）。
