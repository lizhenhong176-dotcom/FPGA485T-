# -*- coding: utf-8 -*-
"""3,693（模板族内 PIP） vs 3,634（law_cells feature）：差 59 的逐族对账。"""
import collections
import io
import json
import sqlite3
import sys

sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re\scripts")
from verify_all_pip import name_variants  # noqa: E402

P = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
d = json.load(io.open(P, encoding="utf-8"))
by_dst = collections.defaultdict(set)
for a, b, *_ in d["pip_defs"]:
    by_dst[b].add(a)

con = sqlite3.connect(r"file:E:\v7work\model\v7_law.sqlite?mode=ro", uri=True)
law = collections.defaultdict(set)
for fam, src in con.execute(
        "select family,src_wire from law_cells where tile_type='INT_L' and sense=1"):
    law[fam].add(src)

fams = set(law)
tot_t = tot_l = 0
miss = []
for dst, srcs in by_dst.items():
    hit = next((c for c in name_variants(dst) if c in fams), None)
    if not hit:
        continue
    tot_t += len(srcs)
    tot_l += len(law[hit])
    extra = {s for s in srcs if not ({s} | set(name_variants(s))) & law[hit]}
    if extra:
        miss.append((hit, len(srcs), len(law[hit]), sorted(extra)[:4]))
print("模板族内 PIP:", tot_t, " law feature:", tot_l, " 差:", tot_t - tot_l)
print("模板多出来源的族数:", len(miss))
for m in miss[:15]:
    print("   %-12s 模板扇入 %2d  law %2d  多出: %s" % m)
