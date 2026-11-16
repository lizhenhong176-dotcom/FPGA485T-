# -*- coding: utf-8 -*-
"""验证 row = Y%50 (0..49) 的含义：350 行 = 7×50、word 布局、ECC 居中。"""
import sqlite3, collections

law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = law.execute("select tile_type, col, y from law_tiles").fetchall()
ys = sorted({y for _, _, y in rows})
print("law_tiles 行数:", len(rows), "Y 值个数:", len(ys), "min/max:", ys[0], ys[-1])
print("Y//50 桶:", dict(sorted(collections.Counter(y // 50 for y in ys).items())))
print("每个 Y 的 tile 数示例:", [(y, sum(1 for _, _, yy in rows if yy == y)) for y in (0, 1, 49, 50, 99, 100)])

meta = dict(law.execute("select key, value from meta").fetchall())
print("meta band_rows =", meta.get("band_rows"), " row_frames =", meta.get("row_frames"))

# word 布局：25+1+25
def word_of(y, par):
    w = 2 * (y % 50) + par
    return w + 1 if w >= 50 else w

print("\nY%50 -> (parity0 word, parity1 word):")
for r in (0, 1, 23, 24, 25, 26, 48, 49):
    print("  row %2d: %3d %3d" % (r, word_of(r, 0), word_of(r, 1)))
used = sorted({word_of(r, p) for r in range(50) for p in (0, 1)})
print("用到的 word 数:", len(used), "缺:", sorted(set(range(101)) - set(used)))
