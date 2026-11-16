# S53 时钟树测绘（第一部分）

日期：2026-11-11　器件：xc7vx485tffg1157-3

## 1. 时钟脊（clock spine）块定位

全片 1,038 个帧块里，`kind='edge30'` 的 12 个 30 帧块就是时钟脊：

| band | base | band | base |
|---|---|---|---|
| 2 | 2562 | 3 | 7370 |
| 3 | 7808 | 4 | 12616 |
| 4 | 13054 | 5 | 17862 |
| 5 | 18300 | 6 | 23108 |
| 6 | 23546 | 1 | 28792 |
| 0 | 33600 | 0 | 34038 |

每 band 两个（上/下时钟脊）。此前统计到的"word 50 非零的 157 帧"主要就落在这里。

## 2. BUFGCTRL：CE 使用位

设计对：`c0_bufg`（BUFG，CE 硬接 1）vs `c1_bufgce`（BUFGCE，CE=1'b1）。
差分：**唯一配置位 = `base 7808 + off26, word 93, bit 5 = 1`**（其余 7 位是 word 50 校验位）。

⇒ BUFGCTRL 家族里"CE 端口被使用"这一位在 (off26, w93, b5)。

## 3. BUFHCE：站点配置簇 + CE 约束位

三个设计（同一切片负载、只改 BUFHCE 的 CE）：`c2`(CE=1) / `c3`(CE=port) / `c4`(CE=0)，站点 `BUFHCE_X0Y0`。

- `c2 − c4`（CE 常量 1 vs 0）：**唯一配置位 = `base 34038 + off27, word 48, bit 19 = 1`**。
- `c3 − c2`（CE 走 fabric）：新增 4 个 tile 上的 `(base 34038 + {off19,22,24,25}, word 49, bit {16,17})` —— 这是 fabric CE 网在各时钟馈送点的标记位，不是 BUFHCE 本身。

站点扫描（`h0`=X0Y0、`h5`=X0Y5、`h10`=X0Y10，均 BUFHCE CE=1）给出每站点 4 位簇：

| 设计 | 点位 |
|---|---|
| h0 (X0Y0) | (off26,w48,b31) (off27,w48,b19) (off27,w48,b23) (off27,w48,b25) |
| h5 (X0Y5) | (off28,w49,b31) (off29,w49,b19) (off29,w49,b23) (off29,w49,b25) |
| h10 (X0Y10) | (off0,w48,b25) (off0,w48,b26) (off1,w48,b21) (off1,w48,b24) (off16,w49,b8) (off24,w49,b8) (off26,w52,b15) (off27,w52,b3) (off27,w52,b7) (off27,w52,b9) |

结论：**每个 BUFHCE 站点占一个"帧对 + 行 word"槽**，位图固定为 {b31} ∪ {b19,b23,b25}；相邻站点沿 (off +2, word +1) 平移。h10 出现在多个位置说明该站点被复制到两处（或 LOC 未生效）。

## 4. MMCM：倍数/分频位

设计对：`m0`(MULT=4, DIV=1, CLKOUT0_DIVIDE=8, VCO 800MHz) vs `m1`(MULT=6, DIV=1, DIVIDE=12, VCO 1200MHz)，输出都是 100 MHz。

差分：28 位，其中 **16 位非 word-50**，全部落在 **帧 27392 / 27393**：

| 帧 | word | 位 |
|---|---|---|
| 27392 | 12 | b0 0→1 |
| 27392 | 25 | b10 1→0, b18 1→0 |
| 27392 | 26 | b28 0→1, b31 0→1 |
| 27393 | 12 | b11 1→0 |
| 27393 | 25 | b9 1→0, b10 0→1, b17 1→0, b18 0→1 |
| 27393 | 26 | b27 1→0, b28 0→1, b30 1→0, b31 0→1 |
| 27393 | 29 | b27 0→1, b30 0→1 |

⇒ MMCM 的 MULT/DIV 配置区在 **帧 27392/27393**（属 base 27322 的 72 帧块尾部），word 12/25/26/29 —— **不是** INT/CLB 的 wof(Y) 行字规则，CMT 块另有词映射（待测）。

## 5. 构建约束（复现必读）

- MMCM VCO 必须落在 **600–1600 MHz**：`CLKFBOUT_MULT_F=16` + `CLKIN1_PERIOD=5.0` 得 3200 MHz → `ERROR: [DRC PDRC-34]`，`route_design` 直接失败。
- **BUFR 无法驱动被 LOC 锁在 fabric 的 FF**：`ERROR: [Place 30-176] Unroutable Placement`（BUFR 只能驱动本时钟区域内的负载）⇒ 做 BUFR 实验必须把 FF 放在同一 region。
- BUFG 的 LOC 不生效：`REF_NAME =~ BUFGCTRL` 匹配不到 `BUFG`（BUFG 是独立 primitive），需按 `REF_NAME == BUFG` 单独写；`g0` 与 `g4` 位流完全相同即为证据。
- BUFHCE 的 LOC 有效（`BUFHCE_X0Yk`）。

## 6. 尚未完成

- edge30 / CMT 块的 word 映射（目前只知道"站点→(off, word)"是平移关系，缺基准锚）。
- BUFR / BUFIO / BUFMRCE / PLL 未测。
- HCLK_{L,R,CLB,INT_INTERFACE,BRAM,DSP,...} 共 3,020 个 tile 的位区未定位。
