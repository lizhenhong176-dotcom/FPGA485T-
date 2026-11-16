# -*- coding: utf-8 -*-
import sqlite3, collections, re
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off FROM law_cells WHERE tile_type='INT_L' AND sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in cur.fetchall(): fam[f][s].add(fo)
mux = {f: v for f, v in fam.items() if len(v) == 24}
# 每族：row -> 源名集合（只取组格 16..21）
ok_cell = 0; tot_cell = 0
row20_21 = collections.Counter()
for f, srcs in mux.items():
    r2s = collections.defaultdict(list)
    for s, fos in srcs.items():
        grp = [x for x in fos if 16 <= x <= 21]
        if len(grp) == 1: r2s[grp[0]].append(s)
    for r in range(16, 22):
        tot_cell += len(r2s.get(r, []))
    # 20/21 行是否只含 bounce/local
    def is_bounce(s): return bool(re.search(r"(BYP|FAN)", s)) and "BOUNCE" in s
    def is_local(s): return s.startswith(("GFAN", "LOGIC_OUTS"))
    b = [s for s in r2s.get(20, []) + r2s.get(21, [])]
    row20_21[(sum(1 for s in b if is_bounce(s)), sum(1 for s in b if is_local(s)))] += 1
    # 行内是否恰好 4 个源
    if all(len(r2s.get(r, [])) == 4 for r in range(16, 22)): ok_cell += 1
print("24 源族:", len(mux), "每行都恰好 4 源的族:", ok_cell)
print("20/21 行构成 (bounce 数, local 数) → 族数:", dict(row20_21))
print("组格总数:", tot_cell, "应等于", 24 * len(mux))