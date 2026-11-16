# -*- coding: utf-8 -*-
"""INT_L 模板：逐目的 wire 统计 mux 扇入（一个目的 wire 的多个 PIP = 一个 mux）。"""
import collections
import io
import json

P = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
d = json.load(io.open(P, encoding="utf-8"))
print("type=%s wires=%s pips=%s" % (d["type"], d["wires"], d["pips"]))
pips = d["pip_defs"]
print("pip_defs 条数:", len(pips), "样例:", pips[:3])
print("wire_defs 样例:", d["wire_defs"][:3] if d.get("wire_defs") else None)


def dst_of(p):
    if isinstance(p, dict):
        return p.get("dst") or p.get("to") or p.get("sink")
    if isinstance(p, (list, tuple)):
        return p[1]
    return str(p).split("->")[-1]


c = collections.Counter(dst_of(p) for p in pips)
fan = collections.Counter(c.values())
print("目的 wire 数:", len(c))
print("扇入分布 (扇入:目的wire数):", dict(sorted(fan.items())))
print("扇入=1（等价直通）:", fan.get(1, 0), "  扇入>1（真 mux）:", len(c) - fan.get(1, 0))
print("最大扇入目的:", c.most_common(5))
for pref in ("IMUX", "BYP", "FAN", "EE2BEG", "WW2BEG", "CLK", "CTRL", "LV"):
    sub = {k: v for k, v in c.items() if str(k).startswith(pref)}
    if sub:
        f2 = collections.Counter(sub.values())
        print("%-8s 目的 wire %4d  PIP %5d  扇入分布 %s"
              % (pref, len(sub), sum(sub.values()), dict(sorted(f2.items()))))
