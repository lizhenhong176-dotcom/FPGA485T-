# T74：CLKIN1 的「类别字段」定位（word 48 bit21/22）

日期：2026-11-10　器件 `xc7vx485tffg1157-3`　远端 `/opt/lzh/v7re/work/clk3`，本地 `_ck3/`

## 1. 想做什么

T73 留下「类别字段未解」：`MUX_MMCM_CLKIN1` 的 30 个源分属 CCIO / CK_BUFHCLK / MUX_CLK_* / MUX_CLK_MMCM* / MUX_CLK_PLL* 五类，
已知 CCIO 与 CK_BUFHCLK 两类的**索引**编码，但**类别本身**用哪些位没定。

## 2. 试了什么

| 设计 | 意图 | 结果 |
|---|---|---|
| `u1_mmcm2mmcm` | 让 `MMCME2_X0Y6.CLKOUT0` 去喂 `MMCME2_X1Y6.CLKIN1`（构造 MMCM 类源）| ✅ 构建成功，但**不是我要的拓扑** |
| `u2_pll2mmcm` | `PLLE2_X0Y6.CLKOUT0 → MMCME2_X1Y6.CLKIN1` | ❌ `PLLE2_ADV` 无 `CLKOUT0B..CLKOUT3B/CLKFBOUTB` 端口，删掉后又因 FF 落点为空报 `[Common 17-55]` |

`u1` 的实测拓扑（`.pips`）：

```
HCLK_CMT_CCIO0          ->> HCLK_CMT_MUX_MMCM_CLKIN1     ← CLKIN1 的源是引脚 CCIO0
HCLK_CMT_MUX_CLK_MMCM0  ->> HCLK_CMT_CK_IN0              ← MMCM0 去了另一个 mux
HCLK_CMT_MUX_CLK_MMCM0  ->> HCLK_CMT_MUX_CLK_0
```

即 **Vivado 不接受 MMCM→MMCM 直连作 CLKIN1**，它把引脚直接接进 CLKIN1，另把 MMCM0 引到 `CK_IN0`。
这个「拒绝」本身是结构性事实：`MUX_MMCM_CLKIN1` 的 30 源里，MMCM/PLL 那 22 条在单 CMT 设计里用不上。

## 3. 意外收获：拿到干净的 CCIO→CLKIN1 样本

`u1` 的 CLKIN1 源是 **CCIO0**（类别 CCIO），而 `t2`（T73）的 CLKIN1 源是 **CK_BUFHCLK0**（类别 BUFHCLK）。
两者引脚相同（都是 `C27`）、CMT 相同，唯一差别就是类别：

| 设计 | CLKIN1 源 | `(base+2, word48)` |
|---|---|---|
| `t2_bh72_c27` | `CK_BUFHCLK0` | `bits [21, 26]` |
| `u1_mmcm2mmcm` | `CCIO0` | `bits [22, 24]` |

⇒ **类别位在 `(base+2, word 48)` 的 bit21 / bit22**：bit21 = BUFHCLK 类，bit22 = CCIO 类。
`t2` 的 bit26 是 BUFHCLK 的槽位 0（T71），`u1` 的 bit24 是 CCIO 类的配套位（含义未定）。

## 4. 顺带排掉一个误归属

`u1` 与 `t2` 的 `(base+1, word 49)` **完全相同**（`bits [21,26,29,31]`）。
所以 T72 里我归到「CCIO 索引」的 word49 那几位，其实是 **`CCIO0 ->> MUX_CLK_13` 这条路的标记**，与 CLKIN1 的类别无关。
T72 §3 的表述需要按这条更正。

## 5. 当前 HCLK_CMT 编码账

| 字段 | 位置 | 状态 |
|---|---|---|
| CCIO 索引 | `(base+1, 51, 27/28)` 2 位二进制 | ✅ 8/8（T73）|
| BUFHCLK 槽位 | `(base+2, 48, 26/25/24/23…)` 6 槽 one-hot + bit21 半区 | ✅ 12/12（T71）|
| 类别 | `(base+2, 48, bit21=BUFHCLK / bit22=CCIO)` | 🟡 2 类已见，MMCM/PLL 类不可构造 |
| MMCM/PLL 作 CLKIN1 源 | — | ⛔ 单 CMT 构造下 Vivado 拒绝（本轮证实） |
| `MUX_CLK_4..13` 链式 | — | ⛔ 实测 0/264 设计出现（T73 前一轮）|

## 6. 复现

```bash
export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/clk3 && /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source u1_mmcm2mmcm.tcl
```

两个坑：跨 region 的时钟网必须 `CLOCK_DEDICATED_ROUTE FALSE`（否则 `Place 30-99 IO Clock Placer failed`）；
MMCM 的下游 FF 必须落在**下游 MMCM 所在 clock region**，否则 `Place 30-512`。
