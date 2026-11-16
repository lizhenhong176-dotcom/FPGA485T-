# -*- coding: utf-8 -*-
import json, collections
g = json.load(open(r"E:\v7work\db\prjxray\xc7vx485t\tilegrid.json"))
bytype = collections.defaultdict(list)
for name, t in g.items():
    tt = dict(t); tt["name"] = name; bytype[tt["type"]].append(tt)
for ty in ("BRAM_L", "BRAM_R", "DSP_L", "DSP_R"):
    xs = sorted({t["grid_x"] for t in bytype.get(ty, [])})
    print("%-8s n=%-5d grid_x 数=%-3d %s" % (ty, len(bytype.get(ty, [])), len(xs), xs[:10]))
bram = [t for ty in ("BRAM_L","BRAM_R","DSP_L","DSP_R") for t in bytype.get(ty, [])]
seg = collections.defaultdict(set)
for t in bram:
    seg[t["grid_y"]//50].add(t["grid_x"])
print("每 50 行段：BRAM/DSP 列数 =", {k: len(v) for k, v in sorted(seg.items())})
allx = sorted({t["grid_x"] for t in bram})
print("全部不同的 grid_x =", len(allx), allx[:20])