# -*- coding: utf-8 -*-
"""A1 强化：far_bands.col 是否 == tile 的 col（全量检验）；far_col 33 上有什么 tile。"""
import json, sqlite3, collections

LAW = r"E:\v7work\model\v7_law.sqlite"
GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
BAND = [6, 5, 0, 1, 2, 3, 4]

con = sqlite3.connect(LAW)
band_start = {}
for b, c, s in con.execute("select band, col, start_frame from far_bands"):
    band_start[(b, c)] = s

rows = con.execute("select tile_name, tile_type, col, y from law_tiles").fetchall()
match = miss = 0
missing_keys = collections.Counter()
for name, tt, col, y in rows:
    band = BAND[y // 50]
    s = band_start.get((band, col))
    if s is None:
        missing_keys[(band, col)] += 1
        miss += 1
    else:
        match += 1
print(f"law_tiles {len(rows)} 行：有对应 far_bands 行 {match}，无 {miss}")
if missing_keys:
    print("  缺失的 (band,col) 前 10:", missing_keys.most_common(10))

# far_col 33 上有哪些 tile 类型
g = json.load(open(GRID, encoding="utf-8"))
by_x = collections.defaultdict(collections.Counter)
for name, v in g.items():
    by_x[v["grid_x"]][v["type"]] += 1
for x in (33, 88, 305, 119, 120):
    print(f"\ngrid_x={x} 上的 tile 类型:", by_x.get(x, {}).most_common(8))
