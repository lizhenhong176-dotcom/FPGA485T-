import io
import re

ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1

sec = """
## __N__. P1 补强第二轮：12 个设计、844 个 tile、零误报（2026-11-15）

**相较 §194 的变化**：第一轮 7 个设计（656 tile、TP 4,682、FP 0、FN 1,348）扩到**第二轮 12 个设计**——新增 `d8b_dense`（96 LUT 密集，修掉 d8 的组合环）、`d9_wide`（32 个 LUT6 全 6 输入）、`d10_long`（16 LUT 横跨最远列，压长线族）、`d11_mix`（24 LUT + 16 SRL16E）、`d12_fanout2`（2 源各驱动 48 LUT）。

### 汇总

| 指标 | 数值 |
|---|---|
| 设计数 | **12**（全部建成，各 20,273,538 B） |
| 活跃 INT tile | **844** |
| 唯一解 / 多解 / 零解 | **844 / 0 / 0** |
| TP / FP / FN | **5,940 / 0 / 1,400** |
| 精确率 | **1.000** |
| 召回（对全部真值行） | 0.8093 |
| 可检出行召回 | **5,940/5,940 = 100%** |
| 表外位（GCLK 时钟字段） | 164（d3 98 + d5 64 + d11 2） |
| 完全一致的 tile | 656/844 |

### FN 1,400 行逐条归因（`out/p1_residual.json`）

- 【数据事实】**775 行扇入=1 直通**（`pip_defs` 固定连接，无选择位）
- 【数据事实】**625 行常量源**（`VCC_WIRE`/`GND_WIRE` 驱动目的线，无可编程连接）
- 【数据事实】**真漏 0 行**（775 + 625 = 1,400，`misses` 为空）

### 分设计（`out/p1_replication.json`）

| 设计 | tile | 唯一解 | 表外位 | 完全一致 | TP | FP | FN | 精确率 | 召回 |
|---|---|---|---|---|---|---|---|---|---|
| d1_lut_chain | 31 | 31 | 0 | 26 | 183 | 0 | 63 | 1.000 | 0.744 |
| d2_lut_big | 56 | 56 | 0 | 45 | 590 | 0 | 103 | 1.000 | 0.851 |
| d3_carry | 125 | 125 | 98 | 40 | 2,392 | 0 | 605 | 1.000 | 0.798 |
| d4_fanout | 51 | 51 | 0 | 36 | 419 | 0 | 157 | 1.000 | 0.727 |
| d5_srl | 314 | 314 | 64 | 280 | 581 | 0 | 246 | 1.000 | 0.703 |
| d6_muxtree | 47 | 47 | 0 | 36 | 381 | 0 | 135 | 1.000 | 0.738 |
| d7_spread | 32 | 32 | 0 | 28 | 136 | 0 | 39 | 1.000 | 0.777 |
| d8b_dense | 44 | 44 | 0 | 31 | 761 | 0 | 23 | 1.000 | 0.971 |
| d9_wide | 39 | 39 | 0 | 37 | 122 | 0 | 4 | 1.000 | 0.968 |
| d10_long | 34 | 34 | 0 | 32 | 125 | 0 | 5 | 1.000 | 0.962 |
| d11_mix | 41 | 41 | 2 | 35 | 201 | 0 | 20 | 1.000 | 0.910 |
| d12_fanout2 | 30 | 30 | 0 | 30 | 49 | 0 | 0 | 1.000 | 1.000 |
| **合计** | **844** | **844** | **164** | **656** | **5,940** | **0** | **1,400** | **1.000** | **0.8093** |

### 关键工程细节（复现必须知道）

1. 一帧被同一 `(band,col)` 的 **50 个 tile 共享**，必须按 `word → row` 分位，否则全部解判零解（第一版踩过）。
2. 模型三元组是 **`(frame_off, bit, parity)`**，不是 `(frame_off, word, bit)`；word 由实例的 `Y%50` 现算。
3. word 50 是 ECC，必须跳过；不跳过会引入每帧 1 个字的结构性噪声。
4. 表外位（GCLK 时钟选择）需单列剔除，否则 96 个 tile 判零解；本轮共 164 个。
5. `d8_dense` 第一轮失败于 `DRC LUTLP-1`（组合环），改链式后成功；写 Verilog 时要自己先看有没有环。

### 边界

单器件 `xc7vx485tffg1761-2`、单类型 INT_L/INT_R（2/115）；真值是 Vivado 自身导出、**非硅片回读**；12 个设计均为小规模单时钟、无 BRAM/DSP 实例。

复算：`python step03_pip/gen_p1_designs2.py` → 远端 `bash run_new.sh` → `_dump.py out2` → `python step03_pip/p1_replication_cells.py` / `_q_p1_residual.py`；文档 `step03_pip/P1_REPLICATION.md`。
"""

sec = sec.replace("__N__", str(n))
nl = "\r\n" if "\r\n" in txt else "\n"
if not txt.endswith(nl):
    txt += nl
out = txt + sec.replace("\n", nl).lstrip("\r\n")
io.open(ST, "w", encoding="utf-8", newline="").write(out)
print("appended section", n, "| ufffd", out.count("\ufffd"), "| bytes", len(out.encode("utf-8")))
