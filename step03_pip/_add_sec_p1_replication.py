import io
import re
import sys

ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
nums = [int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)]
n = max(nums) + 1

sec = """
## __N__. P1 级补强：7 个独立设计上的位级复现与真值对账（2026-11-15）

**一句话**：7 个结构互不相同的新设计、656 个活跃 INT tile，位坐标 + 精确覆盖解码 vs Vivado `get_pips` 真值 —— **精确率 100%（FP=0）**、**可检出行召回 100%（4,682/4,682）**；未检出的 1,348 行全部是结构上无配置位的连接（620 常量源 + 728 扇入=1 直通），**真漏 0**。

### 设计（`step03_pip/gen_p1_designs.py` → `tamper/ref/p1/`）

| 设计 | 结构 | 活跃 tile | 置位 | 构建 |
|---|---|---|---|---|
| d1_lut_chain | 24 级 LUT6 链 | 31 | 1,744 | OK |
| d2_lut_big | 64 LUT6 / 2 列×32 行 | 56 | 4,368 | OK |
| d3_carry | 16 级 32 位累加器链 | 125 | 25,340 | OK |
| d4_fanout | 1 驱动 64 LUT | 51 | 3,906 | OK |
| d5_srl | 32 SRL16E / 4 时钟区 | 314 | 3,908 | OK |
| d6_muxtree | 8 组×6 层 2:1 | 47 | 2,698 | OK |
| d7_spread | 16 LUT / 4 region | 32 | 1,264 | OK |
| d8_dense | 96 LUT 单 region | — | — | 失败 |

d8 失败原因：`ERROR: [DRC LUTLP-1] Combinatorial Loop Alert: 96 LUT cells form a combinatorial loop`（设计写成 `t[i] ← t[(i+1)%96] / t[(i+5)%96]`，确实成环；不是工具问题）。

### 结果（`out/p1_replication.json`）

| 设计 | tile | 唯一解 | 多解 | 零解 | 表外位 | 完全一致 | TP | FP | FN | 精确率 | 召回 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| d1_lut_chain | 31 | 31 | 0 | 0 | 0 | 26 | 183 | 0 | 63 | 1.000 | 0.744 |
| d2_lut_big | 56 | 56 | 0 | 0 | 0 | 45 | 590 | 0 | 103 | 1.000 | 0.851 |
| d3_carry | 125 | 125 | 0 | 0 | 98 | 40 | 2,392 | 0 | 605 | 1.000 | 0.798 |
| d4_fanout | 51 | 51 | 0 | 0 | 0 | 36 | 419 | 0 | 157 | 1.000 | 0.727 |
| d5_srl | 314 | 314 | 0 | 0 | 64 | 280 | 581 | 0 | 246 | 1.000 | 0.703 |
| d6_muxtree | 47 | 47 | 0 | 0 | 0 | 36 | 381 | 0 | 135 | 1.000 | 0.738 |
| d7_spread | 32 | 32 | 0 | 0 | 0 | 28 | 136 | 0 | 39 | 1.000 | 0.777 |
| **合计** | **656** | **656** | **0** | **0** | **162** | **491** | **4,682** | **0** | **1,348** | **1.000** | **0.7765** |

### 残差归因（`out/p1_residual.json`）

- 【数据事实】620 行常量源（`VCC_WIRE`/`GND_WIRE` 驱动目的线，无可编程连接）
- 【数据事实】728 行目的线扇入=1（`pip_defs` 固定连接，无选择位）
- 【数据事实】**真漏 0 行** ⇒ 可检出召回 = 4,682/4,682 = 100%

### 判据与唯一放宽处

判据与 G2 一致（obs → 去 3 个标记格 → 候选 ⊆ obs → 穷尽枚举要求 union == target → 恰 1 解）。
唯一放宽：`target` 中任何候选都覆盖不到的格（模型外位，GCLK 时钟字段）单列 `outside_bits` 后剔除，否则 96 个 tile 判零解。合计 162 个表外位（d3 98、d5 64），全在 `frame_off 0..2`。

### 边界

单器件 `xc7vx485tffg1761-2`、单类型 INT_L/INT_R（2/115）；真值为 Vivado 自身导出，**非硅片回读**；d8 未建成（样本 7）；表外位未解释编码。

复算：`python step03_pip/p1_replication_cells.py` / `python step03_pip/_q_p1_residual.py`；文档 `step03_pip/P1_REPLICATION.md`。
"""

sec = sec.replace("__N__", str(n))
# 保留原换行风格
nl = "\r\n" if "\r\n" in txt else "\n"
if not txt.endswith(nl):
    txt += nl
out = txt + sec.replace("\n", nl).lstrip("\r\n")
io.open(ST, "w", encoding="utf-8", newline="").write(out)
bad = out.count("\ufffd")
lines = out.count(nl)
print("appended section", n, "| lines", lines, "| ufffd", bad, "| bytes", len(out.encode("utf-8")))
