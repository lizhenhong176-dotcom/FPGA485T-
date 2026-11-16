# -*- coding: utf-8 -*-
"""把 T37/T38/T39 三节（§65/§66/§67）移到 §64 之后，使文件内编号单调。"""
import io, re

P = r"E:\DEEPSEEK\FPGA比特流逆向\STATUS.md"
txt = io.open(P, encoding="utf-8").read()
parts = re.split(r"(?m)^(?=## )", txt)
head, blocks = parts[0], parts[1:]

def num(b):
    m = re.match(r"## (\d+)\.", b)
    return int(m.group(1)) if m else None

ts = [b for b in blocks if num(b) in (65, 66, 67) and re.match(r"## 6[567]\. T3[789]", b)]
print("found T blocks:", [b.split("\n")[0] for b in ts])

if len(ts) == 3:
    rest = [b for b in blocks if b not in ts]
    out, inserted = [], False
    for b in rest:
        out.append(b)
        if num(b) == 64 and not inserted:
            out.extend(ts)
            inserted = True
    txt = head + "".join(out)
    io.open(P, "w", encoding="utf-8", newline="\n").write(txt)

t = io.open(P, encoding="utf-8").read()
ns = [int(m.group(1)) for m in re.finditer(r"(?m)^## (\d+)\.(?!\d)", t)]
print("count:", len(ns), "max:", max(ns), "dup:", sorted({n for n in ns if ns.count(n) > 1}))
print("monotonic:", ns == sorted(ns), "strict+1:", ns == list(range(1, max(ns) + 1)))
print("lines:", t.count("\n") + 1, "ufffd:", t.count("\ufffd"))
