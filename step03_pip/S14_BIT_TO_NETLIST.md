# S14 —— 从 .bit 到网表：首个端到端闭环

> ⚠️ **器件修正（2026-11-06）**：本文引脚相关结论（PACKAGE_PIN / 键合引脚）来自实际 routed DCP 的 part = **xc7vx485tffg1157-3**，
> 不是 VC707 的 ffg1761-2。fabric（帧/tile/site/BEL/位图）结论不受影响；引脚需按封装重映射。
> 详见 `PART_CORRECTION_FFG1157.md`，两套映射表在 `pins/pins_map_ffg1157.csv`、`pins/pins_map_ffg1761.csv`。
日期: 2026-10-31    输入: `E:\v7work\_s8v0.bit` (20,273,538 B)
验证目标: Vivado 生成的 `s8_v0.bit`（LUT6 + FDRE + LUT2 三个单元）

## 1. 全芯片 CLB 扫描（纯 bitstream）
`decode_clb.py` 用 `v7_law.sqlite` 的 clb_cells(3,884 行) 对 75,900 个 slice 全扫：

| 项 | 结果 |
|---|---|
| 特征命中 | 62 条，仅落在 2 个 slice |
| 解码 slice | `SLICE_X8Y11`、`SLICE_X47Y51` |
| Vivado 真值 | `SLICE_X8Y11`、`SLICE_X47Y51` |
| 一致 | ✅ 2/2，无多解、无漏判 |

## 2. INIT 解码
- `SLICE_X8Y11/A6LUT`：38 位置位 → 物理 INIT `0x937b7471e799fac5`（真值逻辑 `0x9e3779b97f4a7c15`，差一个 pin-swap）。
- `SLICE_X47Y51/A6LUT`：16 位置位 → `0xc0c0c0c0c0c0c0c0`，等价 LUT2 `4'h8`（AND）。

## 3. FF 解码
`SLICE_X8Y11/AFF`：`AFF.ZRST` 置位（同步复位族）→ FDRE；`AFF.ZINI(31,40,3)` 置位 → `INIT 1'b0`；`AFFMUX.O6` → `D = A6LUT.O`。

## 4. 引脚归属（48-IMUX CSP，唯一解）
| pad | 线网 | 网络 |
|---|---|---|
| A1 | SW2END3 | i[0] |
| A2 | WW2END0 | i[1] |
| A3 | WL1END0 | i[3] |
| A4 | SR1END1 | i[4] |
| A5 | GFAN0 | i[5] |
| A6 | WL1END1 | i[2] |

未解析 0 个。net 名来自 S13 的 6/6 token-exact INT 链（`s13_solution2.json`）。

## 5. 功能等价性证明（关键）
把恢复的 (物理 INIT, 恢复的 pin map) 与原设计 (逻辑 INIT, I0..I5=i[0..5]) 在全部 64 组输入上比对：

```
LUT6 mismatch over 64 inputs: 0
LUT2 mismatch: 0
```

即 **纯 bitstream 恢复出的网表与原设计功能完全等价**（不是"看起来像"，是逐真值点相等）。

## 6. 产物
- `E:\v7work\netlist.json`（结构化：cells/pins/unresolved）
- `E:\v7work\netlist_recovered.v`（可综合 Verilog）
- `step03_pip\emit_netlist.py`（发射器，可复跑）

## 7. 已知边界
- `SLICE_X47Y51` 属 CLBLM_R 的 SLICEL_X1 形态，IMUX 偏移与 X0 不同，其 pad 级归属（A2/A3）尚未由 pip_bits 独立解出，目前用真值交叉确认；补齐 X1 IMUX CSP 后即可纯解码。
- 端口名（i/clk/ce/rst/o/o2/o3）不可从 bitstream 恢复，按约定沿用。
- 多 sink 扇出（i[0]/i[5] 同时喂 LUT2）依赖 o3 seed PIP，仍缺 1 条记账。
