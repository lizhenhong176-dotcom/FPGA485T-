# -*- coding: utf-8 -*-
"""G1b：列码 c 是不是「源线名的属性」（跨族一致）？行号 r 是不是每族独立排列？"""
import sqlite3, collections, re

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
TT = "INT_L"
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type=? and sense=1", (TT,)).fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
cellcount = collections.Counter(c for d in fam.values() for cs in d.values() for c in cs)

def slot(cells):
    r, code = None, 0
    for (fo, p, b) in cells:
        if fo in (16, 17, 18, 19, 20, 21) and cellcount[(fo, p, b)] == 4:
            r = fo - 16
        elif fo in (22, 23, 24, 25):
            code |= 1 << (25 - fo)
    return r, code

# 1) 每个源名跨族的 code 集合
per_name = collections.defaultdict(set)
slots_all = {}
for f, d in fam.items():
    for s, cells in d.items():
        r, c = slot(cells)
        if r is None or c not in (1, 2, 7, 11):
            continue
        per_name[s].add(c)
        slots_all[(f, s)] = (r, c)

multi = {n: v for n, v in per_name.items() if len(v) > 1}
print(f"出现过的源名：{len(per_name)}；code 跨族唯一的：{len(per_name)-len(multi)}；不一致的：{len(multi)}")
for n, v in list(multi.items())[:8]:
    print("  不一致", n, sorted(v))

# 2) 每族内 code -> 行号集合，看行号是不是 0..n-1 排列
bad = 0
dist = collections.Counter()
for f, d in fam.items():
    per = collections.defaultdict(list)
    for s in d:
        if (f, s) in slots_all:
            r, c = slots_all[(f, s)]
            per[c].append(r)
    for c, rs in per.items():
        dist[len(rs)] += 1
        if sorted(rs) != list(range(len(rs))):
            bad += 1
print("每 (族, code) 的行号是否为 0..n-1 排列：违反", bad)
print("每 (族, code) 的行数分布：", dict(sorted(dist.items())))

# 3) 单个源名 -> code 的完整映射（前 20 个）
print("\n源名 -> code（跨族唯一者）：")
for n in sorted(per_name)[:24]:
    print("  ", n.ljust(22), sorted(per_name[n]))
