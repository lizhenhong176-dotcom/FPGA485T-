# -*- coding: utf-8 -*-
"""每个家族的扇入（多少条源线）与线长等级分布（pip_bits 表）。"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
rows = db.execute(
    "select tile, wire_a, wire_b from pip_bits where tile like 'INT_L_%'"
).fetchall()
print("行数:", len(rows), "例:", rows[:3])

fan = collections.defaultdict(set)
for t, a, b in rows:
    fan[b].add(a)
c = collections.Counter(len(v) for v in fan.values())
print("目的 wire 数:", len(fan), "扇入分布:", dict(sorted(c.items())))
for f in sorted(fan, key=lambda k: -len(fan[k]))[:8]:
    print("   大扇入:", f, len(fan[f]))
for f in sorted(fan, key=lambda k: len(fan[k]))[:10]:
    print("   小扇入:", f, len(fan[f]))
