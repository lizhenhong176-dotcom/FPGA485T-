# -*- coding: utf-8 -*-
"""子节号 2.x → 3.x，并同步 STATUS §96 里的交叉引用。"""
import io

REP = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\PIP_PROGRESS_20261108.md"
ST = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"

t = io.open(REP, encoding="utf-8").read()
for a, b in [("### 2.5 ", "### 3.5 "), ("### 2.4 ", "### 3.4 "), ("### 2.3 ", "### 3.3 "),
             ("### 2.2 ", "### 3.2 "), ("### 2.1 ", "### 3.1 ")]:
    assert t.count(a) == 1, (a, t.count(a))
    t = t.replace(a, b)
io.open(REP, "w", encoding="utf-8", newline="\n").write(t)
print("report subsections ->", [l for l in t.split("\n") if l.startswith("### ")])

s = io.open(ST, encoding="utf-8").read()
subs = [("全文 §2.1", "全文 §3.1"), ("全文 §2.2", "全文 §3.2"), ("全文 §2.3", "全文 §3.3"),
        ("全文 §2.4", "全文 §3.4"), ("全文 §2.5", "全文 §3.5"), ("全文 §四", "全文 §五")]
for a, b in subs:
    if a in s:
        s = s.replace(a, b)
        print("ref", a, "->", b)
io.open(ST, "w", encoding="utf-8", newline="\n").write(s)
print("STATUS lines:", s.count("\n") + 1, "| bad:", s.count("\ufffd"))
