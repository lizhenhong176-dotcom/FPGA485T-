# -*- coding: utf-8 -*-
"""另一会话后加的 §68/§69（并行机时、远端资源复核）与本会话 §68/§69 撞号，
把它们改号 §81/§82 并移到文件末尾。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
parts = re.split(r"(?m)^(?=## )", txt)
head, blocks = parts[0], parts[1:]

def num(b):
    m = re.match(r"## (\d+)\.", b)
    return int(m.group(1)) if m else None

targets = []
for b in blocks:
    t = b.split("\n")[0]
    if t.startswith("## 68. 并行机时与首批跨 tile 实测") or t.startswith("## 69. 远端机器资源复核"):
        targets.append(b)

print("found:", [b.split("\n")[0] for b in targets])
if len(targets) == 2:
    keep = [b for b in blocks if b not in targets]
    moved = []
    for b, new in zip(sorted(targets, key=lambda x: num(x)), (81, 82)):
        first, rest = b.split("\n", 1)
        old = num(b)
        first = re.sub(r"^## \d+\.", "## %d." % new, first)
        first = first.replace("（2026-11-08）", "（2026-11-08，原 §%d，因 §68/§69 已被命名不对称与数量对账占用而顺延）" % old, 1)
        moved.append(first + "\n" + rest)
    txt = head + "".join(keep) + "".join(moved)
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", txt)]
print("sections:", len(ns), "max:", max(ns), "dup:", sorted({n for n in ns if ns.count(n) > 1}), "monotonic:", ns == sorted(ns))
print("lines:", txt.count("\n") + 1, "ufffd:", txt.count("\ufffd"))
