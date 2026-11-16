# -*- coding: utf-8 -*-
"""数量对账（修正向量方向）：pip_defs 条目是 [源 wire, 目的 wire, ?, ?]。"""
import collections
import io
import json
import sqlite3
import sys

sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re\scripts")
from verify_all_pip import name_variants  # noqa: E402

P = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
d = json.load(io.open(P, encoding="utf-8"))
pips = d["pip_defs"]
print("模板 PIP 总数:", len(pips))

by_dst = collections.defaultdict(list)
for a, b, *_ in pips:
    by_dst[b].append(a)          # b = 目的 wire, a = 源 wire

con = sqlite3.connect(r"file:E:\v7work\model\v7_law.sqlite?mode=ro", uri=True)
fams = {r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}

cov, unc = {}, {}
for dst, srcs in by_dst.items():
    hit = next((c for c in name_variants(dst) if c in fams), None)
    (cov if hit else unc)[dst] = srcs

print("目的 wire 总数:", len(by_dst))
print("族覆盖的目的 wire:", len(cov), " PIP:", sum(len(v) for v in cov.values()))
print("未覆盖的目的 wire:", len(unc), " PIP:", sum(len(v) for v in unc.values()))
print("未覆盖明细:")
for dst, srcs in sorted(unc.items(), key=lambda kv: -len(kv[1])):
    print("   %-18s 扇入 %3d   例: %s" % (dst, len(srcs), srcs[:3]))
print("对照：law 家族扇入合计 =", sum(len(v) for v in cov.values()))
