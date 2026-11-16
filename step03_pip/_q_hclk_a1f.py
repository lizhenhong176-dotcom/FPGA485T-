# -*- coding: utf-8 -*-
import sqlite3

MODEL = r"E:\v7work\model\v7_model.sqlite"
con = sqlite3.connect(MODEL)

for target in (22144, 22147, 32636, 35528, 35585):
    rows = con.execute(
        "select distinct site, tile_type, grid_col, y, base_frame, word0 from site_addr "
        "where base_frame between ? and ? order by base_frame limit 6",
        (target - 40, target)).fetchall()
    print(f"\nframe {target} 之前 40 帧内的站点块:")
    for r in rows:
        print("   ", r)

print("\n不同 base_frame 的个数:", con.execute(
    "select count(distinct base_frame) from site_addr").fetchone()[0])
