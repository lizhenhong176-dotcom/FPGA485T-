# -*- coding: utf-8 -*-
"""far_bands 是否就是 FAR 的 (block,top,row,col) 首帧；顺带算 128..153 列的基址。"""
from __future__ import annotations
import collections, sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "v7re"))
from bitstream.far import FarAddress

mdl = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")

# band -> (block, top, row)，按帧号递增顺序
seq = []
for fi, far in mdl.execute("select frame_index, far from frame_map where far is not null order by frame_index"):
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    key = (fa.block_type, fa.top_bottom, fa.row)
    if not seq or seq[-1][0] != key:
        seq.append([key, []])
    seq[-1][1].append((fi, fa.column))

band_keys = [k for k, _ in seq][:7]
print("band 顺序:", band_keys)

# 每 (block,top,row) 每列首帧
first = {}
for (key, items) in seq:
    d = {}
    for fi, c in items:
        d.setdefault(c, fi)
    first[key] = d

rows = law.execute("select band, col, start_frame from far_bands order by band, col").fetchall()
bad = 0
for band, col, st in rows:
    key = band_keys[band]
    got = first[key].get(col)
    if got != st:
        bad += 1
        if bad <= 6:
            print(f"  MISMATCH band={band} col={col} far_bands={st} from_FAR={got}")
print(f"far_bands {len(rows)} 行，与 FAR 首帧逐条不符 {bad} 条")

# 列 128..153 的基址（从 FAR 数据算），以及能否覆盖缺的 tile
for band in (0, 6):
    key = band_keys[band]
    d = first[key]
    print(f"band={band} ({key}) 列数 {len(d)}，col 128..153 首帧:",
          [(c, d.get(c)) for c in range(128, 154, 6)])
