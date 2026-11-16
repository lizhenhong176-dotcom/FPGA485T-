# -*- coding: utf-8 -*-
"""把 far_bands 从 128 列补到 154 列（FAR 实际列数），基址一律从 frame_map 的 FAR 首帧算。

- 备份 v7_law.sqlite 到 v7_law_backup_20261108_pre154.sqlite
- 新增列 frames（该列帧数）
- 原有 896 行 start_frame 必须逐条不变（断言）
- end_frame 统一改成 start_frame + frames - 1（旧值是坏数据）
"""
from __future__ import annotations
import collections, shutil, sqlite3, sys
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
sys.path.insert(0, str(ROOT / "v7re"))
from bitstream.far import FarAddress

LAW = Path(r"E:\v7work\model\v7_law.sqlite")
BAK = Path(r"E:\v7work\model\v7_law_backup_20261108_pre154.sqlite")
MODEL = Path(r"E:\v7work\model\v7_model.sqlite")

if not BAK.exists():
    shutil.copy2(LAW, BAK)
    print("备份:", BAK, BAK.stat().st_size, "bytes")
else:
    print("备份已存在:", BAK)

mdl = sqlite3.connect(MODEL)
# band 顺序 = 按帧号出现顺序的 (block, top, row)
order, seen = [], set()
for fi, far in mdl.execute("select frame_index, far from frame_map where far is not null order by frame_index"):
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    if fa.block_type != 0:
        continue
    key = (fa.block_type, fa.top_bottom, fa.row)
    if key not in seen:
        seen.add(key)
        order.append(key)
assert len(order) == 7, order

# 只取 block_type == 0 的段（逻辑/INT 列）
first = {b: {} for b in range(7)}
count = {b: collections.Counter() for b in range(7)}
for fi, far in mdl.execute("select frame_index, far from frame_map where far is not null order by frame_index"):
    fa = FarAddress.decode(far & 0xFFFFFFFF)
    key = (fa.block_type, fa.top_bottom, fa.row)
    if key[0] != 0:
        continue
    b = order.index(key)
    first[b].setdefault(fa.column, fi)
    count[b][fa.column] += 1

law = sqlite3.connect(LAW)
law.execute("BEGIN")
cols = [r[1] for r in law.execute("pragma table_info(far_bands)")]
if "frames" not in cols:
    law.execute("ALTER TABLE far_bands ADD COLUMN frames INTEGER")
    print("新增列 frames")

old = {(b, c): st for b, c, st in law.execute("select band, col, start_frame from far_bands")}
print("原有行:", len(old))

new_rows, mismatch = [], 0
for b in range(7):
    for c in sorted(first[b]):
        st, n = first[b][c], count[b][c]
        if (b, c) in old and old[(b, c)] != st:
            mismatch += 1
            print("  MISMATCH band", b, "col", c, old[(b, c)], "->", st)
        new_rows.append((b, c, st, st + n - 1, n))
print("FAR 推导出的行:", len(new_rows), "| 与原有不一致:", mismatch)
assert mismatch == 0

law.execute("DELETE FROM far_bands")
law.executemany("INSERT INTO far_bands (band, col, start_frame, end_frame, frames) VALUES (?,?,?,?,?)", new_rows)
law.execute("COMMIT")

print("新表行数:", law.execute("select count(*) from far_bands").fetchone()[0],
      "| 列数:", law.execute("select count(distinct col) from far_bands").fetchone()[0],
      "| 列范围:", law.execute("select min(col), max(col) from far_bands").fetchone())
for b in (0, 6):
    print(f"band{b} 末三列:",
          law.execute("select col, start_frame, end_frame, frames from far_bands where band=? order by col desc limit 3", (b,)).fetchall())
law.close()
