# -*- coding: utf-8 -*-
"""把本会话的三节（原 §65/§66/§67）移到文件末尾并改号为 §76/§77/§78，
避开另一会话 T37/T38/T39 已占用的 65/66/67。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()

# 切块：每个 "## N. " 标题到下一个 "## " 前
parts = re.split(r"(?m)^(?=## )", txt)
head = parts[0]
blocks = parts[1:]

def num(b):
    m = re.match(r"## (\d+)\.", b)
    return int(m.group(1)) if m else None

mine = {}
for b in blocks:
    n = num(b)
    if n in (65, 66, 67) and "T37" not in b.split("\n")[0] and "T38" not in b.split("\n")[0] and "T39" not in b.split("\n")[0]:
        title = b.split("\n")[0]
        if title.startswith("## 65. PIP 复用发生在哪一层") or \
           title.startswith("## 66. `(frame_off, parity, bit)`") or \
           title.startswith("## 67. band / row / tile"):
            mine[n] = b

if len(mine) == 3:
    keep = [b for b in blocks if b not in mine.values()]
    new = {65: 76, 66: 77, 67: 78}
    moved = []
    for old in (65, 66, 67):
        b = mine[old]
        first, rest = b.split("\n", 1)
        renamed = re.sub(r"^## \d+\.", "## %d." % new[old], first)
        renamed = renamed.replace("（2026-11-07）", "（2026-11-07，原 §%d，因 T37–T39 占号顺延）" % old, 1)
        moved.append(renamed + "\n" + rest)
    out = head + "".join(keep) + "".join(moved)
    io.open(P, "w", encoding="utf-8", newline="\n").write(out)
    print("moved:", [b.split("\n")[0] for b in moved])
else:
    print("not found, count=", len(mine))

t = io.open(P, encoding="utf-8").read()
nums = [int(n) for n in re.findall(r"(?m)^## (\d+)\.(?!\d)", t)]
print("strict sections:", len(nums), "max:", max(nums))
print("dup:", sorted({n for n in nums if nums.count(n) > 1}))
print("order ok:", nums == sorted(nums))
print("lines:", t.count("\n") + 1, "ufffd:", t.count("\ufffd"))
