# -*- coding: utf-8 -*-
"""Append a STATUS.md section pointing at PROGRESS_20261116.md (auto max+1 numbering)."""
import io, re, sys

ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
nums = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\. ", txt)]
n = (max(nums) if nums else 0) + 1

SEC = u"""## __N__. 进度汇报（2026-11-16，面向导师/评审）

提示词：`step03_pip/PROMPT_PROGRESS_20261116_V1.md` → `PROMPT_PROGRESS_20261116_V2.md`（MCP `optimize-user-prompt` / `iterate-prompt`）。
成稿：`step03_pip/PROGRESS_20261116.md`（六节：一句话结论 / 主线与边界 / 分层进度表 / 增量 / 缺口账 / 下一步三件事 + 能宣称两句）。

- 汇报口径的一句话结论：公式化覆盖 **3,552/3,634 = 97.7%**（分母 = `law_cells` INT_L 的 sense=1 feature 数），外部真值 **844/844 活跃 tile 唯一解、FP 0**。
- 分层进度表按「已验证（外部真值/真实位流）」与「仅自洽（同表两种求和）」**分列**，不再合并成一个状态词（本轮新增的写作纪律）。
- 缺口账按「影响 × 可修性」排序，每行带「修它需要什么前提」；首位 = ECC 地址项 `A(frame)` 未定（阻挡可加载位流）。
- 字数 775 汉字（限 1,200），`\\ufffd`=0。

"""

SEC = SEC.replace("__N__", str(n))
assert SEC not in txt
out = txt.rstrip("\r\n") + "\r\n\r\n" + SEC.replace("\n", "\r\n")
io.open(ST, "w", encoding="utf-8", newline="").write(out)
print("appended section", n, "| sections:", len(nums) + 1, "| bytes:", len(out.encode("utf-8")))
