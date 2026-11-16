# -*- coding: utf-8 -*-
import sqlite3, json, collections
l = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
print("law_tiles 列分布(尾部):")
for r in l.execute("select col, count(*), group_concat(distinct tile_type) from law_tiles where col>=152 group by col"):
    print("  col=%d n=%d types=%s" % r)
print("far_bands col 范围:", l.execute("select min(col), max(col), count(*) from far_bands").fetchone())
print("示例 tile:", l.execute("select tile_name, tile_type, col, y from law_tiles where tile_type='INT_L' and col=8 and y=20").fetchone())
l.close()
g = json.load(open(r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"))
for nm in ("INT_L_X8Y20", "INT_R_X37Y199"):
    t = g.get(nm); print(nm, "grid_x=%s grid_y=%s type=%s" % (t["grid_x"], t["grid_y"], t["type"]) if t else "MISSING")
# tile 列 154..157 对应哪些 tile 名（用 law_tiles 的 col 与 tilegrid 的 grid_x 关系不可直接得，改看 tilegrid 中 INT_FEEDTHRU）
cnt = collections.Counter(t["type"] for t in g.values() if t["type"] in ("INT_FEEDTHRU_1", "INT_FEEDTHRU_2"))
print("feedthru 计数:", dict(cnt))