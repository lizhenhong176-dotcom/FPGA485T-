# -*- coding: utf-8 -*-
"""G9：16 种配置之间是什么关系？是否 = 「基础排列 × 镜像(r→3-r) × 码标签互换」？
以及 IMUX_L0..47 各自落在哪种配置（配置是不是由序号决定的）。"""
import sqlite3, collections, re

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

fam_conf = {}
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if len(d) != 24 or any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    cc, perm = {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag in ("axis", "longL", "rline"):
            perm.setdefault(tag, {})[dirn] = r
        if tag != "other":
            cc.setdefault(tag, set()).add(c)
    cc = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    fam_conf[f] = (perm, cc)

# 把所有 (perm, code) 归一化成「基础型 + 变换」
def norm(perm, cc):
    out = []
    for tag in ("axis", "longL", "rline"):
        m = perm[tag]
        out.append(f"{tag}:" + "".join(str(m[d]) for d in ("E", "N", "S", "W")))
    out.append("code:" + f"{cc['axis']}/{cc['longL']}")
    return " ".join(out)

variants = collections.Counter(norm(*v) for v in fam_conf.values())
print("16 种配置：")
for k, n in variants.items():
    print(f"  {n}×  {k}")

# 镜像检验：perm 与 3-r 是否成对出现
def mirror(m): return {k: 3 - v for k, v in m.items()}
pairs = []
bytag = collections.defaultdict(set)
for f, (perm, cc) in fam_conf.items():
    for tag in ("axis", "longL", "rline"):
        bytag[tag].add(tuple(sorted(perm[tag].items())))
for tag, s in bytag.items():
    ms = {tuple(sorted(mirror(dict(t)).items())) for t in s}
    print(f"\n{tag}: 排列 {len(s)} 种；镜像闭合 = {s == ms}")

# IMUX_L0..47 的配置归属
print("\nIMUX_L 族的配置（E行/N行/S行/W行 axis | axis码/longL码）：")
for n in range(48):
    f = f"IMUX_L{n}"
    if f in fam_conf:
        perm, cc = fam_conf[f]
        m = perm["axis"]
        print(f"  IMUX_L{n:<3} axis=({m['E']},{m['N']},{m['S']},{m['W']}) "
              f"codes={cc['axis']}/{cc['longL']} "
              f"longL=({perm['longL']['E']},{perm['longL']['N']},{perm['longL']['S']},{perm['longL']['W']})")
