# -*- coding: utf-8 -*-
"""代表线名的自连跨度与对外连接。"""
import json, collections

d = json.load(open(r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json", encoding="utf-8"))
wh = ["IMUX_L40", "BYP_ALT0", "FAN_BOUNCE7", "EE2BEG0", "EE4BEG0", "SE6BEG0",
      "SW6BEG0", "WL1BEG0", "WW2BEG0", "LV_L0", "LH0", "LVB_L0"]
sl = collections.defaultdict(set)
ot = collections.defaultdict(collections.Counter)
for e in d:
    tt, dl, pairs = e["tile_types"], e["grid_deltas"], e["wire_pairs"]
    if "INT_L" not in tt:
        continue
    i = tt.index("INT_L"); j = 1 - i
    for p in pairs:
        if not isinstance(p, (list, tuple)) or len(p) != 2:
            continue
        me, oth = p[i], p[j]
        if me not in wh:
            continue
        if tt[j] == "INT_L" and me == oth:
            sl[me].add((abs(dl[0]), abs(dl[1])))
        else:
            ot[me][(tt[j], abs(dl[0]), abs(dl[1]))] += 1
for w in wh:
    print("%-12s 自连=%s  对外=%s" % (w, sorted(sl[w])[:6], ot[w].most_common(3)))
