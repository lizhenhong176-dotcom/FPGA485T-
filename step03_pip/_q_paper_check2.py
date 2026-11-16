# -*- coding: utf-8 -*-
import sqlite3, collections
l = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
# (a) mux 族的 row4/row5 组成：把 frame_off 16..21 当行 0..5
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, par, bit in l.execute(
    "select family, src_wire, frame_off, parity, bit from law_cells where tile_type='INT_L' and sense=1"):
    fam[f][s].add((fo, par, bit))
names24 = [f for f, d in fam.items() if len(d) == 24]
print("24源族数:", len(names24))
def rowcls(s):
    s = s.replace("LOGIC_OUTS_L", "LOGIC_OUTS")
    if "BOUNCE" in s: return "bounce"
    if s.startswith("GFAN"): return "gfan"
    if s.startswith("LOGIC_OUTS"): return "logic"
    return "line"
comp = collections.Counter()
for f in names24:
    byrow = collections.defaultdict(list)
    for s, cells in fam[f].items():
        rows = {fo - 16 for fo, par, bit in cells if 16 <= fo <= 21}
        for r in rows: byrow[r].append(rowcls(s))
    comp[(tuple(sorted(byrow.get(4, []))), tuple(sorted(byrow.get(5, []))))] += 1
print("row4/row5 组成（前 5 种）:")
for k, v in comp.most_common(5): print("  row4=%s row5=%s  ×%d" % (k[0], k[1], v))
# (b) BEG 族二分侧大小
beg = [f for f, d in fam.items() if len(d) == 20]
def bipart(f):
    nodes = set()
    edges = []
    for s, cells in fam[f].items():
        a, b = tuple(sorted(cells))
        nodes |= {a, b}; edges.append((a, b))
    adj = collections.defaultdict(set)
    for a, b in edges: adj[a].add(b); adj[b].add(a)
    color = {}
    for n in nodes:
        if n in color: continue
        color[n] = 0; q = [n]
        while q:
            u = q.pop()
            for v in adj[u]:
                if v in color:
                    if color[v] == color[u]: return None
                else:
                    color[v] = 1 - color[u]; q.append(v)
    A = sum(1 for v in color.values() if v == 0); B = len(color) - A
    return (min(A, B), max(A, B), len(edges))
dist = collections.Counter(bipart(f) for f in beg)
print("BEG 族数:", len(beg))
print("二分侧大小分布 (小,大,边数):")
for k, v in sorted(dist.items()): print("  %s ×%d" % (k, v))
l.close()