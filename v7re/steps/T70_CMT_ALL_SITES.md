# T70：全 14 个 CMT 站点（MMCM/PLL）的 HCLK_CMT 编码对照

日期：2026-11-10　器件：`xc7vx485tffg1157-3`　实验目录：远端 `/opt/lzh/v7re/work/hclkall`，本地 `_ha2/`

## 1. 站点枚举（`_sites.tcl`）

`create_project -in_memory -part xc7vx485tffg1157-3` → `link_design -part ... -name d0` → `get_sites`：

| 类型 | 数量 | 名称 |
|---|---|---|
| MMCME2_ADV | 14 | `MMCME2_ADV_X{0,1}Y{0..6}`，X0/X1 两列 × 7 行 |
| PLLE2_ADV | 14 | `PLLE2_ADV_X{0,1}Y{0..6}`，同上 |
| BUFHCE | 168 | — |
| clock region | 14 | — |

踩坑：`create_project -in_memory` 之后直接 `get_sites` 报 `[Common 17-53] No open design`；
`open_design` 不是有效命令，必须 `link_design`。

## 2. 28 个设计

每个：`CMT → BUFHCE → FDRE → q`，`CLKFBOUT_MULT_F(10.0)`（PLL 用 `CLKFBOUT_MULT(10)`）、`CLKFBIN←CLKFBOUT` 反馈环、`CLKIN1_PERIOD(10.0)` → VCO 1000 MHz。
运行时按 CMT 所在 clock region 推 BUFHCE 与 SLICE 位置：

```tcl
set reg [get_clock_regions -of_objects [get_sites $site]]
set bh  [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "BUFHCE"}] 0]
set sl  [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "SLICE"}] 0]
```

**28/28 全部构建成功**，回读 `SITE=` 全部正确。

### 两轮失败与修正（都是可复现的坑）

| 现象 | 根因 | 修法 |
|---|---|---|
| `DRC PDRC-34` 500 MHz 不在 600–1600 | CLKFBIN 接常量 → `CLKFBOUT_MULT_F` 取默认 5，`CLKIN1_PERIOD=10` → VCO 500 MHz | 加 `CLKFBIN←CLKFBOUT` 反馈环 + `CLKFBOUT_MULT_F(10.0)` |
| `DRC PDRC-43` 500 MHz 不在 800–2133 | 同上（PLL 默认 `CLKFBOUT_MULT=5`） | `CLKFBOUT_MULT(10)` |
| `Place 30-124` BUFHCE 只能驱动同 region 负载 | BUFH/FF 交给 placer 后落到别的 region | 运行时按 region 取 BUFHCE 与 SLICE 并 `LOC` |
| `Place 30-575/172` clock-capable IO 与 MMCM/PLL 配对次优（仅 m12/m13/p12/p13 = X1Y0 两行） | X1Y0 离时钟输入脚 AF25 太远 | `set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]`（连同 `clk_IBUF`） |

## 3. 路由事实：每个 site 都用自家的 0 号源

`*.pips` 里每个设计都出现：

```
HCLK_CMT.HCLK_CMT_MUX_CLK_MMCM0 ->> HCLK_CMT_MUX_CLK_13      （m 系列）
HCLK_CMT.HCLK_CMT_MUX_CLK_PLL0  ->> HCLK_CMT_MUX_CLK_13      （p 系列）
```

即每个 CMT 实例的输出固定是**本 CMT 的 0 号源**，14 个 site 都如此 —— 这正好构成「同编码、不同实例」的对照集。

## 4. 差分：编码只依赖「哪一列」，不依赖「哪一行」

把每个设计的 CMT 配置簇（连续帧段）按段起点归一化成 `(frame-lo, word, bit)` 后比对：

| 组 | 成员 | 结果 |
|---|---|---|
| MMCM X0 列 | m00(X0Y6)、m02(X0Y5)、m04(X0Y4)、m06(X0Y3) | **30/30 全同** |
| MMCM X1 列 | m01(X1Y6)、m03(X1Y5)、m05(X1Y4)、m07(X1Y3) | **30/30 全同** |
| PLL X0 列 | p00、p02、p04、p06、p08、p10 | **292/292 全同** |
| 跨列 | m00 vs m01 | 相同 4/30 |
| 跨列 | p00 vs p01 | 相同 0/292 |

**结论**：HCLK_CMT 的 CMT 输出选择编码是 **per 列（X0/X1）+ per 类型（MMCM/PLL）** 的常量，
与 clock region 的 Y 行**无关**。也就是全器件只有 4 套布局（MMCM×2 列、PLL×2 列），
站点数 14 个不带来额外布局，只带来实例坐标。

## 5. 边界（未完成 / 不确定）

- PLL X1 列（p01/p03/p05/p07/p09）簇定位被孤立位（帧 23575/13083/7837/18329 等）打断，
  当前显示「5 格」不可信；p11/p13 与它们 0/5 相同，需重新锚定后再判。
- 本次只判「同一个 0 号源的编码是否随实例变」，**没有**覆盖 14 个 MMCM 源各自的选择编码
  （`MUX_CLK_MMCM0..13`）——那部分仍以 T48/T49 的 2–3 格差分结论为准。
- 每个设计的 CMT 配置簇里还混有 MMCM/PLL 自身参数位（`CLKFBOUT_MULT_F` 等），
  未逐位分离；本轮只做「簇签名相等性」判定。

## 6. 复现

```bash
# 远端
cd /opt/lzh/v7re/work/hclkall
ls *.tcl | sed 's/.tcl//' | xargs -P 14 -I{} /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado \
    -mode batch -notrace -source {}.tcl > {}.log 2>&1
```
本地分析：`frames_from_bit` 取格 → 按帧聚簇 → 归一化 → 集合比对。
