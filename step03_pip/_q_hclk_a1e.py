# -*- coding: utf-8 -*-
"""A1：用 site_addr（每站点 base_frame）反查 frame 22144 等落在哪个站点块。"""
import sqlite3

MODEL = r"E:\v7work\model\v7_model.sqlite"
con = sqlite3.connect(MODEL)
print("site_frames 索引:", con.execute(
    "select name, sql from sqlite_master where type='index' and tbl_name='site_frames'").fetchall())
print("\nsite_addr 列:", [r[1] for r in con.execute("pragma table_info(site_addr)")])
print("site_addr 行数:", con.execute("select count(*) from site_addr").fetchone()[0])
print("样例:", con.execute("select * from site_addr limit 3").fetchall())

# 站点块的 base_frame 分布是否唯一
frames = (22144, 22145, 22147, 35528)
rows = con.execute(
    "select site, tile_type, grid_col, y, band, base_frame, word0, source from site_addr "
    "where base_frame <= ? order by base_frame desc limit 5", (max(frames),)).fetchall()
print("\nbase_frame <= 35528 的最近站点:")
for r in rows:
    print("   ", r)
