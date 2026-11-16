# -*- coding: utf-8 -*-
"""G5：逐族统计 (类→code) 与 (方向→行) 的自由度；20 源族的口径也要先看清。"""
import sqlite3, collections, re, itertools

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

# 20 源族长什么样
for f, d in fam.items():
    if len(d) == 20:
        print("20 源族样例：", f)
        for s in sorted(d):
            print("   ", s.ljust(24), slot(d[s]))
        break

# 20 源族的 code 取值统计
c20 = collections.Counter()
r20 = collections.Counter()
for f, d in fam.items():
    if len(d) != 20:
        continue
    for s, fos in d.items():
        r, c = slot(fos)
        c20[c] += 1
        r20[r] += 1
print("\n20 源族 code 分布：", dict(sorted(c20.items())))
print("20 源族 row 分布：", dict(sorted(r20.items())))

# 64 个 24 源族：方向→行 的置换种类
CLS = {"EE": ("axis", "E"), "WW": ("axis", "W"), "NN": ("axis", "N"), "SS": ("axis", "S"),
       "NE": ("diag", "N"), "NW": ("diag", "W"), "SE": ("diag", "S"), "SW": ("diag", "S"),
       "EL": ("longL", "E"), "WL": ("longL", "W"), "NL": ("longL", "N"), "SL": ("longL", "S"),
       "ER": ("rline", "E"), "WR": ("rline", "W"), "NR": ("rline", "N"), "SR": ("rline", "S")}

def cls_of(name):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|EL|WL|NL|SL|ER|WR|NR|SR)", name)
    return CLS[m.group(1)] if m else (None, None)

perm_by_cls = collections.defaultdict(collections.Counter)
code_by_cls = collections.defaultdict(collections.Counter)
for f, d in fam.items():
    if len(d) != 24:
        continue
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    tmp = collections.defaultdict(dict)
    cd = collections.defaultdict(set)
    for s, (r, c) in slots.items():
        k, dirn = cls_of(s)
        if k:
            tmp[k][dirn] = r
            cd[k].add(c)
    for k, m in tmp.items():
        if len(m) == 4:
            perm_by_cls[k][tuple(sorted(m.items()))] += 1
    for k, v in cd.items():
        if len(v) == 1:
            code_by_cls[k][list(v)[0]] += 1

print("\n各类的『方向→行』置换种类数：")
for k in ("axis", "diag", "longL", "rline"):
    print(f"  {k}: 种类 {len(perm_by_cls[k])}，最常见 {perm_by_cls[k].most_common(2)}")
print("\n各类的 code 取值：")
for k in ("axis", "diag", "longL", "rline"):
    print(f"  {k}: {dict(code_by_cls[k])}")
