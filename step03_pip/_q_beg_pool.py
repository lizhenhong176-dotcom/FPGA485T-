# -*- coding: utf-8 -*-
"""G16：96 个 20 源 BEG 族的位池长什么样？源能否按「同码」自然分 4 组？"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

for name in ("EE2BEG0", "SS2BEG0", "IMUX_L40"):
    d = fam[name]
    frames = sorted({fo for cs in d.values() for fo, p, b in cs})
    print(f"\n== {name}：{len(d)} 源，涉及帧 {frames}")
    for s in sorted(d):
        cs = sorted(d[s])
        print("   ", s.ljust(22), cs)

# 全局：20 源族的帧集合
f20 = [f for f, d in fam.items() if len(d) == 20]
fr = collections.Counter()
for f in f20:
    for cs in fam[f].values():
        for fo, p, b in cs:
            fr[fo] += 1
print("\n20 源族（", len(f20), "个）的 frame_off 分布：", dict(sorted(fr.items())))
