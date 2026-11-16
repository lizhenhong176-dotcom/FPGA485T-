# -*- coding: utf-8 -*-
"""追加 STATUS §80：PIP/mux 物理形态与家族长度的两种口径。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()

SEC = """
## 80. PIP / mux 的物理形态 + 「家族长度」的两种口径（2026-11-08）

【硬件事实】PIP = 两段 wire 之间由配置 SRAM 位控制的可编程连接点（传输门/缓冲开关），不是软件路由表项。mux = **共用一个目的 wire 的一组 PIP**，组内互斥是电路事实（一个目的 wire 同时只能被一条源驱动），不是工具约定。家族（本项目术语）= 一个目的 wire + 其全部候选源 ≡ 一个 mux。switch box = tile 内全部 mux + 直通。

【数据事实】INT_L tile（`uniform=1`）：600 wire / **3,737 PIP** / 216 目的 wire；其中 172 个目的 wire 扇入>1（= 172 个家族）含 **3,693** PIP，44 个扇入=1 直通 PIP；`3,693+44 = 3,737` ✔；`law_cells` 3,634 = 3,693 − 59 个 `VCC_WIRE` 常量输入（§69）。

**「家族的长度」有两种，必须分开说**：

1. **扇入长度**（多少候选源，`law_cells` sense=1 按 `(family,src)` 去重 3,634 条）：`24 → 64 族`（`IMUX_L0..L47` 48 + `BYP_ALT0..7` 8 + `FAN_BOUNCE*` 8，即 6×4 网格那批）、`20 → 96 族`（方向线族 `EE2/WW2/EE4/WW4/NE6/NW6/SE6/SW6/NN2/SS2/NL1/SL1/EL1/ER1…` 各 4 变体）、`18 → 2`（`LVB_L0/L12`）、`16 → 6`（`CLK_L0/L1`、`CTRL_L0/L1`、`GFAN0/1`）、`12 → 3`（`LH0`、`LV_L18`、另一 `LH`）、`10 → 1`（`LV_L0`）；合计 172 族 / 3,634 feature ✔。

2. **线长等级**（命名自带，数字 = 跨几个 tile）：`…1…`=1（单线）、`…2…`=2（双线）、`…4…`=4（四线）、`…6…`=6（六线）、`LV/LVB`=长竖线、`LH`=长横线。【数据事实】`tileconn.json` 实测：`LV_L0` 自连偏移到 (0,11)、对外到 `INT_L` **17 行**；`LVB_L0` 到 11 行；`LH0` 到 **14–23 列**；`SE6BEG0`→`INT_R` (1,1)(1,2)(1,3)；`EE2BEG0`→(1,0)；`EE4BEG0`→(2,0)；而 `IMUX_L40`/`BYP_ALT0`/`FAN_BOUNCE7` **无自连**（目的 wire 不出本 tile）。

**结论**：172 族里只有 **4 族**（`LV_L0`、`LV_L18`、`LVB_L0`、`LVB_L12`）的目的 wire 是长线；其余 168 族的 mux 都只在本 tile 工作，「长度」体现在**它接收的源线是 1/2/4/6 档还是长线**。`band = 50 行 = 一个 clock region`（`band_rows=50`、5,246 帧/band）正是长线的活动尺度。

【未测/禁讲】INT tile 内 mux 是传输门树还是多级缓冲树、几级、24 个源的物理相邻关系；`6×4` 只是组合逻辑上的乘积，不保证硅片排成 6 行 4 列（§79.3）。

详见 `step03_pip/PIP_MUX_PHYSICAL_AND_SPAN.md`；复算 `_q_fanin3.py`、`_q_family_span.py`、`_q_span_examples.py`、`_q_pip_reconcile.py`。

"""

if "## 80. PIP / mux 的物理形态" not in txt:
    txt = txt.rstrip("\n") + "\n" + SEC
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
print("sections:", len(ns), "max:", max(ns), "dup:", sorted({n for n in ns if ns.count(n) > 1}), "monotonic:", ns == sorted(ns))
print("lines:", txt.count("\n") + 1, "ufffd:", txt.count("\ufffd"))
