# S56 PLL 属性位实测（站点 PLLE2_ADV_X0Y0，帧 32638/32639）

日期：2026-11-11　基线：MULT=4, CLKOUT0_DIVIDE=8, DIVCLK=1, PHASE=0, DUTY=0.5,
BANDWIDTH=OPTIMIZED, STARTUP_WAIT=FALSE, REF_JITTER1=0.010

## 1. 单属性差分（只统计 32638/32639 内非 word-50 位）

| 变体 | 改动 | 置 1 | 置 0 |
|---|---|---|---|
| `s_wait1` | STARTUP_WAIT FALSE→TRUE | **(98, 1)** | — |
| `s_do10` | CLKOUT0_DIVIDE 8→10 | (77,0) (77,3) | — |
| `s_phase45` | CLKOUT0_PHASE 0→45 | **(77, 8)** | — |
| `s_duty25` | CLKOUT0_DUTY 0.5→0.25 | (77,0) (77,3) | (77,4) |
| `s_mult5` | MULT 4→5 | (80,11) | (94,30) |
| `s_div2` | DIVCLK 1→2（MULT 4→8 保 VCO） | (80,1) (80,4) (81,15) (94,23) | (80,0) (80,3) (80,22) (94,20) (94,29) |
| `s_bwlow` | BANDWIDTH OPT→LOW | — | (94,20) (94,22) (94,29) |
| `s_cout1` | 启用 CLKOUT1 (DIVIDE=4) | (77,22) | (77,27) |

## 2. PLL 的 word 平面

| word | 承担的属性 |
|---|---|
| **w77** | CLKOUT0_DIVIDE / CLKOUT0_PHASE / CLKOUT0_DUTY / CLKOUT1 使能 |
| **w80** | MULT 低位 + DIVCLK |
| **w81** | DIVCLK 粗段 |
| **w94** | MULT 高位 + BANDWIDTH |
| **w98** | STARTUP_WAIT |

与 S55 的 MMCM 平面（w2 / w12 / w25 / w26 / w29 / w21）**完全错开**，两槽各自一套 word 号。

## 3. 可靠结论

| 项 | 结论 | 置信 |
|---|---|---|
| STARTUP_WAIT | `(w98,b1)`，FALSE=0 / TRUE=1 | A |
| CLKOUT0_PHASE | `(w77,b8)`，0→45 置 1 | A（单点） |
| CLKOUT0_DIVIDE 8→10 | `(77,0)(77,3)` 置 1 | A |
| CLKOUT0_DUTY 0.5→0.25 | `(77,0)(77,3)` 置 1，`(77,4)` 清 0 | A |
| MULT 4→5 | `(80,11)` 置 1、`(94,30)` 清 0 | A（单点） |
| DIVCLK 1→2 | `(80,0)(80,3)(80,22)(94,20)(94,29)` 清 0，`(80,1)(80,4)(81,15)(94,23)` 置 1 | B（与 MULT 联动） |
| BANDWIDTH LOW | `(94,20)(94,22)(94,29)` 清 0 | A |
| CLKOUT1 使能 | `(77,22)` 置 1、`(77,27)` 清 0 | A |
| REF_JITTER（MMCM 侧实测） | 不编码 | A |

**编码形态**：与 MMCM 同构 —— MULT / DIVIDE 都是**分段码**（值不同则 cell 集互不嵌套），
单比特属性（PHASE 相位步、STARTUP_WAIT、BANDWIDTH）是**开关位**。

## 4. 复现

`PLLE2_ADV #(.CLKOUT0_DIVIDE(..), .CLKFBOUT_MULT(..), .DIVCLK_DIVIDE(..), .CLKOUT0_PHASE(..),
.CLKOUT0_DUTY_CYCLE(..), .BANDWIDTH(..), .STARTUP_WAIT(..), .REF_JITTER1(..), .CLKIN1_PERIOD(5.0))`
+ `BUFG` 反馈环 + 综合后 `set_property LOC PLLE2_ADV_X0Y0` + DRC NSTD-1/UCIO-1 降级；VCO 800–1600 MHz。
