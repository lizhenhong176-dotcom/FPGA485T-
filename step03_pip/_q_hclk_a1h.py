# -*- coding: utf-8 -*-
"""A1：列出 (FAR col -> grid_x) 全映射，找出时钟列对应关系。"""
import json, sqlite3, collections

GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
LAW = r"E:\v7work\model\v7_law.sqlite"
g = json.load(open(GRID, encoding="utf-8"))
con = sqlite3.connect(LAW)

law = {r[0]: (r[1], r[2]) for r in con.execute("select tile_name, col, y from law_tiles")}
m = collections.defaultdict(set)
for name, v in g.items():
    if name in law:
        m[law[name][0]].add(v["grid_x"])

cols = sorted(m)
print("FAR col 数:", len(cols), "范围:", cols[0], cols[-1])
prev = None
rows = []
for c in cols:
    xs = sorted(m[c])
    rows.append((c, xs))
    if len(xs) != 1:
        print("  多 grid_x 的 col:", c, xs)
for i in range(0, min(len(rows), 12)):
    print("  col", rows[i][0], "-> grid_x", rows[i][1])
print("  ...")
for i in range(28, 40):
    print("  col", rows[i][0], "-> grid_x", rows[i][1])

# grid_x 全集 vs 出现过的 grid_x
allx = sorted({v["grid_x"] for v in g.values()})
seen = sorted({x for _, xs in rows for x in xs})
missing = [x for x in allx if x not in seen]
print("\ntilegrid 全部 grid_x 数:", len(allx), "INT 覆盖:", len(seen))
print("未覆盖的 grid_x（可能是时钟/IO 列）前 40:", missing[:40])
