# -*- coding: utf-8 -*-
"""G7：非方位源的码归属是否固定？三类排列之间是否互相决定？"""
import sqlite3, collections, re, math

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
rows = con.execute("select family, src_wire, frame_off from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in rows:
    fam[f][s].add(fo)

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

AX = {"EE": "E", "WW": "W", "NN": "N", "SS": "S"}
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}
def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return ("other", name)

recs = []
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if len(d) != 24 or any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    cls_code, perm, extras = {}, {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "other":
            extras[s] = (r, c)
        else:
            cls_code.setdefault(tag, set()).add(c)
            if tag != "diag":
                perm.setdefault(tag, {})[dirn] = r
    cc = {k: list(v)[0] for k, v in cls_code.items() if len(v) == 1}
    recs.append((f, cc, perm, extras))

print("族数：", len(recs))

# 1) 非方位源 -> code 与哪个线类同码
aff = collections.defaultdict(collections.Counter)
for f, cc, perm, extras in recs:
    inv = {v: k for k, v in cc.items()}
    for s, (r, c) in extras.items():
        aff[s][inv.get(c, "?")] += 1
print("\n非方位源与哪个线类同码（族数统计）：")
for s in sorted(aff):
    print("  ", s.ljust(22), dict(aff[s]))

# 2) 排列自由度
def permkey(p): return tuple(sorted(p.items()))
combos = collections.Counter()
for f, cc, perm, extras in recs:
    if all(k in perm and len(perm[k]) == 4 for k in ("axis", "longL", "rline")):
        combos[(permkey(perm["axis"]), permkey(perm["longL"]), permkey(perm["rline"]))] += 1
print(f"\n三元排列组合种类：{len(combos)}（理论上界 24^3 = 13,824）")
# 给定 axis 排列时 longL/rline 是否有多种
cond = collections.defaultdict(set)
for (a, l, r), n in combos.items():
    cond[a].add((l, r))
print("给定 axis 排列时 (longL,rline) 的种类数：", [len(v) for v in cond.values()][:10])
# axis 排列 × 码归属 的联合
joint = collections.Counter()
for f, cc, perm, extras in recs:
    if "axis" in perm and len(perm["axis"]) == 4 and "axis" in cc and "longL" in cc:
        joint[(permkey(perm["axis"]), cc["axis"], cc["longL"])] += 1
print(f"axis排列 × (axis码, longL码) 联合种类：{len(joint)}")
