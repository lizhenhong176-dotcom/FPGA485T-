# -*- coding: utf-8 -*-
"""用 tileconn.json 量「每种线（家族）跨多远」：INT_L 侧的 wire 出现在哪些 delta 上。"""
import json, collections, re

P = r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json"
d = json.load(open(P, encoding="utf-8"))

# wire -> set of (delta, tile_type_of_other_side, other_wire)
reach = collections.defaultdict(set)
for e in d:
    tt, dl, pairs = e["tile_types"], e["grid_deltas"], e["wire_pairs"]
    dl = (abs(dl[0]), abs(dl[1]))
    if "INT_L" not in tt:
        continue
    i = tt.index("INT_L")
    j = 1 - i
    for p in pairs:
        if len(p) != 2:
            continue
        w_me, w_other = p[i], p[j]
        reach[w_me].add((dl, tt[j], w_other))

print("INT_L 侧出现过的 wire 名数:", len(reach))

def prefix(w):
    m = re.match(r"([A-Z]+[0-9]*[A-Z]*)", w)
    return m.group(1) if m else w

byp = collections.defaultdict(lambda: collections.Counter())
for w, s in reach.items():
    for (dx, dy), t, _ in s:
        byp[prefix(w)][(dx, dy, t)] += 1

for p in sorted(byp, key=lambda k: -sum(byp[k].values()))[:28]:
    top = byp[p].most_common(4)
    print("%-14s n=%-5d %s" % (p, sum(byp[p].values()), top))
