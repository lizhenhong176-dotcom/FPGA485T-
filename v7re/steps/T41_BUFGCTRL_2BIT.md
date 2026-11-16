# T41：PIP 版手段 A 首次成功 —— BUFGCTRL 输入选择 = 2 位

日期：2026-11-08

## 1. 结果

两个设计唯一的差别是 `BUFGCTRL` 的 `S0/S1`（选 I0 还是 I1），其余全部固定
（引脚 AF25/AN33/AN34、`IOSTANDARD LVCMOS18`、`LOC BUFGCTRL_X0Y16`、FF 位置）：

| 项 | 结果 |
|---|---|
| PIP 列表 | **逐行完全相同（92 行 / 92 行）** |
| 数据差格 | **2 位** |
| 位置 | `(帧 13080, word 0, bit 11)`、`(帧 13081, word 0, bit 3)` |

即：**BUFGCTRL 的输入选择（I0 vs I1）由 2 个位编码，落在 2 个帧的 word 0 上。**

## 2. 为什么这次成立

这是「手段 A：同一路径、只换中间一跳」的第一次成功应用：

- 引脚不变（IOB 配置不变）；
- 走线不变（PIP 列表逐行相同）；
- 只改 `S0/S1` 两个常量 → 差分里只剩选择位。

对比 INT 的做法（换源必然换线），时钟 mux 这类「选择由寄存器位决定、不由布线决定」
的结构，天生适合手段 A。

## 3. 构建踩到两个坑（记录备用）

1. `BUFGCTRL` **没有** `SIM_DEVICE` 参数（`ERROR: [Synth 8-3438] ... does not have any parameter 'SIM_DEVICE'`）；
2. IO 引脚直连 BUFG 会触发 `[Place 30-574] Poor placement for routing between an IO pin and BUFG`
   → 必须加 `set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets a/b/c]` 才放得过。

## 4. 下一步（同一手法可套的时钟族）

| 目标 | 做法 | 预期构建数 |
|---|---|---|
| `BUFGCTRL` 其余 site（X0Y8 / X0Y24…） | 同设计换 `LOC` | 2/站点 |
| `BUFGMUX` vs `BUFGCTRL` | 换原语 | 2 |
| HROW（`CLK_HROW_*`）的 CK_MUX | 同引脚、改 BUFG 输出去向 | 4–6 |
| HCLK 的 `HCLK_CK_*` | 同 FF 位置、改时钟源 | 4–6 |

判据同 T40：**PIP 列表必须逐行相同**；差分应落在个位数且集中在时钟 tile 的帧内。
