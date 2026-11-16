# -*- coding: utf-8 -*-
"""Dump the 6 long-line families as two-cell edge codes: src -> (cellA, cellB)."""
import sqlite3, collections
DB = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(DB); cur = con.cursor()
FAMS = ["LH0","LH12","LVB_L0","LVB_L12","LV_L0","LV_L18"]
cur.execute("select family, src_wire, frame_off, bit, parity from law_cells where tile_type='INT_L' and sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in cur.fetchall():
    if f in FAMS: fam[f][s].add((fo, b, p))
for f in FAMS:
    srcs = fam[f]
    # adjacency: two cells share an edge iff same src
    cell2src = collections.defaultdict(set)
    for s, cs in srcs.items():
        for c in cs: cell2src[c].add(s)
    # bipartite: build graph over cells, edges = co-occurrence in a src
    adj = collections.defaultdict(set)
    for s, cs in srcs.items():
        cs = sorted(cs)
        for i in range(len(cs)):
            for j in range(i+1, len(cs)):
                adj[cs[i]].add(cs[j]); adj[cs[j]].add(cs[i])
    color = {}
    for start in adj:
        if start in color: continue
        color[start] = 0; st = [start]
        while st:
            u = st.pop()
            for v in adj[u]:
                if v not in color: color[v] = 1 - color[u]; st.append(v)
    A = sorted([c for c in color if color[c]==0]); B = sorted([c for c in color if color[c]==1])
    print("=== %s  srcs=%d cells=%d  A=%d B=%d" % (f, len(srcs), len(color), len(A), len(B)))
    print("  A:", A); print("  B:", B)
    rows = []
    for s, cs in sorted(srcs.items()):
        a = [c for c in cs if color.get(c)==0]; b = [c for c in cs if color.get(c)==1]
        rows.append((s, a[0] if a else None, b[0] if b else None))
    for s, a, b in rows:
        print("   %-16s A=%-14s B=%s" % (s, a, b))
con.close()