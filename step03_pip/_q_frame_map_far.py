# -*- coding: utf-8 -*-
"""frame_map 里的 FAR：block_type / row / col / minor 的实际取值。"""
from __future__ import annotations
import collections, sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "v7re"))
from bitstream.far import FarAddress

m = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
print("frame_map 行数:", m.execute("select count(*) from frame_map").fetchone()[0])
print("有 far 的行:", m.execute("select count(*) from frame_map where far is not null").fetchone()[0])
print("sources:", m.execute("select frame_address_source, count(*) from frame_map group by 1").fetchall())
print("confidence:", m.execute("select confidence, count(*) from frame_map group by 1").fetchall())

rows = m.execute("select frame_index, far, block_type, row_number, block_addr, tile_name, is_overhead"
                 " from frame_map where far is not null order by frame_index limit 8").fetchall()
for r in rows:
    fa = FarAddress.decode(r[1] & 0xFFFFFFFF)
    print(r, "->", fa, "linear_frames=", (r[1] & 0xFFFFFFFF) >> 11)

print()
print("block_type 分布:", m.execute("select block_type, count(*) from frame_map group by 1 order by 1").fetchall())
print("row_number 分布:", m.execute("select row_number, count(*) from frame_map group by 1 order by 1").fetchall()[:12])
print("block_addr 分布:", m.execute("select block_addr, count(*) from frame_map group by 1 order by 1").fetchall()[:12])

# 用 python 解 FAR 的 col/minor
cols, minors, tops = collections.Counter(), collections.Counter(), collections.Counter()
for (fi, far) in m.execute("select frame_index, far from frame_map where far is not null order by frame_index"):
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    cols[fa.column] += 1
    minors[fa.minor] += 1
    tops[fa.top_bottom] += 1
print("FAR col 取值数:", len(cols), "min/max:", min(cols), max(cols))
print("FAR minor 取值数:", len(minors), "min/max:", min(minors), max(minors))
print("top_bottom:", dict(tops))
print("每列帧数（前 10 列）:", dict(sorted(collections.Counter(
    FarAddress.decode(f & 0xFFFFFFFF).column for (f,) in m.execute("select far from frame_map where far is not null")).items())[:10]))
