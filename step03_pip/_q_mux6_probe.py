# -*- coding: utf-8 -*-
import sqlite3, collections, re
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off, bit FROM law_cells WHERE tile_type='INT_L' AND sense=1")
rows = cur.fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b in rows:
    fam[f][s].add((fo, b))
mux = {f: v for f, v in fam.items() if len(v) == 24}
print("24 源族:", len(mux))
print("== IMUX_L40 的 24 源 ==")
for s, cells in sorted(mux["IMUX_L40"].items()):
    print("  %-16s cells=%s" % (s, sorted(cells)))