# -*- coding: utf-8 -*-
"""家族（=目的 wire）的物理跨度：自连链路 + 与逻辑/其他 tile 的连接。"""
import json, collections, re, sqlite3

P = r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json"
d = json.load(open(P, encoding="utf-8"))

self_links = collections.defaultdict(list)      # wire -> [delta]
to_other = collections.defaultdict(set)         # wire -> {(delta, tile_type)}

for e in d:
    tt, dl, pairs = e["tile_types"], e["grid_deltas"], e["wire_pairs"]
    if "INT_L" not in tt:
        continue
    i = tt.index("INT_L")
    j = 1 - i
    for p in pairs:
        if not isinstance(p, (list, tuple)) or len(p) != 2:
            continue
        me, ot = p[i], p[j]
        if tt[j] == "INT_L" and me == ot:
            self_links[me].append((abs(dl[0]), abs(dl[1])))
        else:
            to_other[me].add((abs(dl[0]), abs(dl[1]), tt[j]))

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
fams = [r[0] for r in db.execute(
    "select distinct family from law_cells where tile_type='INT_L' and sense=1 order by family")]

def cls(w):
    sl = self_links.get(w)
    if not sl:
        return "本地(0跳)"
    mx = max(max(a, b) for a, b in sl)
    if mx == 1:
        return "单线(1 tile)"
    if mx == 2:
        return "双线(2 tile)"
    if mx <= 4:
        return "四线(<=4 tile)"
    return "长线/跨区(>=%d tile)" % mx

c = collections.Counter()
rows = []
for f in fams:
    k = cls(f)
    c[k] += 1
    rows.append((k, f, sorted(self_links.get(f, []))[:2], sorted(to_other.get(f, []))[:2]))

print("家族按目的线跨度分类（INT_L，172 族）:")
for k, n in c.most_common():
    print("  %-22s %d" % (k, n))
print()
for k in c:
    print("[" + k + "] 例:", [r[1] for r in rows if r[0] == k][:6])
