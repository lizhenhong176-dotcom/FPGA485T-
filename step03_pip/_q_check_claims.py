# -*- coding: utf-8 -*-
"""核对文档里两条关键断言：tile 网格范围、每个 band 对应的 Y 区间。"""
import sqlite3

r = sqlite3.connect("file:E:/v7work/_curated_20261021/routing/v7_routing.db?mode=ro", uri=True)
print("tiles grid_x", r.execute("select min(grid_x),max(grid_x),min(grid_y),max(grid_y) from tiles").fetchone())

l = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
print("law_tiles col/y", l.execute("select min(col),max(col),min(y),max(y) from law_tiles").fetchone())
print("by region:", l.execute(
    "select y/50 as region, min(y), max(y), count(*) from law_tiles group by region").fetchall())
print("far_bands per band:", l.execute(
    "select band, min(start_frame), max(start_frame), count(*) from far_bands group by band").fetchall())
print("frame span:", l.execute("select min(start_frame), max(start_frame) from far_bands").fetchone())
