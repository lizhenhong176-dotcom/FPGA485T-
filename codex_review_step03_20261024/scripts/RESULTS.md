# STEP03 第一轮：PIP → bit 差分实验（远端 WSL，Vivado 2017.2）

实验目录：远端 `/opt/lzh/step03/pip1`
设计：两个 DONT_TOUCH LUT6（`lut_a -> n1 -> lut_b -> b`），`n1` 锁定在
`SLICE_X8Y10/A6LUT -> SLICE_X8Y11/A6LUT`，两条网线经过 `INT_L_X6Y10`、`INT_L_X6Y11`。

## 基线

`build_a.tcl` → `routed.dcp` + `a.bit`（20,273,538 B）。
`n1` 的 4 条 PIP：

```
0 CLBLL_L_X6Y10/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12
1 INT_L_X6Y10/INT_L.LOGIC_OUTS_L12->>NR1BEG0
2 INT_L_X6Y11/INT_L.NR1END0->>IMUX_L8
3 CLBLL_L_X6Y11/CLBLL_L.CLBLL_IMUX8->CLBLL_LL_A5
```

## 方法

1. `pip_edit.py`：RapidWright 读 `routed.dcp`（需先 `write_edif` 生成 `top.edf`），
   用 `java.util.ArrayList` 重建 PIP 列表（Python list 会报 `No matching overloads`），
   删掉第 `DROP` 条后写 `b.dcp`。
2. `bit_any.tcl`：`open_checkpoint` → `write_bitstream -force -bin_file`。
3. `diff_all.py`：解析两份 `.bit`，按帧、按 (word, bit) 求差。

## 结果

| 变体 | 删掉的 PIP | 差异帧 | 配置位（排除 word 50） | word 50 |
|---|---|---|---|---|
| drop1 | `INT_L_X6Y10 LOGIC_OUTS_L12->>NR1BEG0` | 31690, 31693 | (w20,b7) 各 1 位 | 7 位（ECC） |
| drop2 | `INT_L_X6Y11 NR1END0->>IMUX_L8` | 31699, 31702, 31704, 31705 | (w22,b3) + (w22,b2)×3 | 3–5 位（ECC） |
| drop0 | `CLBLL_LL_A->CLBLL_LOGIC_OUTS12` | — | 无变化 | — |
| drop3 | `CLBLL_IMUX8->CLBLL_LL_A5` | — | 无变化 | — |

对照实验：项目里已有的 LUT INIT 差分对
`/opt/lzh/v7re/work/probe_smoke/{a,b}.bit` → 帧 31750、31751，
配置位 `(20,15)`，**word 50 同样有 9 位变化**。

## 结论

1. **word 50 是 ECC**，不是配置位。任何数据位变化都会引起 word 50 的一组位变化；
   做 PIP→bit 数据库时必须把它剔除（或用 ECC 校验差分是否正确）。
2. 删除 INT tile 的 PIP 会精确反映到比特流的固定帧上：`drop1` 命中 2 帧，
   `drop2` 命中 4 帧，且 word 编号不同（w20 / w22），说明这几帧覆盖同一 tile 的不同配置列。
3. **站点内部 PIP（CLB 的 A→LOGIC_OUTS、IMUX→A）改 DCP 不生效**：
   bitgen 从网表/布局重新推导站点路由，忽略 DCP 里改过的 site routing 属性。
   要 fuzz 站点内部位，必须改网表（例如换 LUT 输入引脚）而不是改 route 属性。

## 帧号映射回 FAR（已完成）

用 `ConfigArray` 按“行 + 每行末尾 2 个 overhead 帧”重建线性序号：

| 帧号 | FAR | row | col | 块内偏移 |
|---|---|---|---|---|
| 31688 | `0x420308` | 6 | 6 | 8 |
| 31690 | `0x42030A` | 6 | 6 | 10 |
| 31693 | `0x42030D` | 6 | 6 | 13 |
| 31694 | `0x42030E` | 6 | 6 | 14 |
| 31699 | `0x420313` | 6 | 6 | 19 |
| 31702 | `0x420316` | 6 | 6 | 22 |
| 31704 | `0x420318` | 6 | 6 | 24 |
| 31705 | `0x420319` | 6 | 6 | 25 |

全部落在列 X6、行 6，块覆盖 `CLBLL_L_X6Y0..Y49`（CLB 与 INT 共用同一列的配置空间），
与设计里的 `INT_L_X6Y10/11/20/30/40` 对得上。

## 同一条 PIP 在不同 Y 的位位置

设计改为 `SLICE_X8Y{row}` / `SLICE_X8Y{row+1}`，都用同一款 PIP（`LOGIC_OUTS_L20->>NR1BEG2`），
删掉后差分：

| Y | 删除的 PIP | 变化帧 | 配置位 | word50 位数 |
|---|---|---|---|---|
| 20 | `INT_L_X6Y20 LOGIC_OUTS_L20->>NR1BEG2` | 31688, 31694 | (w41, b7) | 6 |
| 22 | 同款 | 31688, 31694 | (w45, b7) | 6 |
| 30 | 同款 | 31688, 31694 | (w62, b7) | 7 |
| 31 | 同款 | 31688, 31694 | (w64, b7) | ~10 |
| 32 | 同款 | 31688, 31694 | (w66, b7) | 10 |
| 40 | 同款 | 31688, 31694 | (w82, b7) | 10 |
| 41 | 同款 | 31688, 31694 | (w84, b7) | 10 |
| 42 | 同款 | 31688, 31694 | (w86, b7) | 7 |
| 50 | 同款（region 1） | **26442, 26448** | (w1, b7) | 10 |
| 52 | 同款（region 1） | **26442, 26448** | (w5, b7) | 8 |
| 60 | 同款（region 1） | **26442, 26448** | (w21, b7) | 10 |

结论：

- **帧对由 (列, clock region, PIP 变体) 决定**：region 0（Y0~49）恒为 `31688 + 31694`，
  region 1（Y50~99）恒为 `26442 + 26448`；两个 region 的块内偏移都是 **8 和 14**
  （块基址 region0=`0x420300`，region1=`0x400300`）。
- **word ≈ 2 × (Y − region 起始行) + k**：region 1 的 Y50/52/60 → 1/5/21（k=1）；
  region 0 的 Y20/22 → 41/45（k=1），Y30 及以后 → 62/64/66/82/84/86（k=2）。
  即 **每行 +2 个 word**，但 k 有 1 或 2 的差异，待复核（可能与具体 wire 实例有关）。
- bit 位恒为 b7（这款 PIP）。
- Y10 那组用的是另一款 PIP（`LOGIC_OUTS_L12->>NR1BEG0`），帧号 31690/31693、word 20，
  说明**帧对和 word 都编码了 PIP 变体 + 所在行**，不是单一坐标。

## 下一步

1. 复核 word 常数 k 的 ±1（Y20/22 与 Y30+ 的分界），确认是否与 wire 实例/帧内偏移有关。
2. 对同一 tile 的多种 PIP 变体（BEG0/BEG1/BEG2、END、IMUX 方向）各取一条，建 `变体 → (帧对, word)` 表。
3. word 50 的 ECC 规则单独验证：已知数据位翻转 → ECC 位的映射是否可以拟合。
