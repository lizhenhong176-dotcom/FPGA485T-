# -*- coding: utf-8 -*-
"""G14：旁路源（LOGIC_OUTS/GFAN/BOUNCE）在 row4/row5 的分配是否与族序号奇偶有关。"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in rows:
    fam[f][s].add(fo)

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

pat = collections.Counter()
for f, d in fam.items():
    if len(d) != 24:
        continue
    n = int(re.search(r"(\d+)$", f).group(1))
    for s, fos in d.items():
        if re.match(r"^(LOGIC_OUTS|GFAN)", s):
            r, c = slot(fos)
            pat[("L4" if r == 4 else "L5", "even" if n % 2 == 0 else "odd")] += 1
print("LOGIC/GFAN 所在行 × 族序号奇偶：")
for k in sorted(pat):
    print("  ", k, pat[k])

pat2 = collections.Counter()
for f, d in fam.items():
    if len(d) != 24:
        continue
    n = int(re.search(r"(\d+)$", f).group(1))
    for s, fos in d.items():
        if s.startswith(("BYP_BOUNCE", "FAN_BOUNCE")):
            r, c = slot(fos)
            pat2[("L4" if r == 4 else "L5", "even" if n % 2 == 0 else "odd")] += 1
print("BOUNCE 所在行 × 族序号奇偶：")
for k in sorted(pat2):
    print("  ", k, pat2[k])
