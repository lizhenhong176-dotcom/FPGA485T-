# -*- coding: utf-8 -*-
"""law_cells(sense=1) 统计每族扇入 + 线长等级分类。"""
import sqlite3, collections, json, re

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = db.execute(
    "select family, src_wire from law_cells where tile_type='INT_L' and sense=1"
).fetchall()
fan = collections.defaultdict(set)
for f, s in rows:
    fan[f].add(s)
print("族数:", len(fan), "feature 总数:", sum(len(v) for v in fan.values()))
print("扇入分布:", dict(sorted(collections.Counter(len(v) for v in fan.values()).items())))

# 按前缀归类
def grp(f):
    for p in ("IMUX_L", "BYP_", "BYP_ALT", "FAN_", "EE2BEG", "WW2BEG", "EE4BEG", "WW4BEG",
              "NE6BEG", "NW6BEG", "SE6BEG", "SW6BEG", "NN2BEG", "SS2BEG", "NL1BEG", "NR1BEG",
              "SL1BEG", "SR1BEG", "CLK_", "CTRL_", "GFAN", "LV_", "LVB_", "LH"):
        if f.startswith(p):
            return p
    return f

g = collections.defaultdict(list)
for f in fan:
    g[grp(f)].append(f)
for p in sorted(g, key=lambda k: -len(g[k])):
    fs = g[p]
    print("%-10s %3d 族  扇入=%s" % (p, len(fs), sorted({len(fan[f]) for f in fs})))
