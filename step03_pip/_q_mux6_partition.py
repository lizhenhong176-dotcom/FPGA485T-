# -*- coding: utf-8 -*-
import sqlite3, collections, re
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off FROM law_cells WHERE tile_type='INT_L' AND sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in cur.fetchall(): fam[f][s].add(fo)
mux = {f: v for f, v in fam.items() if len(v) == 24}
def norm(s):
    return re.sub(r"_N\d+_\d+$", "", re.sub(r"_S\d+$", "", s))
parts = collections.Counter(); code_by_group = collections.Counter(); per = {}
for f, srcs in mux.items():
    r2s = collections.defaultdict(list)
    for s, fos in srcs.items():
        grp = [x for x in fos if 16 <= x <= 21]
        if len(grp) == 1 and grp[0] <= 19: r2s[grp[0]].append(s)
    part = frozenset(frozenset(norm(s) for s in v) for v in r2s.values())
    parts[part] += 1
    per[f] = (part, r2s)
print("线源四组划分的不同数:", len(parts), "→ 族数分布:", sorted(parts.values()))
main = parts.most_common(1)[0][0]
print("族数 =", parts.most_common(1)[0][1])
print("\n唯一的四组划分（去后缀名）:")
for g in sorted(main, key=lambda x: sorted(x)):
    print("   ", sorted(g))
print("\n每组内的列码（取 IMUX_L40）:")
for r, ss in sorted(per["IMUX_L40"][1].items()):
    print("  row", r, [(s, sorted(fo for fo in mux['IMUX_L40'][s] if fo >= 22)) for s in ss])