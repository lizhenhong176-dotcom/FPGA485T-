# -*- coding: utf-8 -*-
import sqlite3, collections, re
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off FROM law_cells WHERE tile_type='INT_L' AND sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in cur.fetchall(): fam[f][s].add(fo)
mux = {f: v for f, v in fam.items() if len(v) == 24}
def code(srcs, s):
    bits = sorted(x for x in srcs[s] if x >= 22)
    return sum(1 << (25 - b) for b in bits)
ok = 0; bad = []
for f, srcs in mux.items():
    r2s = collections.defaultdict(list)
    for s, fos in srcs.items():
        grp = [x for x in fos if 16 <= x <= 21]
        if len(grp) == 1 and grp[0] <= 19: r2s[grp[0]].append(s)
    for r, ss in r2s.items():
        cs = sorted(code(srcs, s) for s in ss)
        if cs == [1,2,7,11]: ok += 1
        else: bad.append((f, r, cs))
print("组数", sum(len(v) for v in mux.values()), "每组恰含 4 个不同长度类:", ok, "异常:", len(bad))
print(bad[:5])