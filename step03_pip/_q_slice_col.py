# -*- coding: utf-8 -*-
import sqlite3

law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
print("band0 col0..10 (band, col, start, end):")
for r in law.execute("select band, col, start_frame, end_frame from far_bands where band=0 order by col limit 11"):
    print("  ", r)

mdl = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
print()
print("sites 表列名:", [r[1] for r in mdl.execute("pragma table_info(sites)")])
for st in ("SLICE_X11Y20", "SLICE_X47Y51", "SLICE_X130Y20", "SLICE_X150Y20"):
    row = mdl.execute("select site, tile, tile_type, row, col, clock_region from sites where site=?", (st,)).fetchone()
    print(st, "->", row)
print()
print("SLICE 的 col 范围:", mdl.execute("select min(col), max(col), count(distinct col) from sites where site like 'SLICE%'").fetchone())
print("col 在 128..157 的 SLICE 数:",
      mdl.execute("select count(*), count(distinct col) from sites where site like 'SLICE%' and col between 128 and 157").fetchone())
