# -*- coding: utf-8 -*-
"""列出全部不满足完全叉积的族。"""
import sqlite3, collections

db = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = db.execute(
    "select family,src_wire,frame_off,bit,parity from law_cells "
    "where tile_type='INT_L' and sense=1"
).fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

bad = []
for f, srcs in sorted(fam.items()):
    cnt = collections.Counter()
    for s, cs in srcs.items():
        for c in cs:
            cnt[c] += 1
    mw = min(cnt.values())
    grp = {c for c in cnt if cnt[c] == mw}
    other = set(cnt) - grp
    per = sorted({len([c for c in cs if c in grp]) for cs in srcs.values()})
    if per != [1]:
        bad.append((f, len(srcs), "组格数/源=%s" % per))
        continue
    gid = {s: [c for c in cs if c in grp][0] for s, cs in srcs.items()}
    pat = collections.defaultdict(set)
    for s, cs in srcs.items():
        pat[gid[s]].add(frozenset(cs & other))
    sizes = {len(pat[g]) for g in grp}
    gsz = len(pat[next(iter(grp))])
    if len(sizes) != 1 or sizes.pop() != gsz:
        bad.append((f, len(srcs), "组内码字重复或组大小不齐"))
print("例外族数:", len(bad))
for b in bad:
    print(" ", b)
