# -*- coding: utf-8 -*-
"""修进度报告的节号：插入「主线边界」后「二」重复，整体顺延为 一..七。"""
import io

P = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_PROGRESS_20261108.md"
t = io.open(P, encoding="utf-8").read()

pairs = [
    ("## 六、下一步优先级（只排主线：PIP 复用分析）", "## 七、下一步优先级（只排主线：PIP 复用分析）"),
    ("## 五、风险与边界", "## 六、风险与边界"),
    ("## 四、缺口账", "## 五、缺口账"),
    ("## 三、已作废结论", "## 四、已作废结论"),
    ("## 二、进度表", "## 三、进度表"),
]
for old, new in pairs:
    assert t.count(old) == 1, (old, t.count(old))
    t = t.replace(old, new)

t = t.replace("详见全文 §2.1", "详见 §3.1")  # 仅当出现时
io.open(P, "w", encoding="utf-8", newline="\n").write(t)

heads = [l for l in t.split("\n") if l.startswith("## ")]
print("lines:", t.count("\n") + 1, "| bad:", t.count("\ufffd"))
for h in heads:
    print(" ", h)
