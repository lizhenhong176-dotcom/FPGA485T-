# -*- coding: utf-8 -*-
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
m24 = {f: d for f, d in fam.items() if len(d) == 24}
print("24 源族数", len(m24))
groups = collections.Counter()
for f, d in m24.items():
    fr = sorted({fo for cs in d.values() for fo, _, _ in cs})
    ps = sorted({p for cs in d.values() for _, p, _ in cs})
    nb = len({b for cs in d.values() for _, _, b in cs})
    groups[(tuple(fr), tuple(ps), nb)] += 1
for k, v in groups.most_common():
    print(f"  {v:>3}  frames={k[0]} parity={k[1]} bits={k[2]}")
prefix = collections.Counter(re.sub(r"\d+$", "", f) for f in m24)
print("前缀分布：", dict(prefix))
