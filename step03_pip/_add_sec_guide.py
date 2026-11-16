# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. 术语+流程+覆盖指南（2026-11-13）

- 交付 `step03_pip/INT_EXPERIMENT_GUIDE.md`（167 行 / 8 节）：§2 **24 条术语四列表**（定义/本项目取值/真实例子/常见误解）、§3 单个 PIP 的端到端样例（`INT_R_X37Y199` 的 `SS6END0->>SS2BEG0`，两格 `(11,0,10)(13,0,10)`）、§4 八步流程（目的/做法/判据/产出/不做会怎样）、§5 六条"为什么"（替代方案/否掉原因/否掉会犯什么错）、§6 **覆盖三层账**、§7 六个易错概念、§8 复算入口。
- 提示词：`PROMPT_INT_GUIDE_V1.md`（1,636 字符）→ `_V2.md`（2,113 字符，MCP）。
- **覆盖结论（新核对的精确口径，与旧稿的 59 不一致）**：一个 INT tile 3,737 条 = **3,629 条有位记录的信号 PIP（97.1%）+ 64 条 `VCC_WIRE` 常量（1.7%）+ 44 条直通（1.2%）**；`law_cells` 3,634 与模板 3,629 差 **5** 条（长线跨族选源拼写差异，**未核实**）。
- 两个分母必须分开说：按 tile 内 PIP 算规则覆盖 **3,552/3,737 = 95.0%**；按 `law_cells` 特征算 **3,552/3,634 = 97.7%**。
- 器件级：**7,474/35,126 = 21.3%**（仅 INT_L/INT_R，单器件）；未覆盖的 27,652 条中 D 类密集多源占 15,518（44.2%）。补齐估算 **25–35 人日**。
- 脚本：`_q_cover_tile.py`（四类分解）、`_q_cover_pairs.py`（law vs 模板 归一化比对：tpl 3,737 / law 3,634 / law_only 5 / tpl_only 108 = 64 VCC + 44 直通）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("status_section", n, "lines", t.count("\n")+1, "ufffd", t.count("\ufffd"))