# -*- coding: utf-8 -*-
"""A1：far_bands.col 与 tile 列的关系；HCLK_CMT 观测帧落在哪个 far_col。"""
import sqlite3, collections

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)

# 1) 已知锚点：INT_L_X8Y20 -> base 31752（band6）；INT_R_X37Y199 -> 6510（band1）
for name, base in [("INT_L_X8Y20", 31752), ("INT_R_X37Y199", 6510)]:
    row = con.execute("select tile_type, col, y from law_tiles where tile_name=?", (name,)).fetchone()
    print(name, "law_tiles:", row)
    hit = con.execute("select band, col, start_frame from far_bands where start_frame=?",
                      (base,)).fetchall()
    print("   start_frame 命中:", hit)

# 2) 每个 band 里 far_col 的 start_frame 单调关系与步长
rows = con.execute("select band, col, start_frame, frames from far_bands order by band, col").fetchall()
by = collections.defaultdict(list)
for b, c, s, n in rows:
    by[b].append((c, s, n))
for b in (1, 4, 6):
    lst = by[b]
    print(f"\nband{b} 前 8 列:", lst[:8])
    deltas = [lst[i + 1][1] - lst[i][1] for i in range(len(lst) - 1)]
    print(f"band{b} 相邻列 start 差:", collections.Counter(deltas).most_common(6))
