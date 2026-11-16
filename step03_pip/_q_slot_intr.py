# -*- coding: utf-8 -*-
"""G15：INT_R 侧是否与 INT_L 同构（同样的 4 线类 × 4 方向结构、16 种配置）。"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
AX = {"EE": "E", "WW": "W", "NN": "N", "SS": "S"}
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}
def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return "extra", name

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

for TT in ("INT_L", "INT_R"):
    rows = con.execute("select family, src_wire, frame_off from law_cells "
                       "where tile_type=? and sense=1", (TT,)).fetchall()
    fam = collections.defaultdict(lambda: collections.defaultdict(set))
    for f, s, fo in rows:
        fam[f][s].add(fo)
    stat = collections.Counter()
    cfgs = collections.defaultdict(set)
    for f, d in fam.items():
        if len(d) != 24:
            continue
        slots = {s: slot(c) for s, c in d.items()}
        if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
            stat["非网格"] += 1
            continue
        per = collections.defaultdict(set)
        perm = collections.defaultdict(dict)
        for s, (r, c) in slots.items():
            tag, dirn = key(s)
            if tag == "extra":
                continue
            per[tag].add(c)
            if tag != "diag":
                perm[tag][dirn] = r
        stat["族"] += 1
        stat["类→code 唯一" if all(len(v) == 1 for v in per.values()) else "类→code 多值"] += 1
        stat["方向铺满 0..3" if all(sorted(v.values()) == [0, 1, 2, 3]
                                for v in perm.values() if len(v) == 4) else "未铺满"] += 1
        cfgs[TT].add((tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
                      tuple(sorted(perm["rline"].items()))))
    print(TT, dict(stat), "| 配置种数：", len(cfgs[TT]))

# 两侧配置是否逐条相等
la = collections.Counter()
lb = collections.Counter()
for TT, c in (("INT_L", la), ("INT_R", lb)):
    rows = con.execute("select family, src_wire, frame_off from law_cells "
                       "where tile_type=? and sense=1", (TT,)).fetchall()
    fam = collections.defaultdict(lambda: collections.defaultdict(set))
    for f, s, fo in rows:
        fam[f][s].add(fo)
    for f, d in fam.items():
        if len(d) != 24:
            continue
        slots = {s: slot(x) for s, x in d.items()}
        perm = collections.defaultdict(dict)
        for s, (r, cc) in slots.items():
            tag, dirn = key(s)
            if tag in ("axis", "longL", "rline"):
                perm[tag][dirn] = r
        if all(len(perm[t]) == 4 for t in ("axis", "longL", "rline")):
            c[(tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
               tuple(sorted(perm["rline"].items())))] += 1
print("\n两侧排列三元组集合相同：", set(la) == set(lb), "| 种类数：", len(la), len(lb))
