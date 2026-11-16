# -*- coding: utf-8 -*-
"""P1f：BEG 的 Q 轴逐族体检（4 个 Q 节点的几何类别构成）。"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
beg = {f: d for f, d in fam.items() if len(d) == 20}

def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)", s):
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"

sig = collections.Counter()
for f, d in beg.items():
    cells = {s: sorted(cs) for s, cs in d.items()}
    deg = collections.Counter()
    for cs in cells.values():
        for c in cs:
            deg[c] += 1
    Q = {n for n in deg if deg[n] == 5}
    cols = collections.defaultdict(list)
    for s, cs in cells.items():
        for c in cs:
            if c in Q:
                cols[c].append(s)
    pat = []
    for c in sorted(cols):
        gs = sorted({geo(s) for s in cols[c]})
        pat.append("+".join(gs))
    sig[tuple(pat)] += 1

print("Q 轴几何类别签名（按 frame 排序）：")
for k, v in sig.most_common(12):
    print(f"   {v:>3}  ", k)

# 抽 3 族打印 Q 列明细
import random
random.seed(3)
for f in random.sample(sorted(beg), 3):
    d = beg[f]
    cells = {s: sorted(cs) for s, cs in d.items()}
    deg = collections.Counter()
    for cs in cells.values():
        for c in cs:
            deg[c] += 1
    Q = {n for n in deg if deg[n] == 5}
    cols = collections.defaultdict(list)
    for s, cs in cells.items():
        for c in cs:
            if c in Q:
                cols[c].append(s)
    print(f"\n{f}:")
    for c in sorted(cols):
        print("   ", c, [(s, geo(s)) for s in sorted(cols[c])])
