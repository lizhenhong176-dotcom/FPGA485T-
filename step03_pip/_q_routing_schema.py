# -*- coding: utf-8 -*-
"""统计：一块 INT tile 里有多少 PIP、多少个目的 wire（= mux 个数）、mux 扇入分布。"""
import collections
import sqlite3

ROUT = r"E:\v7work\_curated_20261021\routing\v7_routing.db"
con = sqlite3.connect("file:%s?mode=ro" % ROUT, uri=True)
tabs = [r[0] for r in con.execute("select name from sqlite_master where type='table'")]
print("tables:", tabs)
for t in tabs:
    cols = [c[1] for c in con.execute("pragma table_info(%s)" % t)]
    n = con.execute("select count(*) from %s" % t).fetchone()[0]
    print(" ", t, n, cols[:10])
