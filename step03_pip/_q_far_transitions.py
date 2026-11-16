# -*- coding: utf-8 -*-
"""FAR 字段随线性帧号怎么变：列出跳变点。"""
from __future__ import annotations
import sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "v7re"))
from bitstream.far import FarAddress

m = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
rows = [(fi, far) for fi, far in m.execute(
    "select frame_index, far from frame_map where far is not null order by frame_index")]

prev = None
trans = []
for fi, far in rows:
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    key = (fa.block_type, fa.top_bottom, fa.row)
    if key != prev:
        trans.append((fi, fa))
        prev = key

print("帧号 / block / top / row 变化点共", len(trans), "处；前 40 处：")
for fi, fa in trans[:40]:
    print(f"  帧 {fi:6d} -> block={fa.block_type} top={fa.top_bottom} row={fa.row} col={fa.column} minor={fa.minor}")

print()
print("列（col）变化点统计：")
prevc = None
colsegs = []
for fi, far in rows:
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    if fa.column != prevc:
        colsegs.append((fi, fa.block_type, fa.top_bottom, fa.row, fa.column))
        prevc = fa.column
print("  共", len(colsegs), "段；前 20：")
for s in colsegs[:20]:
    print("   帧 %6d block=%d top=%d row=%d col=%d" % s)
print("  后 6：")
for s in colsegs[-6:]:
    print("   帧 %6d block=%d top=%d row=%d col=%d" % s)
