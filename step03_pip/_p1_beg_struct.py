# -*- coding: utf-8 -*-
"""P1c：96 个 20 源 BEG 族的结构（cell 按 (frame, parity) 聚合，bit 在族内恒定）。"""
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

beg = {f: d for f, d in fam.items() if len(d) == 20}
print("20 源族数：", len(beg))

# 每族：bit 是否唯一？(frame,parity) 是否 9 个？
nb, nf = collections.Counter(), collections.Counter()
for f, d in beg.items():
    bits = {b for cs in d.values() for _, _, b in cs}
    fps = {frozenset((fo, p) for fo, p, _ in cs) for cs in d.values()}
    nb[len(bits)] += 1
    nf[tuple(sorted(set().union(*fps)))] += 1
print("族内不同 bit 数的分布：", dict(nb))
print("族内 (frame,parity) 池分布：")
for k, v in nf.most_common():
    print("   ", k, v)

# 取一族打印全表
for name in ["EE2BEG0", "WW2BEG0", "SS6BEG0"]:
    if name not in beg:
        continue
    d = beg[name]
    print(f"\n{name}:")
    tbl = {}
    for s, cs in sorted(d.items()):
        cell = sorted((fo, p) for fo, p, _ in cs)
        tbl[s] = cell
    afr = sorted({c[0] for c in [x for v in tbl.values() for x in v]})
    print("   帧集合:", afr)
    for s in sorted(tbl, key=lambda x: (geo(x), x)):
        print(f"   {s:<16} {geo(s):<6} {tbl[s]}")
