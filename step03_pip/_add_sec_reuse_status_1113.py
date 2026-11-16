# -*- coding: utf-8 -*-
import io, re
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(ST, encoding="utf-8", newline="").read()
assert "\ufffd" not in txt
n = max(int(m) for m in re.findall(r"(?m)^## (\d+)\.", txt)) + 1
sec = """## __N__. PIP 复用规律现状盘点（2026-11-13）

按 `step03_pip/PROMPT_PIP_REUSE_STATUS_V2.md` 生成、并按 A/B/C 三档 + 缺陷账 + 自我攻击三节写成：**`step03_pip/PIP_REUSE_STATUS_20261113.md`**（80 行）。

**当日复跑（全部 2026-11-13）**
- `python step03_pip/gen_slots.py` → `[mux] 64/64`、`[BEG] 96/96（变体 32/32）`、`[复合] 96/96`、覆盖 **3,552/3,634 = 97.7%**、余 82 条（6 长线族）。
- `python v7re/scripts/verify_all_pip.py --tile-type INT_L|INT_R --normalize` → `家族 172`、`精确命中 3634（100.0%）`、`mux 1536/1536`、`beg 2098/2098`、不符 0、未覆盖 0。
- `python -m pytest v7re\\tests -q -p no:cacheprovider` → `15 passed in 0.37s`。

**三档结论（详见文档）**
- A 已证明 6 条（生成器闭合 / 校验双向 / 回归 15 passed / 复用度量 / 槽位编码 231,656 位 0 违例 / 真值 91.45%）。
- B 只有行为学证据 5 条（6×4 物理矩阵、列=长度类、BEG 二分、E5 全器件抽样、跨类型同形 19/32）。
- C 明确没做到 4 条（82 条长线无公式、行轴无版图证据=工具上限、跨类型 3/115、跨器件 0/1、26 帧块外与 word 50 未建模）。

**缺陷账排序（影响×可修性）**：①82 条长线（可修性高，判据 ≥80/82）②行轴版图证据（工具上限）③跨类型 3/115 ④跨器件 0/1 ⑤ECC 未闭合 ⑥位库粒度。

**自我攻击三条**（文档「如果我错了」节）：97.7% 是否自证（1 天：生成器不读 `law_cells` 直接比对，差异 ≤82 为通过）、列=长度类（≥95% 一致为通过）、跨类型同形（另选 `CK_BUFG_CASCO*` 复跑，≥50% 0 差异为成立）。

"""
sec = sec.replace("__N__", str(n))
io.open(ST, "w", encoding="utf-8", newline="").write(txt.rstrip() + "\n\n" + sec)
t = io.open(ST, encoding="utf-8", newline="").read()
print("section", n, "ufffd", t.count("\ufffd"), "lines", t.count("\n") + 1, "bytes", len(t.encode("utf-8")))