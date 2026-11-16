# -*- coding: utf-8 -*-
"""Test: is (A,B) cell choice a function of the source's index in template pip_defs order?"""
import json, sqlite3, collections
T = json.load(open(r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json", encoding="utf-8"))
pips = T["pip_defs"]           # [src, dst, delay, inverted]
fam2order = collections.defaultdict(list)
for e in pips:
    fam2order[e[1]].append(e[0])
DB = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(DB); cur = con.cursor()
cur.execute("select family, src_wire, frame_off, bit, parity from law_cells where tile_type='INT_L' and sense=1")
cells = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in cur.fetchall(): cells[f][s].add((fo,b,p))
FAMS = ["LH0","LH12","LVB_L0","LVB_L12","LV_L0","LV_L18"]
for f in FAMS:
    order = fam2order[f]
    print("=== %s  pip_defs order (%d):" % (f, len(order)))
    print("   ", [(i, s) for i, s in enumerate(order)])
    srcs = cells[f]
    # bipartition (same as before)
    adj = collections.defaultdict(set)
    for s, cs in srcs.items():
        cs = sorted(cs)
        for i in range(len(cs)):
            for j in range(i+1, len(cs)):
                adj[cs[i]].add(cs[j]); adj[cs[j]].add(cs[i])
    color = {}
    for st0 in adj:
        if st0 in color: continue
        color[st0] = 0; st=[st0]
        while st:
            u = st.pop()
            for v in adj[u]:
                if v not in color: color[v]=1-color[u]; st.append(v)
    for i, s in enumerate(order):
        cs = srcs.get(s)
        if cs is None: print("    %2d %-14s NOT IN law_cells" % (i, s)); continue
        a=[c for c in cs if color.get(c)==0]; b=[c for c in cs if color.get(c)==1]
        print("    %2d %-14s A=%-12s B=%s" % (i, s, a[0] if a else None, b[0] if b else None))
con.close()