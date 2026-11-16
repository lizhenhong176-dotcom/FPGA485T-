# S15 —— 纯解码网表 + 重综合位级验证

> ⚠️ **器件修正（2026-11-06）**：本文引脚相关结论（PACKAGE_PIN / 键合引脚）来自实际 routed DCP 的 part = **xc7vx485tffg1157-3**，
> 不是 VC707 的 ffg1761-2。fabric（帧/tile/site/BEL/位图）结论不受影响；引脚需按封装重映射。
> 详见 `PART_CORRECTION_FFG1157.md`，两套映射表在 `pins/pins_map_ffg1157.csv`、`pins/pins_map_ffg1761.csv`。
日期: 2026-10-31    输入: `E:\v7work\_s8v0.bit`（20,273,538 B）

## 1. 新规律：IMUX 位表按 **slice 实例形态** 通用，与 tile_type 无关

实测表 `tilepipe.json` 是在 `CLBLL_L_X6Y11` 上 fuzz 出来的（inst0=X8Y11 SLICEM_X0、inst1=X9Y11 SLICEL_X1）。
S15 把它直接套到 **`CLBLM_R_X31Y51`（不同 tile_type、不同 band、不同 Y）** 的 inst1 上：

| 目标 | 结果 |
|---|---|
| 位池映射（相对块首 off 16..25, word 相对） | 命中 |
| 该块内活跃 mux | 恰好 2 个（`IMUX_L3`、`IMUX_L0`） |
| CSP 结果 | `A2←ER1END1`、`A3←NW2END0`，均 exact + unique |

同一解码器回放 `SLICE_X8Y11` 的 6 个 pad，**6/6 exact + unique**，与 S9 的 CSP 独立复算结果一致 —— 说明表可跨 tile_type 复用，无需重新 fuzz。

## 2. 网络名（端口身份）纯解码

6 条输入链的终点落在 `INT_L_X32Y50..55`（每行一个 IO 入口），据此建立
`(tile,wire) -> 入口行` 映射（207 个节点，**0 冲突**），行号 Y−50 即端口序号：

| pad (X8Y11) | 线网 | 端口 |
|---|---|---|
| A1 | SW2END3 | i[0] |
| A2 | WW2END0 | i[1] |
| A3 | WL1END0 | i[3] |
| A4 | SR1END1 | i[4] |
| A5 | GFAN0 | i[5] |
| A6 | WL1END1 | i[2] |

`SLICE_X47Y51` 的两个输入不在 6 条链里（扇出支路），用反向走线补齐：
`ER1END1 → SW6BEG0@X32Y55 → i[5]`、`NW2END0 → NW2BEG0@X32Y50 → i[0]`。

## 3. 重综合位级验证（最强证据）

把恢复的 `netlist2.v` 送回 Vivado 2017.2，加 LOC + `LOCK_PINS` 固定引脚，重新 place/route/bitgen，
与原 bitstream 逐帧逐字比对：

| 区域 | 差异 |
|---|---|
| `SLICE_X47Y51` 整个 CLB 块（36 帧） | **0 字差异** |
| `SLICE_X8Y11` LUT INIT 区（off 32..35） | **0 字差异** |
| `SLICE_X8Y11` FF/mux 区（off 30/31） | **0 字差异** |
| `SLICE_X8Y11` IMUX 选择区（off 16..25） | 18 字差异（路由未复现，mux 输入源不同） |
| 全芯片 | 53 字差异 / 25 帧（全部是 INT 布线 + ECC） |

即：**单元配置位（LUT INIT、FF 属性、引脚锁定）完全重现**；差异只出现在"走线决定的选择位"上，
而这是我们没有约束布线导致的，非解码错误。

## 4. 产物
- `E:\v7work\netlist2.json`、`E:\v7work\netlist2.v`（纯解码，不含真值）
- `step03_pip\imux_decode.py`（通用 IMUX 解码器，按实例形态）
- `step03_pip\emit_netlist2.py`（全流程发射器）
- `E:\v7work\_resynth.bit`（重综合验证用 bitstream）

## 5. 仍待补
- 输出网的 IO 终点 → OBUF 端口序号（当前按结构命名为 o/o2/o3）。
- 走线约束复现（若把 ROUTE 也约束上，IMUX 区可望零差异）。
