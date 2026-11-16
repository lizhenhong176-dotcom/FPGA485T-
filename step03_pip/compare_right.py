# -*- coding: utf-8 -*-
"""本地：用统一窗口基准后的差异，与 INT_R|IMUX6 编码表逐源比对。"""
import base64
import json
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
B64 = open(os.path.join(HERE, "_diffs2.b64"), encoding="ascii").read().strip()

obs = defaultdict(set)
for line in base64.b64decode(B64).decode().strip().splitlines():
    src, df, w, bit = line.split(",")
    obs[src].add((int(df), int(w), int(bit)))

cells = defaultdict(set)
for r in json.load(open(os.path.join(HERE, "imux_cells.json"), encoding="utf-8")):
    if r["tile_type"] == "INT_R" and r["mux"] == "IMUX6" and r["sense"]:
        cells[r["src_wire"]].add((r["df"], 23, r["bit"]))

ok = bad = 0
for src in sorted(obs):
    if obs[src] == cells.get(src, set()):
        ok += 1
    else:
        bad += 1
        print("%-14s obs=%s cells=%s" % (src, sorted(obs[src]), sorted(cells.get(src, set()))))
print("equals: %d/%d" % (ok, ok + bad))
