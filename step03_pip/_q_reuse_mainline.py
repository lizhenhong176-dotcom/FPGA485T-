# -*- coding: utf-8 -*-
"""量化 PIP 复用：层次计数、形状分类、跨族共享、实例抽取。"""
import sqlite3, collections, json, sys

DB = r"E:\v7work\model\v7_law.sqlite"
db = sqlite3.connect(DB)

def load(tt):
    rows = db.execute(
        "select family,src_wire,frame_off,bit,parity,sense from law_cells where tile_type=?", (tt,)
    ).fetchall()
    s1 = [r for r in rows if r[5] == 1]
    fam = collections.defaultdict(lambda: collections.defaultdict(set))
    for f, s, fo, b, p, se in s1:
        fam[f][s].add((fo, p, b))
    return rows, s1, fam

for tt in ("INT_L", "INT_R"):
    rows, s1, fam = load(tt)
    print(f"== {tt}: total {len(rows)} sense1 {len(s1)} sense0 {len(rows)-len(s1)} families {len(fam)}")
    shapes = collections.Counter()
    cells_all = collections.defaultdict(set)
    feats = 0
    for f, srcs in fam.items():
        cells = set().union(*srcs.values())
        shapes[(len(cells), len(srcs))] += 1
        feats += len(srcs)
        for c in cells:
            cells_all[c].add(f)
    print("   features", feats, "distinct cells", len(cells_all))
    print("   shapes", sorted(shapes.items(), key=lambda x: -x[1]))
    multi = {c: sorted(v) for c, v in cells_all.items() if len(v) > 1}
    print("   cross-family cells", len(multi), list(multi.items())[:5])
    share = collections.Counter(len(v) for v in cells_all.values())
    print("   share dist", sorted(share.items()))
    # per-feature cell count distribution
    pc = collections.Counter(len(v) for srcs in fam.values() for v in srcs.values())
    print("   cells-per-feature", sorted(pc.items()))
    if tt == "INT_L":
        # 每类形状的实例
        inst = {}
        for f, srcs in fam.items():
            key = (len(set().union(*srcs.values())), len(srcs))
            inst.setdefault(key, (f, sorted(srcs)[:3],
                                  sorted(sorted(v) for v in list(srcs.values())[:3])))
        for k in sorted(inst, key=lambda x: -x[1]):
            f, ss, cs = inst[k]
            print(f"   inst {k} -> {f} srcs={ss} cells0={cs}")
        # 子集对
        pairs = 0
        nested2 = 0
        for f, srcs in fam.items():
            sets = {s: frozenset(v) for s, v in srcs.items()}
            items = list(sets.items())
            for i in range(len(items)):
                for j in range(len(items)):
                    if i != j and items[i][1] < items[j][1]:
                        pairs += 1
                        if len(items[i][1]) == 2:
                            nested2 += 1
        print("   strict subset pairs", pairs, "2-cell nested", nested2)
        # 形状总数
        print("   shapes total", sum(shapes.values()))
