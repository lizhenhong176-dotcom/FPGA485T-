# -*- coding: utf-8 -*-
"""P1b：A 端点是否只由源名决定（跨 96 个 BEG 族稳定）？B 端点是否只由源的几何类别决定？"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)1", s):
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"

# A/B 用 frame 区间区分：先看各族两端点的帧集合
pools = collections.Counter()
for f, d in fam.items():
    if len(d) != 20:
        continue
    frames = sorted({fo for cs in d.values() for fo, _, _ in cs})
    pools[tuple(frames)] += 1
print("20 源族的帧集合（前 5 种）：")
for k, v in pools.most_common(5):
    print("  ", k, v)

# 选 A 端点 = 帧较小的那批（6..11），B = 12..15
a_of_name = collections.defaultdict(collections.Counter)
b_of_name = collections.defaultdict(collections.Counter)
for f, d in fam.items():
    if len(d) != 20:
        continue
    for s, cs in d.items():
        cs = sorted(cs)
        a_cell = [c for c in cs if c[0] <= 11]
        b_cell = [c for c in cs if c[0] >= 12]
        if len(a_cell) == 1 and len(b_cell) == 1:
            a_of_name[s][(a_cell[0][0], a_cell[0][1], a_cell[0][2])] += 1
            b_of_name[s][(b_cell[0][0], b_cell[0][1], b_cell[0][2])] += 1

def stable(m):
    return sum(1 for v in m.values() if len(v) == 1), len(m)
print(f"\nA 端点跨族稳定（唯一）：{stable(a_of_name)[0]}/{stable(a_of_name)[1]} 个源名")
print(f"B 端点跨族稳定（唯一）：{stable(b_of_name)[0]}/{stable(b_of_name)[1]} 个源名")

# 按几何类看 B 是否稳定
g2b = collections.defaultdict(collections.Counter)
for s, v in b_of_name.items():
    for cell, n in v.items():
        g2b[geo(s)][cell] += n
print("\n几何类 -> B 端点（计数）：")
for g in sorted(g2b):
    print("  ", g.ljust(8), dict(sorted(g2b[g].items())))
