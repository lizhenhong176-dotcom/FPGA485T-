# S60 · GTX（GTXE2_CHANNEL）配置帧区首次定位

日期：2026-11-11　设备：xc7vx485tffg1157-3　bitstream：20,273,538 B（大端，`FDRI burst = 5,067,776 = 50,176×101`）

## 1. 为什么必须自建设计

扫远端 `/opt/lzh` 全部 194 个用户级 `.v`：**0 个含 GTX/PCIE 实例**（194 个命中全是 Vivado 安装目录里的 unisim 原语定义）。7,987 个 bitstream 里也没有 GTX 设计 ⇒ 无现成语料，只能自建探针。

## 2. 最小可用 GTX 探针（可构建 + 可布线的写法）

```verilog
(* DONT_TOUCH = "true" *) GTXE2_CHANNEL #(
  .CPLL_FBDIV(2), .CPLL_FBDIV_45(5), .TXOUT_DIV(4), .RXOUT_DIV(4),
  .TX_DATA_WIDTH(20), .RX_DATA_WIDTH(20)) u_gt (
  .CPLLREFCLKSEL(3'b001), .GTRESETSEL(1'b0), .GTTXRESET(1'b0), .GTRXRESET(1'b0),
  .GTGREFCLK(clk), .TXOUTCLK(txclk_raw), .CPLLLOCK(cpll_lock),
  .CPLLREFCLKLOST(cpll_lost), .CPLLFBCLKLOST(fb_lost));
(* DONT_TOUCH = "true" *) BUFG  u_bg (.I(txclk_raw), .O(txclk));
(* DONT_TOUCH = "true" *) FDRE  u_ff (.C(txclk), .CE(1'b1), .D(1'b1), .R(1'b0), .Q(o));
```

只需要 **8 个端口**即可实例化（`Synth 8-350 requires 230 connections, but only 8 given` 只是 warning）。

### 必踩的 4 个门（顺序不能错）

| 门 | 报错 | 修法 |
|---|---|---|
| TXOUTCLK 直驱 FF | `DRC REQP-1739 GTx R/TXOUTCLK drives inappropriate load` | 中间插 `BUFG`（`LOC BUFGCTRL_X0Y0`） |
| 无参考时钟 | `DRC REQP-51 must_use_ref_clock` | 用 `GTGREFCLK`（fabric 时钟进 GTX） |
| GTGREFCLK 被禁 | `DRC REQP-52 connects_GTGREFCLK_ACTIVE` | DRC 降级 |
| DRC 降级写法 | `ERROR: [Vivado 12-2485] Invalid severity {Warning}` | 用 `set_property SEVERITY Warning [get_drc_checks REQP-51]`（**不要加花括号**），且必须在 `place_design` **之前** |

可用豁免集合：`REQP-51 REQP-52 REQP-1739 NSTD-1 UCIO-1`（外加 `CFGBVS GND` + `CONFIG_VOLTAGE 1.8 [current_design]`）。

## 3. 实测：GTX 配置位在哪

设计矩阵（同一 RTL，只改一个参数或 LOC）：

| 设计 | 变量 | 差异帧 | 差异 cell（剔除 word 50） |
|---|---|---|---|
| t0→t1 | `CPLL_FBDIV` 2→4 | **31507** | `(w1, b16) 0→1` |
| t0→t2 | `TXOUT_DIV` 4→8 | **31506** | `(w12, b0) 0→1`、`(w12, b2) 0→1` |
| t0→t3 | `TX_DATA_WIDTH` 20→40 | 31504–31507 | `(31504,w4,b14)1→0`、`(31505,w4,b14)0→1`、`(31506,w4,b25)0→1`、`(31507,w4,b24)1→0` |

⇒ **GTX 列块 = 帧 31476..31507**（block base 31476 = 31508−32，紧接 band0 第一个 CLB 块 31508 之前），**word 平面是 0..100 全宽**（不是 `wof(Y)`，与 CMT 同类）。

### 通道间 word 偏移（两个独立属性交叉确认）

**属性 A：`CPLL_FBDIV` 2→4**（每通道各一对设计 c[0-3]a/c[0-3]b，同参数只改 LOC）

| LOC | 差异 cell | 相对 Y0 偏移 |
|---|---|---|
| X0Y0 | `(31507, w1, b16)` 0→1 | 0 |
| X0Y1 | `(31507, w23, b16)` 0→1 | **+22** |
| X0Y2 | `(31507, w58, b16)` 0→1 | **+57** |
| X0Y3 | `(31507, w80, b16)` 0→1 | **+79** |

**属性 B：`TXOUT_DIV` 4→8**（同四通道，独立验证）

| LOC | 差异 cell | 与 A 一致？ |
|---|---|---|
| X0Y0 | `(31506, w12, b0/b2)` | ✓ |
| X0Y1 | `(31506, w34, b0/b2)` | ✓ (+22) |
| X0Y2 | `(31506, w69, b0/b2)` | ✓ (+57) |
| X0Y3 | `(31506, w91, b0/b2)` | ✓ (+79) |

⇒ **通道平面基址 = 0 / 22 / 57 / 79**（两属性零偏差）。四通道铺满整帧 101 字；**不等距**（22 / 35 / 22 / 22），中段 Y1 多 13 字（暂归因于该通道附带的额外字段，【未定形】）。

### 四通道 = 四个 quad？

把 LOC 从 `X0Y0` 换到 `X1Y0`（跨 quad），差异出现在 **帧 27286/27287** ⇒ quad X1 的 GTX 块 = `[27286−32, 27286)`，即「某 CLB 块基址 −32」的 32 帧块。band0 的 quad X0 为 `[31476, 31508)`，同样满足「下一 CLB 块基址 −32」。

### word 50

GTX 块里**每一帧的 word 50 都随配置变化（5–9 位）** ⇒ GTX 块的 word 50 是帧级校验字（与 S58 对 io72/edge30 的结论一致），不是配置。

## 4. 入库

`v7_law.sqlite.v7_verified` 167 → **173**（6 行 `tile_type='GTXE2_CHANNEL'`：BLOCK/col_base、CPLL_FBDIV、TXOUT_DIV×2、TX_DATA_WIDTH×2）。

## 5. 下一步

1. **通道 word 平面定形**：对 4 个通道各跑 3–4 个参数（`TXOUT_DIV`/`PMARESET_TIME`/`RXCDR_CFG`），用「同字段跨通道」对齐，把 0/22/57/79 的规律做实。
2. **RX 侧**：`RX_DATA_WIDTH`、`RXCDR_CFG`、`RX_CM_TRIM` 等（本批只测 TX 侧三个参数）。
3. **GTXE2_COMMON**（14 个 site，参考时钟缓冲与 CPLL 共用）：单独定位。
4. **PCIE_* tile**（2 块 246 帧的 pcie 类块）仍是空白。

## 6. 续测：RX 字段与 GTXE2_COMMON（2026-11-11）

| 设计 | 变量 | 差异 cell（剔除 w50） |
|---|---|---|
| r1 | `RX_DATA_WIDTH` 20→40 | `(31504,w4,b14) 1→0`、`(31505,w4,b14) 0→1` |
| r2 | `RX_CM_TRIM` 4→5 | `(31505,w4,b8) 0→1` |
| r3 | `RXSLIDE_MODE` OFF→AUTO（`SHOW_REALIGN_COMMA=FALSE`） | `(31504,w16,b7) 0→1`、`(31505,w16,b10) 1→0` |
| m1→m2 | `GTXE2_COMMON.QPLL_FBDIV` 4→5 | `(31506,w45,b16) 0→1` |

### 三个结论

1. **`w4` 的 b14 对是「数据位宽」共用位**：`TX_DATA_WIDTH` 20→40 也动这对（外加 `w4 b25/b24` 两个 TX 专属位），`RX_DATA_WIDTH` 只动这对 ⇒ b14 对 = 收发共用的 DATA_WIDTH 编码，b25/b24 对 = TX 独有。
2. **`GTXE2_COMMON` 与 channel 共处同一组帧（31506/31507）**，其平面基址 = **w45** —— 正好落在 Y1 那段「多出来的 35 字」区间（22..56）内，**解释了之前"通道不等距 22/35/22"里多出的 13 字**：不是 Y1 的额外字段，而是 COMMON（QPLL）的平面。
3. `GTXE2_COMMON` 的存在还会点亮若干「时钟/参考通路」位（`f2588 w42 b20`、`f7834 w42 b20`、`f7834 w93 b8`、`f28818 w42 b20` 等，均 1→0），即 QPLL/REFCLK 使能散布在 edge30 块里 —— 与 S53 的 BUFGCTRL 结论同族。

### 修正后的 GTX 帧平面表（当前最佳模型）

```
帧 31506  word 0..21   → channel Y0
          word 22..44  → channel Y1
          word 45..56  → GTXE2_COMMON (QPLL)
          word 57..78  → channel Y2
          word 79..100 → channel Y3
帧 31507  同上切分，另一组配置字（CPLL/数据宽度等）
帧 31476..31505 → TX/RX 逻辑、PCS/PMA、参考时钟通路等大块
```

## 7. COMMON 的 quad 归属（7 个 quad 全部定位）

对 `GTXE2_COMMON_X0Y0..X0Y6` 各建一份设计（只改 LOC），逐份与 `X0Y0` 基线差分，取「非 w50 有变化」的帧聚簇：

| quad | 该 quad 的 GTX 块（32 帧） | 推导式 | 实测簇首 |
|---|---|---|---|
| `X0Y0` | `[31476, 31508)` | 31748 − 272 | 31476 |
| `X0Y1` | `[26230, 26262)` | 26502 − 272 | 26230 |
| `X0Y2` | `[0, 32)` | 272 − 272 | 0 |
| `X0Y3` | `[5246, 5278)` | 5518 − 272 | 5246 |
| `X0Y4` | `[10492, 10524)` | 10764 − 272 | 10492 |
| `X0Y5` | `[15738, 15770)` | 16010 − 272 | 15738 |
| `X0Y6` | `[20984, 21016)` | 21256 − 272 | 20984 |

**规则：`quad i` 的 GTX 块 = `band_base(i) − 272`，长度 32 帧。** 7/7 精确命中（`band_base` 为该 band 的 CLB 列帧基址：31748 / 26502 / 272 / 5518 / 10764 / 16010 / 21256）。

通道编号与 quad 的对应：`GTXE2_CHANNEL_X0Y0..Y27`，**quad = Y ÷ 4**（Y4 实测落在 quad1 的 26230 簇，与 COMMON_X0Y1 同簇）。

全片 56 个 channel = 2 × 28，14 个 COMMON = 2 × 7 —— 两块 die 半区（X0 / X1）各 7 个 quad，各 quad 一个 32 帧块。

### 差分里要剔除的固定噪声

每次换 LOC 都会连带出现同一批「fabric/时钟通路」帧（`31516/31521/31551/31556`、`31684–31686`、`31827–31829`、`31963–31965`、`32100/32171/32235/32299`、`27286–27361`、`28818`、`2588/2589`、`7834`）—— 这是 `BUFG`/I/O 端口未约束造成的布线差异，与 GTX 无关，实验时必须按「簇首 = band_base−272」取，不能按“有差异”取。

## 8. X1 半区复核：`+5212` 半区偏移

方法修正（很重要）：LOC 扫描的差分里噪声太多，**改用「同一 LOC、只改一个参数」的成对实验**，差异就只剩该参数的那一位。

| 成对实验 | 差异 cell |
|---|---|
| `X0Y0` QPLL_FBDIV 4→5 | `(31506, w45, b16) 0→1` |
| `X1Y0` QPLL_FBDIV 4→5 | `(36718, w45, b16) 0→1` |
| `X1Y2` QPLL_FBDIV 4→5 | `(5242, w45, b16) 0→1` |

⇒ **X1 半区 = X0 半区 + 5212 帧**（36718 − 31506 = 5242−0 = 5212，两者一致），且 QPLL 位在块内的相对位置（w45、块首+30）完全相同。

于是 7 个 quad 的块基址在两半区都满足同一条规则：

```
block_base(half, quad i) = band_base(i) − 272 + (half==X1 ? 5212 : 0)
```

`X1Y0 → 36688`、`X1Y2 → 5212` 两个独立实测点均符合。
