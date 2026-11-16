# -*- coding: utf-8 -*-
"""给 STATUS.md 追加 §74：row 的三种含义 + 复用缺口账。"""
import io

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """## 74. row 的三种含义 + 复用还差多少（2026-11-08）

文档 `step03_pip/PIP_REUSE_STRUCTURE.md` §7/§8；复算 `step03_pip/_q_grid_check.py`。

**row 三义**：①**网格行** r∈0..5，帧 = **16+r**（帧 16..21），只存在于 64 个 mux 族（其余 108 族该区为 0）；②**tile 的 Y** 0..349，决定 word（`word=2*(Y%50)+parity`）；③帧内 word 槽位 0..100。①与②正交，互不决定。

**6×4 网格实测（IMUX_L40，24 源）**：每行 4 个源共用 1 个行格；4 个列码为 `{25}`、`{24}`、`{25,24,23}`、`{25,24,22}`，故**前 2 列 4 格、后 2 列 2 格**（与「前 2 列 2 格」的表述相反，已按数据更正）。行格用位：r∈{0,1,4,5}→bit6，r∈{2,3}→bit7（配对位 S）。每族 2 格源/4 格源各 12 个（64 族一致，`(12,12)×64`），全 mux 区 768/768。

**缺口账（三种口径）**：
| 口径 | 进度 | 剩余 |
|---|---|---|
| A 地址可公式化 | **160/172 = 93.0%** | 12 族 = 7.0%（6 时钟/控制 + 6 长线），覆盖 178/3,634 = 4.9% feature |
| A+B 源→槽位顺序可推 | **0/1,536 = 0%** | 槽位顺序由布线邻接决定，是数据不是规律，须用 `v7_routing.db` 重建 |
| A+B+C 跨 tile 类型 | 0/4 类 | CLB/DSP/BRAM 未做同口径列重统计 |
| A+B+D 跨器件 | 未测 | 只有 XC7VX485T-2 |

**推论**：说「复用已解 93%」只对「地址律」成立；说「复用已解决」则不成立——槽位顺序 0% 可推，跨类型/器件未测。
"""

txt = io.open(STATUS, encoding="utf-8").read()
assert "## 74. row 的三种含义" not in txt
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(txt.rstrip() + "\n\n" + SEC)
t = io.open(STATUS, encoding="utf-8").read()
print("ok lines", len(t.splitlines()), "fffd", t.count(chr(0xFFFD)))
