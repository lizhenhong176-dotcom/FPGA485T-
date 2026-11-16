# -*- coding: utf-8 -*-
"""每个 (block, top, row) 段里：列数、列号范围、每列帧数。"""
from __future__ import annotations
import collections, sqlite3, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "v7re"))
from bitstream.far import FarAddress

m = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
segs = collections.OrderedDict()
for fi, far in m.execute("select frame_index, far from frame_map where far is not null order by frame_index"):
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    segs.setdefault((fa.block_type, fa.top_bottom, fa.row), []).append((fi, fa.column, fa.minor))

for key, items in segs.items():
    cols = collections.Counter(c for _, c, _ in items)
    f0, f1 = items[0][0], items[-1][0]
    print(f"block={key[0]} top={key[1]} row={key[2]}: 帧 {f0}..{f1} 共 {len(items)} | "
          f"列数 {len(cols)} | 列号 {min(cols)}..{max(cols)} | 每列帧数 {sorted(set(cols.values()))}")
