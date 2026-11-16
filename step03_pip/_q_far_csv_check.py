# -*- coding: utf-8 -*-
"""从 CSV 用 10 位列掩码重算 far_bands，和库里的 1078 行逐条对比（独立来源交叉验证）。"""
from __future__ import annotations
import collections, csv, sqlite3
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
N_BANDS, BAND_ROWS = 7, 50

by_band = collections.defaultdict(dict)
for r in csv.DictReader(open(ROOT / "phaseA" / "frame_index_far.csv", encoding="utf-8")):
    band = int(r["row"]) - 1
    if band < 0 or band >= N_BANDS:
        continue
    col = (int(r["block_addr"], 16) >> 7) & 0x3FF          # 修正：10 位，不再 & 0x7F
    fi = int(r["frame_index"])
    e = by_band[band].setdefault(col, [fi, fi, 0])
    e[0] = min(e[0], fi)
    e[1] = max(e[1], fi)
    e[2] += 1

law = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = {(b, c): (s, e, n) for b, c, s, e, n in
        law.execute("select band, col, start_frame, end_frame, frames from far_bands")}
print("CSV 重算:", sum(len(v) for v in by_band.values()), "行 | 库中:", len(rows), "行")

bad = 0
for b, cols in by_band.items():
    for c, (s, e, n) in cols.items():
        got = rows.get((b, c))
        if got != (s, e, n):
            bad += 1
            if bad <= 5:
                print("  MISMATCH", (b, c), "csv", (s, e, n), "db", got)
missing = set(rows) - {(b, c) for b, cols in by_band.items() for c in cols}
print("不一致:", bad, "| 库中有而 CSV 无:", len(missing))
print("CSV 列数/band:", {b: len(v) for b, v in sorted(by_band.items())})
