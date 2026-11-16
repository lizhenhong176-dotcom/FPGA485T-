# -*- coding: utf-8 -*-
"""每个家族的扇入（多少条源线）与线长等级分布。"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
print([r[0] for r in db.execute("select name from sqlite_master where type='table'")])
cols = [r[1] for r in db.execute("pragma table_info(pip_bits)")]
print("pip_bits 列:", cols)
rows = db.execute("select tile_type, family, src_wire from pip_bits where tile_type='INT_L'").fetchall()
fan = collections.defaultdict(set)
for t, f, s in rows:
    fan[f].add(s)
c = collections.Counter(len(v) for v in fan.values())
print("家族数:", len(fan), "扇入分布:", dict(sorted(c.items())))
for f in sorted(fan, key=lambda k: -len(fan[k]))[:6]:
    print("  ", f, len(fan[f]))
print("  ...最小:", [(f, len(fan[f])) for f in sorted(fan, key=lambda k: len(fan[k]))[:6]])
