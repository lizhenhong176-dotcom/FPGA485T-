# -*- coding: utf-8 -*-
"""核对 6×4 表格说法：每族 2 格/4 格源数、行格唯一性、IMUX_L40 的 24 源落位。"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = db.execute(
    "select family,src_wire,frame_off,bit,parity from law_cells "
    "where tile_type='INT_L' and sense=1"
).fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

# 1) 每族 2 格 / 4 格源数
tot2 = tot4 = 0
per = collections.Counter()
for f, srcs in fam.items():
    n2 = sum(1 for v in srcs.values() if len(v) == 2)
    n4 = sum(1 for v in srcs.values() if len(v) == 4)
    per[(n2, n4)] += 1
    tot2 += n2
    tot4 += n4
print("2 格源合计", tot2, "4 格源合计", tot4)
print("(2格源数,4格源数) 的族分布:", sorted(per.items(), key=lambda x: -x[1]))

# 2) 行格唯一性：每个族里，被 4 个源共用、且 frame_off 16..21 的格
print("\n各族行格数（frame_off 16..21 的格）:")
c = collections.Counter()
for f, srcs in fam.items():
    cells = set().union(*srcs.values())
    c[len([x for x in cells if 16 <= x[0] <= 21])] += 1
print(sorted(c.items()))

# 3) IMUX_L40 明细
srcs = fam["IMUX_L40"]
print("\nIMUX_L40 源数", len(srcs))
for s in sorted(srcs, key=lambda s: sorted(srcs[s])):
    print("  ", s, sorted(srcs[s]))
