# T78：混合设计（LUT + DSP + BRAM）对 INT 格宇宙的复验

## 动机
用户质疑：此前「INT tile 同一套规则、残差 0」的检验全部由 LUT 设计驱动，
LUT 只走 IMUX/BEG/时钟路径，可能覆盖不到 DSP/BRAM 列附近的 INT tile。
本实验用一个含 DSP 的混合设计直接测这块盲区。

## 设计（`_mixed/`，远端 `/opt/lzh/v7re/work/mixed`）
- 60 个 LUT6（`DONT_TOUCH`）+ 8 个 DSP48E1 用满（A/B 输入全接信号、`OPMODE=25'h0`、`ALUMODE`/`CARRYINSEL` 接常量、输出异或到 obs）+ 4 个 `RAMB36E1`。
- 显式 `-part xc7vx485tffg1157-3`；`DSP_SITES=8`；**`BRAM_SITES=0`**（`get_sites -filter {SITE_TYPE =~ "RAMB36*"}` 未匹配到，BRAM 由工具自由放置）。
- 构建成功，`mixed.bit` 20,273,538 B。

## 结果（`all_int_tiles_check.py --bit _mixed/mixed.bit`）
```
覆盖 INT tile 实例: 23 / 53,100
窗口内置位: 1,824
格宇宙外: 8   → 判定 FAIL
```
8 个「宇宙外」格聚成 **5 个签名**：

| 签名 (tt, frame_off, bit, parity) | 次数 | 归属 |
|---|---|---|
| `(INT_L, 0, 16, 1)` / `(INT_R, 0, 16, 1)` | 1 + 1 | **GCLK 直通使能位**（`bitwriter.py` 的 `GCLK_PASS_BIT`） |
| `(INT_L, 1, 3, 0)` | 2 | BYP/FAN 旁路控制位（T5 已记录，未接入） |
| `(INT_L, 1, 7, 0)` | 1 | 同上 |
| `(INT_L, 1, 31, 0)` | 3 | 同上 |

## 白名单复验
把这 4 类「非族级控制位」加入白名单后重跑：
```
_mixed/mixed.bit      覆盖 tile 23,    窗口位 1,824  → 残差 0
_tilecov2/cov2.bit    覆盖 tile 12,565 窗口位 64,686 → 残差 0
```

## 结论
1. **规律成立**：混合设计点亮的 23 个 INT tile（含 DSP 列旁侧）里，没有任何 mux/BEG 位落在既知编码之外。
2. 「残差 0」的前提必须写清：宇宙 = `law_cells`（族级位）**∪ 4 类非族级控制位**。少了后半，就会像本轮一样报 8 个假阳性 —— 它们不是"规律不适用"，是宇宙定义不完整。
3. DSP 列附近并未出现新的族级位型 ⇒ 「per 列差异」只发生在 HCLK_CMT（T70 的 4 套布局），INT 不随列变。

## 未完成
- BRAM 站点筛选未生效（`RAMB36*` 未匹配），本设计里 BRAM 是工具自由放置，未做定向验证；BRAM 的 180 条地址 mux 另见 T69（已被证明无法用差分隔离）。
- 混合设计未导出 `.pips`，无法做「PIP 列表相同」闸门与解码对账。

## 复现
```
python v7re/scripts/all_int_tiles_check.py --bit _mixed/mixed.bit
（白名单版：本文件 §白名单复验 的内联脚本）
```

## 六、白名单固化进检验脚本（2026-11-11）

`v7re/scripts/all_int_tiles_check.py` 已内置 `CONTROL_BITS`，载入宇宙时并入：

```
(0,16,1)                        GCLK 直通使能位（T41 / bitwriter.GCLK_PASS_BIT）
(1,3,0) (1,7,0) (1,31,0)        BYP/FAN 二级旁路，parity 0（T5 / T78）
(1,3,1) (1,7,1)                 同族旁路，parity 1（_c3/_c4 实测）
```

固化后对 12 个来源不同的位流复验（LUT 阵列、双 LUT、时钟、CCIO、DSP、BRAM、混合）：

```
检查 bitstream: 12 个
累计覆盖 INT tile 实例: 12,958 / 53,100（24.40%）
窗口内置位总数: 69,626；落在格宇宙外的: 0
判定: PASS（所有观测到的 INT tile 同一套规则）
```

其中新增抓到并登记的两格来自 `_c3.bit` / `_c4.bit`（`INT_L_X8Y20`，`(fo=1, bit=7/3, parity=1)`），
即 T5 当年记下但一直没接入检验的 FAN 旁路位。这说明白名单机制本身有效：它把"已知但未登记"的位从噪声变成清单。
