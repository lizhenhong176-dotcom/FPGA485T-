import json, collections
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
rows = []
for tag, rec in sorted(d.items(), key=lambda kv: int(kv[1]["sink"].split("_L")[1])):
    mux = rec["sink"]
    srcs = rec["sources"]
    cells = collections.Counter()
    for s, m in srcs.items():
        for f, w, b in m:
            cells[(f, b)] += 1
    rows.append((mux, len(srcs), len(cells), sorted(cells.items(), key=lambda kv: -kv[1])[:4]))
for r in rows[:40]:
    print(r[0], "srcs", r[1], "cells", r[2], "top", r[3])
