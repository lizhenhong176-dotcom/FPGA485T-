# -*- coding: utf-8 -*-
"""给 STATUS.md 追加 §72：进度汇报材料入口。"""
import io

STATUS = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

SEC = """## 72. 进度汇报材料（2026-11-08）

文档 `step03_pip/PROGRESS_REPORT_20261108.md`；提示词 `step03_pip/PROMPT_PROGRESS_REPORT_V1.md` → `_V2.md`（MCP 生成）。
内容：一页纸结论（148 字）/ 里程碑表（10 条，各带复算入口）/ 核心数字表（13 项，全带分母）/ 已完成 vs 未完成（未完成写清挡住什么）/ 「只能展示一张表」= 172 族构成表 / 三条风险与应答 / 三档下一步 / 已作废与不可靠清单 / 口头版（540 汉字，约 2 分半）/ 三个追问与应答 / 「首次/唯一」不使用声明。

口径要点：①覆盖率两侧 3,634/3,634，INT_R 必须先归一化（否则 2,312/3,634 = 63.6%）；②位库形状沿用 prjxray artix7，原创是地址律 + 160/172 生成式压缩 + 闭环 + 歧义量化；③已作废数据必须主动交代（sense 混算那一组）。
"""

txt = io.open(STATUS, encoding="utf-8").read()
assert "## 72. 进度汇报材料" not in txt
io.open(STATUS, "w", encoding="utf-8", newline="\n").write(txt.rstrip() + "\n\n" + SEC)
t = io.open(STATUS, encoding="utf-8").read()
print("ok lines", len(t.splitlines()), "fffd", t.count(chr(0xFFFD)))
