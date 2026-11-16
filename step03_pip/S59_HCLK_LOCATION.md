# S59 · HCLK_* 位区定位（3 设计三态差分）

日期：2026-11-11
远端：`/opt/lzh/step15/hclk/`
设计：8×FDRE 固定 `SLICE_X8Y11`，**唯一变量 = 时钟怎么到 FF**

| 设计 | 时钟路径 |
|---|---|
| `h_off` | `IBUFG` 直接驱动 FF 时钟（无缓冲器） |
| `h_bufg` | `IBUFG → BUFG → FF`（全局网） |
| `h_on` | `IBUFG → BUFHCE → FF`（**区域网 / HCLK**） |

三态分类（逐 cell 取三位 `off/bufg/on`）：

| 类别 | 含义 | 数量 |
|---|---|---|
| `bufg_only` | 仅 BUFG 版本与另两者不同 | **169** |
| `hclk_only` | 仅 BUFHCE 版本与另两者不同 | **31** |
| `other` | 两者都与 `h_off` 不同（布线分歧） | 55 |
| 合计（排除 word 50） | | 255 |

## 0. 核心结论

**HCLK_* 没有自己的帧块。** `frame_blocks` 的 1,038 块只有 6 类
（clb 763 / gap28 245 / io72 14 / edge30 12 / pcie 2 / x36 2），**没有 hclk 类**。
HCLK 的配置分两层落在既有块里：

1. **缓冲器入口层**（谁把时钟送上 HCLK）：`edge30` 块 `off26..29`，
   实测 `BUFHCE_X0Y0` = `(34038+26, w48, b31) + (34038+27, w48, b19/b23/b25)`
   ——与 S53 的 BUFHCE 结论**逐位一致**（交叉验证）。
2. **HCLK 轨道选择层**（哪条 HCLK 进哪个 CLB 列）：分散在**各列 CLB/INT 块的 INT 控制池**
   （`off 0..18`、`22..25`），按该行的 word 排布，**单 bit 语义**（不是家族）。

## 1. `hclk_only` 的 31 个 cell（全部列出）

| 帧 | 块 | off | word | bit |
|---|---|---|---|---|
| 27322 | io72（base 27322） | 0 | 23 | 23, 30 |
| 27322 | 同上 | 0 | 59 | 1, 3 |
| 27330 | 同上 | 8 | 57 | 6 |
| 27336 | 同上 | 14 | 57 | 7 |
| 27730 | clb gc115 | 0 | 23 | 29, 31 |
| 28354 / 28355 | pcie | 216 / 217 | 22 | 1 / 2 |
| 31680 | clb gc16（INT_L_X6Y11 的块） | 0 | 22 | 23 |
| 33601 | edge30（base 33600） | 1 | 87 | 0, 1 |
| 33604 | 同上 | 4 | 51 | 10 |
| 33605 | 同上 | 5 | 51 | 8 |
| 33741 / 33743 | gap28 | 3 / 5 | 51 | 9 / 8 |
| 33869 / 33871 | clb gc179 | 3 / 5 | 51 | 9 / 8 |
| 34010 / 34014 | clb gc188 | 8 / 12 | 51 | 10 / 11 |
| 34038 | edge30（base 34038） | 0 | 51 | 22, 25 |
| 34039 | 同上 | 1 | 51 | 20, 24 |
| 34064 | 同上 | 26 | 48 | 31 |
| 34065 | 同上 | 27 | 48 | 19, 23, 25 |

观察：
- 最后 4 行（`off26/27, w48`）就是 **BUFHCE_X0Y0 的实例位**（与 S53 一致），说明 `h_on` 的 BUFHCE 落在 `BUFHCE_X0Y0`。
- `27322` 系列（io72，band1）是 **IO 列的 HCLK 入口**——`h_off` 与 `h_bufg` 都为 0，只有走区域网才置 1。
- `31680 / 27730 / 33869 / 34010` 是**各列 CLB 块自己的 HCLK 落点使能**，位置与 `off` 相关（相邻列 off 递增 2–4）。
- `28354/28355` 落在 **pcie 块**（off 216/217）——即 PCIE 区的 HCLK 传输位。

## 2. `bufg_only` 的 169 个 cell（分布）

| 块类型 | off | 代表 (word, bit) |
|---|---|---|
| edge30（base 7808, band3） | 26 / 27 | `w42 b20`、`w93 b8`、`w24 b{1,3,15}`、`w73 b{1,3,15}` |
| edge30（base 2562, band2） | 26 / 27 / 28 | 同上形态 |
| edge30（base 13054, band4） | 27 | `w24 b3` |
| clb（多列 gc 0–25） | 0–5 | `w22/w23 b{22..31}` |
| io72 | 0 / 2 / 4 / 7 / 11–17 / 68 / 69 | `w23 b…`、`w57/w59/w85/w49` |

⇒ **BUFG 的“入口”同时改写 edge30 与各个下游列的落点**——BUFG 会向全片广播，所以触发的 cell 远多于 BUFHCE（169 vs 31），这与“全局 vs 区域”的语义一致。

## 3. `other`（55 个）说明

这 55 个在 `h_off` 与另两版之间均不同、但 `h_bufg` 与 `h_on` 又不一致 ⇒ 属**布线分歧**
（时钟路径不同导致 placer/bitgen 选了不同的 INT 走线与落点）。
集中在 `clb gc16/gc19/gc20/gc25/gc30/gc45/gc76`，word 多为 22/23/24/26/28/40/41
——就是 `SLICE_X8Y11` 观察列自身与沿途各列的 INT 控制位。

## 4. 对“HCLK_* 3,020 tile”的重新表述

| 层 | 位在哪 | 状态 |
|---|---|---|
| BUFGCTRL / BUFHCE / BUFMRCE | edge30 `off26..29` | ✅ 部分实测（CE 位、实例位） |
| HCLK 轨道选择（每列入口） | 该列 CLB/INT 块 `off 0..25` 的对应 row word | ✅ 本报告给出 31 个实例位；**未定名** |
| HCLK 的 VBRK / VFRAME / UTURN 段 | 同上（VBRK/edge 块） | ❌ 未测 |

⇒ 之前说的“3,020 个 HCLK_* tile 完全空白”应修正为：
**HCLK 不是独立可配置块，它的位是“分散在各列 INT 控制池 + edge30 入口”的单 bit 集合**，
所以“按 tile 计覆盖率”这个口径对 HCLK 不适用。

## 5. 复现配方

```
h_off : IBUFG(clk) -> 8xFDRE.C     （无缓冲器）
h_bufg: IBUFG(clk) -> BUFG -> 8xFDRE.C
h_on  : IBUFG(clk) -> BUFHCE(CE=1) -> 8xFDRE.C
FF 全部 LOC SLICE_X8Y11；clk=PACKAGE_PIN AL31；d[0..7]/q[0..7] 钉 16 个 bonded pin
synth 后 LOC；CFGBVS GND + CONFIG_VOLTAGE 1.8；豁免 NSTD-1/UCIO-1
分类：逐 (frame,word,bit) 取 (h_off,h_bufg,h_on) 三元组，排除 word 50
```

## 6. 未完成

- 31 个 `hclk_only` cell 的**逐个定名**（哪条 HCLK 轨道、哪个 region 入口）；
- `HCLK_VBRK` / `HCLK_VFRAME` / `HCLK_*_UTURN` 段的位（跨区连接）；
- BUFG 的 169 个 cell 里，哪些是 BUFGCTRL 自身属性（ISCE/IS_SELECT/CE）与哪些是“广播落点”未区分。
