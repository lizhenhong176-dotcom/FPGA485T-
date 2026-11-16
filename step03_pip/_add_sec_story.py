# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 讲解稿：INT tile 族实验的思路 / 结果 / 问题（2026-11-13）

- 交付 `step03_pip/INT_TILE_FAMILY_EXPERIMENT_STORY.md`（298 行、11 节）：§3 八步链（每步写"排除了什么"）、§4 时间线（当时以为 → 后来改成）、§5 结果两列表（已外部验证 / 仅自洽分开）、§6 **17 个问题分五类**（数据获取/判读/统计/工具能力/文档脚本，每条含"没发现会得出什么错结论"）、§7 撤回表 7 行、§8 重做 10 条带代价、§9 缺口、§11 复算入口索引。
- 提示词：`step03_pip/PROMPT_INT_TILE_STORY_V1.md`（756 字符）→ `_V2.md`（1,281 字符，MCP `optimize-user-prompt` + `iterate-prompt`）；V2 追加六条硬要求（时间线专节、五类问题各≥2、错误结论必须带数字、撤回表、结果两列、重做 10 条带代价）。
- 稿中直接引用的最新数字：生成器 **3,552/3,634 = 97.7%** 0 差异；槽位不变量 **231,656 位 0 违例**；真值 1,155/1,263 = 91.45%；线长律 12,565 tile / 64,686 位表外 0；E8 50,176 帧全等；单 bit 检出 99.4438%；误报 240 位 / 120 tile（白名单后 0）。
- 该稿的定位：对外讲解件，不新增实验；所有数字均指向 `step03_pip/` 现有脚本（§11 索引）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("section", n, "lines", t.count("\n")+1, "ufffd", t.count("\ufffd"))