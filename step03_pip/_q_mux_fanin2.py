# -*- coding: utf-8 -*-
"""INT_L 模板：按目的 wire 统计 mux 扇入（pip_defs = [dst, src, ?, ?]）。"""
import collections
import io
import json

P = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
d = json.load(io.open(P, encoding="utf-8"))
pips = d["pip_defs"]
by_dst = collections.defaultdict(list)
for dst, src, *_ in pips:
    by_dst[dst].append(src)

print("PIP 条数", len(pips), "目的 wire 数", len(by_dst))
fan = collections.Counter(len(v) for v in by_dst.values())
print("扇入分布（扇入:目的wire数）:", dict(sorted(fan.items())))
print("扇入=1:", fan.get(1, 0), "扇入>1:", len(by_dst) - fan.get(1, 0))
print("最大扇入:", collections.Counter({k: len(v) for k, v in by_dst.items()}).most_common(5))
for pref in ("IMUX", "BYP", "FAN", "EE2BEG", "WW2BEG", "CLK", "CTRL", "LV", "EE2END", "LOGIC_OUTS"):
    sub = {k: v for k, v in by_dst.items() if str(k).startswith(pref)}
    if sub:
        f2 = collections.Counter(len(v) for v in sub.values())
        print("%-12s 目的 %4d  PIP %5d  扇入分布 %s"
              % (pref, len(sub), sum(len(v) for v in sub.values()), dict(sorted(f2.items()))))
print()
for dst in ("IMUX_L10", "BYP_ALT0", "EE2BEG0", "CLK_L0", "LV0"):
    v = by_dst.get(dst, [])
    print(dst, "扇入", len(v), v[:8])
