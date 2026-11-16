# -*- coding: utf-8 -*-
"""G17：96 个 20 源 BEG 族的槽位结构 —— 它是 5×4 / 4×4 的乘积吗？码位是否又对上「线类」？"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

AX = {"EE": "axis", "WW": "axis", "NN": "axis", "SS": "axis",
      "NE": "diag", "NW": "diag", "SE": "diag", "SW": "diag",
      "EL": "longL", "WL": "longL", "NL": "longL", "SL": "longL",
      "ER": "rline", "WR": "rline", "NR": "rline", "SR": "rline"}
def cls(s):
    p = s[:2]
    if p in AX:
        return AX[p]
    if s.startswith(("LOGIC_OUTS", "GFAN")):
        return "logic"
    if s.startswith(("BYP_BOUNCE", "FAN_BOUNCE")):
        return "bounce"
    return "other"

stat = collections.Counter()
prod = collections.Counter()
for f, d in fam.items():
    if len(d) != 20:
        continue
    A, B = set(), set()
    edges = []
    for s, cs in d.items():
        cs = sorted(c for c in cs)
        if len(cs) != 2:
            stat["不是 2 格"] += 1
            continue
        a, b2 = cs[0], cs[1]
        A.add(a)
        B.add(b2)
        edges.append((a, b2, s))
    if stat["不是 2 格"]:
        continue
    stat[f"A{len(A)}×B{len(B)}"] += 1
    prod[(len(A), len(B), len(edges), len({(a, b) for a, b, _ in edges}))] += 1

print("20 源族规模统计：")
for k, v in sorted(stat.items()):
    print("  ", k, v)
print("\n(A数, B数, 边数, 不同边数)：", dict(prod))

# 码位（B）是否对应线类？取一个族看交叉表
f0 = "EE2BEG0"
print(f"\n{f0} 的 (A, B, 线类)：")
for s, cs in sorted(fam[f0].items()):
    cs = sorted(cs)
    print("   ", s.ljust(20), "A=", cs[0][0], "B=", cs[1][0], "类=", cls(s))

# 全局：B 帧 -> 线类分布
tab = collections.Counter()
for f, d in fam.items():
    if len(d) != 20:
        continue
    for s, cs in d.items():
        cs = sorted(cs)
        if len(cs) == 2:
            tab[(cs[1][0], cls(s))] += 1
print("\nB 帧 × 线类 交叉表：")
Bs = sorted({k[0] for k in tab})
cls_list = ["axis", "diag", "longL", "rline", "logic", "bounce", "other"]
print("B".ljust(5), *[c.rjust(8) for c in cls_list])
for b in Bs:
    print(str(b).ljust(5), *[str(tab[(b, c)]).rjust(8) for c in cls_list])
