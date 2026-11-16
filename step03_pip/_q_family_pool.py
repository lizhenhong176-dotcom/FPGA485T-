# -*- coding: utf-8 -*-
import sqlite3, collections
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("select family, src_wire, frame_off, bit, parity from law_cells where tile_type='INT_L' and sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))   # family -> src -> cells
for f, s, fo, b, p in cur.fetchall(): fam[f][s].add((fo, b, p))
def summ(f):
    cells = {c for s in fam[f].values() for c in s}
    fos = sorted({c[0] for c in cells}); bits = sorted({c[2] for c in cells})
    pars = sorted({c[1] for c in cells})
    return len(fam[f]), len(cells), (min(fos), max(fos)), pars, bits
for f in ["IMUX_L40","IMUX_L0","EE2BEG0","SS6BEG1","LH0","LVB_L0","CLK_L0","GFAN0","CTRL_L1"]:
    if f in fam:
        n, nc, rng, pars, bits = summ(f)
        print("%-10s src=%-3d cells=%-3d fo=%s parity=%s bits=%s" % (f, n, nc, rng, pars, bits))
    else:
        print("%-10s MISSING" % f)
# pool usage per tile
used = {(c[0], c[1], c[2]) for f in fam for s in fam[f].values() for c in s}
print("distinct (fo,parity,bit) in INT_L:", len(used), "of pool 26*2*32 =", 26*2*32)
byfo = collections.Counter(c[0] for c in used)
print("bits per frame_off:", dict(sorted(byfo.items())))
con.close()