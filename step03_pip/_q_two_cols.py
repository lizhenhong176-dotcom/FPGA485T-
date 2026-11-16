# -*- coding: utf-8 -*-
"""两套列坐标：tile 列 vs 帧列；哪些 tile 列没有帧基址。"""
import sqlite3, collections

m = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
tile_cols = {r[0] for r in m.execute("select distinct col from law_tiles")}
frame_cols = {r[0] for r in m.execute("select distinct col from far_bands")}
print("tile 列数:", len(tile_cols), "min/max:", min(tile_cols), max(tile_cols))
print("帧列数:", len(frame_cols), "min/max:", min(frame_cols), max(frame_cols))
miss = sorted(tile_cols - frame_cols)
print("无帧基址的 tile 列:", len(miss), miss[:40])

# INT tile 的列奇偶与能否定位
rows = m.execute("select tile_name, tile_type, col, y from law_tiles where tile_type in ('INT_L','INT_R')").fetchall()
print("INT tile 实例:", len(rows))
odd = collections.Counter((t, c % 2) for _, t, c, _ in rows)
print("INT_L/INT_R 列奇偶:", dict(odd))
ok = [r for r in rows if r[2] in frame_cols]
print("能直接拿 far_bands 基址的:", len(ok), "占 %.1f%%" % (100.0 * len(ok) / len(rows)))
bycol = collections.Counter(r[2] for r in rows if r[2] not in frame_cols)
print("定位不了的列:", sorted(bycol.items())[:12], "共", len(bycol), "列")
