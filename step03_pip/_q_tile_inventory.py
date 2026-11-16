# -*- coding: utf-8 -*-
"""盘点：器件有哪些 tile、每类多少实例、PIP 编码律覆盖到哪些类型。"""
import json, sqlite3, collections, os

GRID = r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"
MODEL = r"E:\v7work\model\v7_model.sqlite"
LAW = r"E:\v7work\model\v7_law.sqlite"

g = json.load(open(GRID, encoding="utf-8"))
if isinstance(g, dict):
    tiles = g.get("tiles", g)
else:
    tiles = g
print("tilegrid 类型:", type(tiles), "条数:", len(tiles))
sample = tiles[0] if isinstance(tiles, list) else list(tiles.items())[0]
print("样例:", str(sample)[:200])

cnt = collections.Counter()
for t in tiles:
    if isinstance(t, dict):
        cnt[t.get("type") or t.get("tile_type")] += 1
    else:
        cnt[str(t)] += 1
print("\n类型数:", len(cnt), "总计:", sum(cnt.values()))
for k, v in cnt.most_common(40):
    print(f"  {k:<28} {v}")
print("...")
print("其余类型数：", max(0, len(cnt) - 40))

# 模型库里有哪些 tile_type 有 PIP 位
con = sqlite3.connect(MODEL)
try:
    rows = con.execute("select tile_type, count(*) from pip_bits group by tile_type").fetchall()
    print("\npip_bits by tile_type:", rows)
except Exception as e:
    print("pip_bits:", e)
try:
    rows = con.execute("select count(*), count(distinct tile_name) from pip_bits").fetchone()
    print("pip_bits 总数/不同 tile:", rows)
except Exception as e:
    print(e)

con2 = sqlite3.connect(LAW)
for tbl, col in [("law_cells", "tile_type"), ("law_tiles", "tile_type"), ("clb_cells", "tile_type")]:
    try:
        rows = con2.execute(f"select {col}, count(*) from {tbl} group by {col}").fetchall()
        print(f"\n{tbl} by {col}:", rows)
    except Exception as e:
        print(tbl, e)
