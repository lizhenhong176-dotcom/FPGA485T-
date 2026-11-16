# -*- coding: utf-8 -*-
"""Are the A/B ordinals of a source consistent across the 6 long-line families?"""
import sqlite3, collections
DB = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(DB); cur = con.cursor()
cur.execute("select family, src_wire, frame_off, bit, parity from law_cells where tile_type='INT_L' and sense=1")
cells = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in cur.fetchall(): cells[f][s].add((fo,b,p))
FAMS = ["LH0","LH12","LVB_L0","LVB_L12","LV_L0","LV_L18"]
idxA, idxB = collections.defaultdict(dict), collections.defaultdict(dict)
for f in FAMS:
    srcs = cells[f]
    adj = collections.defaultdict(set)
    for s, cs in srcs.items():
        cs = sorted(cs)
        for i in range(len(cs)):
            for j in range(i+1, len(cs)):
                adj[cs[i]].add(cs[j]); adj[cs[j]].add(cs[i])
    color = {}
    for st0 in adj:
        if st0 in color: continue
        color[st0]=0; st=[st0]
        while st:
            u = st.pop()
            for v in adj[u]:
                if v not in color: color[v]=1-color[u]; st.append(v)
    A = sorted([c for c in color if color[c]==0]); B = sorted([c for c in color if color[c]==1])
    ra, rb = {c:i for i,c in enumerate(A)}, {c:i for i,c in enumerate(B)}
    # baseline: the "unselected" cell of an axis is the one whose bit is 0 for most srcs? keep raw ordinals for now
    for s, cs in srcs.items():
        a=[c for c in cs if color.get(c)==0]; b=[c for c in cs if color.get(c)==1]
        if a: idxA[s][f]=ra[a[0]]
        if b: idxB[s][f]=rb[b[0]]
names = sorted(set(idxA) | set(idxB))
print("%-14s %-28s %-28s" % ("src", "A-ordinal by family", "B-ordinal by family"))
for s in names:
    print("%-14s %-28s %-28s" % (s, idxA.get(s), idxB.get(s)))
con.close()