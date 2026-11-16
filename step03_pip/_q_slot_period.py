# -*- coding: utf-8 -*-
"""G11：每族的配置编号，找每个前缀的周期规律。"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
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

def sig(f):
    perm, cc = {}, {}
    for s, fos in fam[f].items():
        r, c = slot(fos)
        p = s[:2]
        for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
            if p in tab:
                if tag != "diag":
                    perm.setdefault(tag, {})[tab[p]] = r
                cc.setdefault(tag, set()).add(c)
    cc1 = {k: sorted(v)[0] for k, v in cc.items() if len(v) == 1}
    return (tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
            tuple(sorted(perm["rline"].items())), cc1.get("axis"), cc1.get("longL"))

grid = [f for f in fam if len(fam[f]) == 24 and all(
    slot(c)[0] is not None for c in fam[f].values())]
seen, order = {}, []
for f in sorted(grid):
    g = sig(f)
    if g not in seen:
        seen[g] = len(seen)
    order.append((f, seen[g]))

print("配置总数：", len(seen))
bypre = collections.defaultdict(dict)
for f, i in order:
    n = int(re.search(r"(\d+)$", f).group(1))
    bypre[re.sub(r"\d+$", "", f)][n] = i
for p, m in bypre.items():
    seq = [m[n] for n in sorted(m)]
    print(f"  {p:<9}", "".join(f"{x:>3}" for x in seq), " | n =", min(m), "..", max(m))

# 检查是否镜像成对：偶数位 vs 下一奇数位
def mirror(tp):
    return tuple(sorted((k, 3 - v) for k, v in tp))
pairs = 0
for p, m in bypre.items():
    for n in sorted(m):
        if n + 1 in m:
            a, b = seen and None, None
print("\n镜像检验（同块内 n 与 n+1 的 axis 排列是否互为 3-r）：")
byidx = {}
for f, i in order:
    n = int(re.search(r"(\d+)$", f).group(1))
    byidx[(re.sub(r"\d+$", "", f), n)] = i
inv = {i: g for g, i in seen.items()}
for p, m in bypre.items():
    res = []
    for n in sorted(m):
        if n % 2 == 0 and n + 1 in m:
            a, b = inv[m[n]][0], inv[m[n + 1]][0]
            res.append("M" if mirror(a) == b else ".")
    print(f"  {p:<9}", "".join(res))
