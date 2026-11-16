# -*- coding: utf-8 -*-
"""检验「6×4 网格」是数据里的完全叉积，还是我贴上去的命名。

做法：对每个族，不看族名也不看帧号，只从列重出发做二分：
  - 最轻的格（列重 min）= 组选择位；每个源应恰好含 1 个
  - 其余格 = 码字；每个源占其中若干
判据（三条，全过才算「完全叉积」）：
  A. 每个源恰好含 1 个组格
  B. 各组大小相同
  C. 每组的码字模式集合完全相同，且组大小 = 模式数（(组,码) 一一对应）
"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = db.execute(
    "select family,src_wire,frame_off,bit,parity from law_cells "
    "where tile_type='INT_L' and sense=1"
).fetchall()

fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

ok, bad, dims = [], [], collections.Counter()
for f, srcs in sorted(fam.items()):
    cnt = collections.Counter()
    for s, cs in srcs.items():
        for c in cs:
            cnt[c] += 1
    minw = min(cnt.values())
    grp = [c for c in cnt if cnt[c] == minw]
    other = set(cnt) - set(grp)

    gid, patterns, why = {}, collections.defaultdict(set), None
    for s, cs in srcs.items():
        hit = [c for c in cs if c in grp]
        if len(hit) != 1:
            why = "源含 %d 个组格" % len(hit); break
        gid[s] = hit[0]
        patterns[hit[0]].add(frozenset(cs & other))
    if why:
        bad.append((f, why)); continue

    sizes = {len([s for s in srcs if gid[s] == g]) for g in grp}
    if len(sizes) != 1:
        bad.append((f, "组大小不齐 %s" % sorted(sizes))); continue
    gsz = sizes.pop()
    psets = [patterns[g] for g in grp]
    if any(len(p) != gsz for p in psets):
        bad.append((f, "组内码字有重复")); continue
    if len({frozenset(p) for p in psets}) != 1:
        bad.append((f, "各组码字集合不同")); continue

    ok.append(f)
    dims[(len(grp), gsz, len(other))] += 1

print("族数 %d：完全叉积 %d，不满足 %d" % (len(fam), len(ok), len(bad)))
print("(组数, 每组源数, 码字数) 分布:", dict(dims))
for f, w in bad[:8]:
    print("  例外:", f, w)
