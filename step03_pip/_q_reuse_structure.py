# -*- coding: utf-8 -*-
"""PIP 复用的结构分析：复用从哪来、是否双峰（公共位 vs 私有位）、跨族 3 例的成因。"""
import sqlite3, collections

DB = r"E:\v7work\model\v7_law.sqlite"
db = sqlite3.connect(DB)

rows = db.execute(
    "select family,src_wire,frame_off,bit,parity from law_cells "
    "where tile_type='INT_L' and sense=1"
).fetchall()

fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

print("families", len(fam))
tot_cells = 0
tot_place = 0
profiles = []
for f, srcs in fam.items():
    cells = set().union(*srcs.values())
    mult = collections.Counter()
    for s, cs in srcs.items():
        for c in cs:
            mult[c] += 1
    n = len(srcs)
    m = len(cells)
    P = sum(mult.values())
    tot_cells += m
    tot_place += P
    hi = [c for c, k in mult.items() if k >= n / 2]
    lo = [c for c, k in mult.items() if k < n / 2]
    profiles.append((f, n, m, P, len(hi), len(lo),
                     sorted(mult.values(), reverse=True), max(mult.values())))

print("cells", tot_cells, "placements", tot_place, "avg", round(tot_place / tot_cells, 2))

# 按形状聚合
by = collections.defaultdict(list)
for f, n, m, P, nhi, nlo, vals, mx in profiles:
    by[(m, n)].append((P / m, nhi, mx, len(fam[f])))

print("\n形状 | 族数 | 每格平均复用 | 高复用(k>=n/2)格数 | 最大复用")
for k in sorted(by, key=lambda x: -len(by[x])):
    v = by[k]
    print(k, len(v), round(sum(x[0] for x in v) / len(v), 2),
          collections.Counter(x[1] for x in v).most_common(3),
          collections.Counter(x[2] for x in v).most_common(3))

# 双峰检验：把每族的多重度序列拉平看分布
allv = collections.Counter()
for f, n, m, P, nhi, nlo, vals, mx in profiles:
    for v in vals:
        allv[v] += 1
print("\n全局 每格被几源共用 的直方图:", sorted(allv.items()))

# 实例：mux 族与 BEG 族各一个
for name in ("BYP_ALT0", "IMUX_L40", "EE2BEG0", "EE4BEG0", "LH0", "LV_L0"):
    if name not in fam:
        continue
    srcs = fam[name]
    mult = collections.Counter()
    for s, cs in srcs.items():
        for c in cs:
            mult[c] += 1
    n = len(srcs)
    print(f"\n{name}: n={n} m={len(mult)} P={sum(mult.values())}")
    for c, k in sorted(mult.items(), key=lambda x: -x[1]):
        print("   ", c, "used by", k, "srcs")
