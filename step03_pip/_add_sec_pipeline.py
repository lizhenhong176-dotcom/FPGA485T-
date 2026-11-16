# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 流水线视角：INT tile 规律是怎么被处理出来的（2026-11-13）

- 交付 `step03_pip/INT_TILE_LAW_PIPELINE.md`（16 节）：九阶段（S1 位流→位矩阵 / S2 帧→tile 基址 / S3 受控差分 / S4 差异→cell 三元组 / S5 三套结构判据 / S6 两轴归属 / S7 172 族分桶 / S8 生成器 / S9 四支路验证），每阶段写「输入/处理(≤15 行伪代码)/输出/判据/真实数字/失败分支」。
- 关键新增表格：§11 一条真实连接的九阶段形态（`INT_R_X37Y199` 的 `SS6END0->>SS2BEG0`）、§12 数据量演进（162,168,832 位 → 88,358,400 建模位 → 8,900 记录 → 3,634 连接 → 1,598 格 → ~600 数字，总压缩 ≈2.7×10⁵）、§13 表结构演进、§14 「600 个数字重建 8,900 条记录」的 3 条前提、§15 12 行文字流程图。
- 提示词：`PROMPT_INT_PIPELINE_V1.md`（1,048 字符）→ `_V2.md`（1,524 字符，MCP；V2 增：表结构演进、每阶段失败分支、三套判据完整写法+真实反例、压缩代价、文字流程图）。
- 该文只整理既有实测，不新增实验；所有数字指向 `step03_pip/` 现有脚本（§16 索引）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("status", n, "lines", t.count("\n")+1, "ufffd", t.count("\ufffd"))