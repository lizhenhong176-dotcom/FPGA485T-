# -*- coding: utf-8 -*-
import sqlite3, collections
con = sqlite3.connect(r"E:\v7work\model\v7_model.sqlite")
def dec(far):
    return ((far>>23)&7, (far>>22)&1, (far>>17)&0x1F, (far>>7)&0x3FF, far&0x7F)
rows = []
for fi, far, oh in con.execute("select frame_index, far, is_overhead from frame_map"):
    if far is None or oh: continue
    rows.append((fi,) + dec(far))
print("data_frames", len(rows))
agg = collections.defaultdict(lambda: dict(n=0, cols=set(), minors=set(), fmin=10**9, fmax=-1))
for fi, b, t, r, c, m in rows:
    k = (b, t, r)
    a = agg[k]; a["n"] += 1; a["cols"].add(c); a["minors"].add(m)
    a["fmin"] = min(a["fmin"], fi); a["fmax"] = max(a["fmax"], fi)
for k in sorted(agg):
    a = agg[k]
    print("block=%d top=%d row=%d  frames=%-5d cols=%d (%d..%d) minors=%d (%d..%d) frame_range=%d..%d" % (
        k[0], k[1], k[2], a["n"], len(a["cols"]), min(a["cols"]), max(a["cols"]),
        len(a["minors"]), min(a["minors"]), max(a["minors"]), a["fmin"], a["fmax"]))
con.close()