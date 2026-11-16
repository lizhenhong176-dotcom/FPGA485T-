# S54 CMT（MMCM/PLL）配置区定位与 word 平面切分

日期：2026-11-11　器件：xc7vx485tffg1157-3

## 1. 站点与帧的对应（实测锚点）

用同一 MMCM 属性、只改 `LOC` 的三份设计（`n0`=X0Y0、`n1`=X0Y1、`n2`=X0Y2）定位：

| 站点 | CMT tile | 名称 Y | 配置帧 | 所属块 |
|---|---|---|---|---|
| `MMCME2_ADV_X0Y0` | `CMT_TOP_R_LOWER_B_X88Y9` | 9 | **32638 / 32639** | io72 base 32568（band0）+70/+71 |
| `MMCME2_ADV_X0Y1` | `CMT_TOP_R_LOWER_B_X88Y61` | 61 | **27392 / 27393** | io72 base 27322（band1）+70/+71 |
| `MMCME2_ADV_X0Y2` | `CMT_TOP_R_LOWER_B_X88Y113` | 113 | **1130 / 1131** | io72 base 1092（band2）+70/+71 |

⇒ **规则：CMT 配置帧 = 该 band 的 io72 块基址 + 70 / +71（块内最后两帧）。** 站点沿 band 递增（Y = 9 + 52·band）。

## 2. word 是"属性平面"，不是行字

对同一站点 `X0Y0` 只改 `CLKFBOUT_MULT_F`（4 → 6，输出频率保持 100 MHz），得 14 个非校验位，全部落在 32638/32639，**word 只出现 12 / 25 / 26 / 29**：

| 帧 | word | 位变化 |
|---|---|---|
| 32638 | 12 | b0 0→1, b8 0→1 |
| 32638 | 25 | b9/b10/b17/b18 1→0 |
| 32638 | 26 | b28/b31 0→1 |
| 32639 | 12 | b1/b11 1→0 |
| 32639 | 25 | b8/b16 0→1 |
| 32639 | 26 | b28/b31 0→1 |
| 32639 | 29 | b28/b31 0→1 |

同一站点、同一帧位置，**PLL**（`PLLE2_ADV_X0Y0`，`CMT_TOP_R_UPPER_T_X88Y44`）的 MULT 4→8 变化落在**同一对帧** 32638/32639，但 word 是 **77 / 80 / 81 / 94**：

| 帧 | word | 位变化 |
|---|---|---|
| 32638 | 77 | b1/b4 1→0 |
| 32638 | 80 | b1/b4 0→1 |
| 32638 | 81 | b13 1→0, b14/b15 0→1, b21 1→0, b22/b23 0→1 |
| 32638 | 94 | b20 1→0 |
| 32639 | 77 | b1/b4 0→1 |
| 32639 | 80 | b0/b3 1→0 |
| 32639 | 81 | b14/b22 1→0 |
| 32639 | 94 | b23 0→1, b29 1→0 |

⇒ **word 编号 = CMT 内的属性槽位**：LOWER 槽（MMCM）占低位 word（12/25/26/29），UPPER 槽（PLL）占高位 word（77/80/81/94）。这是全项目第一个**非 wof(Y) 的 word 规则**，只出现在 CMT 块。

## 3. 与时钟脊的关系

- `edge30` 块（12 个）= BUFGCTRL / BUFHCE / BUFIO 等水平时钟资源；
- `io72` 块的 +70/+71 = **CMT（MMCM/PLL）**；
- 二者都在"时钟脊"列上，但属于不同块类型，位区互不重叠。

## 4. 复现配方

```
BUFG u_fb(.I(clkfb), .O(ckfb_buf));
MMCME2_ADV #(.CLKOUT0_DIVIDE_F(8.0), .CLKFBOUT_MULT_F(4.0), .DIVCLK_DIVIDE(1),
             .CLKIN1_PERIOD(5.0)) u_mm(.CLKIN1(clk), .CLKFBIN(ckfb_buf),
             .CLKFBOUT(clkfb), .CLKOUT0(ck), .PWRDWN(1'b0), .RST(1'b0));
# LOC: set_property LOC MMCME2_ADV_X0Yk [get_cells u_mm]   （综合后！）
# 约束: create_clock -period 5.000 [get_ports clk]
# DRC: NSTD-1 / UCIO-1 降级为 Warning
# VCO 必须在 600–1600 MHz（MULT_PERIOD 换算），否则 DRC PDRC-34 且 route 失败
```
PLL 同理，`PLLE2_ADV`，VCO 800–1600 MHz，LOC 到 `PLLE2_ADV_XkYk`。

## 5. 未完成

- MMCM/PLL 的逐属性位元表（`CLKOUT0_DIVIDE`、`CLKOUT_PHASE`、`DUTY_CYCLE`、`BANDWIDTH`、`REF_JITTER` 等约 20 个属性）未逐位取名；目前只证实"落在哪两帧、哪些 word"。
- `BUFIO / BUFR / BUFMRCE` 未测（BUFR 受 `Place 30-176` 限制）。
- 3,020 个 `HCLK_*` tile 的位区未定位。
