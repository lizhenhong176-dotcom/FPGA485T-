# -*- coding: utf-8 -*-
"""G1 探针：取出 mux 族的 (src -> row r, col code c) 槽位表，看源名与槽位的关系。"""
import sqlite3, json, re, collections

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
cur = con.cursor()

TT = "INT_L"
rows = cur.execute(
    "select family, src_wire, frame_off, bit, parity from law_cells "
    "where tile_type=? and sense=1", (TT,)).fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

# 列重：为了区分行格(重4)/列格
cellcount = collections.Counter()
for f, d in fam.items():
    for s, cells in d.items():
        for c in cells:
            cellcount[c] += 1

def slot_of(cells, fam_cells):
    """返回 (r, code) 或 None：行格 = 该族列重恰好 4 的格；列格 = 其余（code 位）。"""
    rows_hit = []
    code = 0
    for (fo, p, b) in cells:
        if cellcount[(fo, p, b)] == 4 and fo in (16, 17, 18, 19, 20, 21):
            rows_hit.append(fo - 16)
        elif fo in (22, 23, 24, 25):
            code |= 1 << (25 - fo)
    if len(rows_hit) != 1:
        return None
    return rows_hit[0], code

by_size = collections.Counter(len(d) for d in fam.values())
print("family 数：", len(fam), "| 源数分布：", dict(sorted(by_size.items())))

# 挑 24 源族看全貌
show = [f for f, d in fam.items() if len(d) == 24][:3]
for f in show:
    print("\n==", f)
    for s in sorted(fam[f]):
        print("   ", s.ljust(24), slot_of(fam[f][s], fam[f]))

# 槽位填充统计（24 源族）
full = 0
grids = collections.Counter()
for f, d in fam.items():
    if len(d) != 24:
        continue
    slots = [slot_of(d[s], d) for s in d]
    if any(x is None for x in slots):
        continue
    full += 1
    grids[tuple(sorted(slots))] += 1
print("\n24 源族可解槽位：", full, "| 槽位集合种类：", len(grids))
