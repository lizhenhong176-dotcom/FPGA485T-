# -*- coding: utf-8 -*-
"""从路由库统计 INT_L / INT_R 一块 tile 内的 PIP 数与目的 wire 扇入分布。"""
import collections
import json
import sqlite3

ROUT = r"E:\v7work\_curated_20261021\routing\v7_routing.db"
con = sqlite3.connect("file:%s?mode=ro" % ROUT, uri=True)

for tt in ("INT_L", "INT_R", "CLBLL_L", "CLBLM_L", "BRAM_L", "DSP48E1"):
    row = con.execute("select instances, wires, pips, uniform from tile_types where type=?", (tt,)).fetchone()
    if row:
        print(tt, "instances=%s wires=%s pips=%s uniform=%s" % row)

# INT_L 的模板里逐 PIP 展开，统计「按目的 wire 分组」的扇入分布
row = con.execute("select template from tile_types where type='INT_L'").fetchone()
tpl = json.loads(row[0]) if isinstance(row[0], str) else None
print("template type:", type(row[0]), (len(row[0]) if row[0] else None))

if tpl:
    print("template keys:", list(tpl)[:10])
    pips = tpl.get("pips") or tpl.get("pip")
    print("pips sample:", (pips[:3] if pips else None))

    def dst_of(p):
        if isinstance(p, (list, tuple)):
            return p[1]
        if isinstance(p, dict):
            return p.get("dst") or p.get("to")
        return str(p).split("->")[-1]

    if pips:
        c = collections.Counter(dst_of(p) for p in pips)
        fan = collections.Counter(c.values())
        multi = {k: v for k, v in c.items() if v > 1}
        print("PIP 总数:", len(pips), "目的 wire 数:", len(c))
        print("扇入=1 的目的 wire:", fan.get(1, 0), " 扇入>1 的:", len(multi))
        print("扇入分布 (扇入:个数):", dict(sorted(fan.items())))
        print("最大扇入:", max(c.values()), "样例:", c.most_common(3))
