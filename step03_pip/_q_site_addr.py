# -*- coding: utf-8 -*-
import sqlite3

mdl = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")

print("site_addr 行数:", mdl.execute("select count(*) from site_addr").fetchone())
print("sample:", mdl.execute("select * from site_addr limit 3").fetchall())
print("grid_col 范围:", mdl.execute("select min(grid_col),max(grid_col),count(distinct grid_col) from site_addr").fetchone())
print("high col sample:")
for r in mdl.execute("select * from site_addr where grid_col between 128 and 130 limit 6"):
    print("  ", r)

print()
print("INT_L col 与 tilegrid x 的关系：")
rows = mdl.execute("select tile_name, grid_x, grid_y from tiles where tile_name in "
                   "('INT_L_X8Y20','INT_R_X37Y199','INT_L_X0Y0','INT_L_X152Y0')").fetchall()
print("  ", rows)
print("law_tiles 的 INT_L_X8Y20:", law.execute("select * from law_tiles where tile_name='INT_L_X8Y20'").fetchone())
