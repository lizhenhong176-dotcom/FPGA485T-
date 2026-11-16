# -*- coding: utf-8 -*-
"""把另一会话后加的 `## 70. A 类 tile 验证` 改号 §84 并移到文件末尾。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
parts = re.split(r"(?m)^(?=## )", txt)
head, blocks = parts[0], parts[1:]

tgt = [b for b in blocks if b.split("\n")[0].startswith("## 70. A 类 tile 验证")]
print("found:", [b.split("\n")[0] for b in tgt])
if len(tgt) == 1:
    b = tgt[0]
    first, rest = b.split("\n", 1)
    first = "## 84. A 类 tile 验证：协议成立，首批实测（2026-11-08，原 §70，与 §70 歧义评估撞号顺延）"
    rest = rest.lstrip("\n")
    moved = first + "\n" + rest
    keep = [x for x in blocks if x is not b]
    txt = head + "".join(keep) + moved
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
print("sections:", len(ns), "max:", max(ns), "dup:", sorted({n for n in ns if ns.count(n) > 1}), "monotonic:", ns == sorted(ns))
print("lines:", txt.count("\n") + 1, "ufffd:", txt.count("\ufffd"))
