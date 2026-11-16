# -*- coding: utf-8 -*-
import collections
import io
import json

P = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
d = json.load(io.open(P, encoding="utf-8"))
pips = d["pip_defs"]

by_dst = collections.defaultdict(list)
for dst, src, *_ in pips:
    by_dst[dst].append(src)

for dst in ("IMUX_L10", "BYP_ALT0", "EE2BEG0", "LV0", "CLK_L0"):
    srcs = by_dst.get(dst, [])
    print(dst, "扇入", len(srcs))
    print("   ", srcs)
