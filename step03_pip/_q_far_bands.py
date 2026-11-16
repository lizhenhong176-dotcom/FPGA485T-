# -*- coding: utf-8 -*-
"""看 far_bands 的结构与每 band 的帧数构成。"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
print("far_bands 列:", [r[1] for r in db.execute("pragma table_info(far_bands)")])
rows = db.execute("select * from far_bands limit 4").fetchall()
cols = [r[1] for r in db.execute("pragma table_info(far_bands)")]
for r in rows:
    print(dict(zip(cols, r)))

allr = db.execute("select * from far_bands").fetchall()
print("行数:", len(allr))
i_b = cols.index([c for c in cols if "band" in c][0])
i_c = cols.index([c for c in cols if c in ("col", "column")][0]) if any(c in ("col", "column") for c in cols) else None
i_s = cols.index([c for c in cols if "start" in c][0])
i_n = cols.index([c for c in cols if c in ("n_frames", "frames", "count")][0]) if any(c in ("n_frames", "frames", "count") for c in cols) else None
per = collections.defaultdict(list)
for r in allr:
    per[r[i_b]].append(r[i_s])
print("band 数:", len(per))
for b in sorted(per):
    s = sorted(per[b])
    print("  band %d: 列数 %d, start %d..%d, 连续差集 %s" % (
        b, len(s), s[0], s[-1], sorted({s[i+1]-s[i] for i in range(len(s)-1)})[:6]))
print("总帧数上界:", max(max(v) for v in per.values()) + 1)
