# -*- coding: utf-8 -*-
"""P1d：96 个 20 源 BEG 族的二分结构（cell = (frame, parity, bit)，bit 参与区分）。"""
import sqlite3, collections, re, itertools

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
beg = {f: d for f, d in fam.items() if len(d) == 20}

def two_color(edges):
    adj = collections.defaultdict(set)
    for a, b in edges:
        if a == b:
            return None
        adj[a].add(b)
        adj[b].add(a)
    color = {}
    for st in adj:
        if st in color:
            continue
        color[st] = 0
        stk = [st]
        while stk:
            u = stk.pop()
            for v in adj[u]:
                if v in color:
                    if color[v] == color[u]:
                        return None
                else:
                    color[v] = 1 - color[u]
                    stk.append(v)
    return color

def complete(edges, color):
    pos = collections.defaultdict(set)
    for a, b in edges:
        pos[a].add(b)
        pos[b].add(a)
    s0 = [n for n, c in color.items() if c == 0]
    s1 = [n for n, c in color.items() if c == 1]
    ok = all(len(pos[n]) == len(s1) for n in s0) and all(len(pos[n]) == len(s0) for n in s1)
    return ok, len(s0), len(s1)

shape, nonbip, dup = collections.Counter(), [], []
for f, d in beg.items():
    cells = {s: sorted(cs) for s, cs in d.items()}
    if any(len(v) != 2 for v in cells.values()):
        shape["非 2 格源"] += 1
        continue
    edges = [tuple(v) for v in cells.values()]
    col = two_color(edges)
    if col is None:
        nonbip.append(f)
        continue
    ok, a, b = complete(edges, col)
    shape[(f"K({a},{b})" if ok else f"二分 {a}+{b} 非完全")] += 1
    if a == 1 or b == 1:
        dup.append((f, a, b))

print("二分结构分布：")
for k, v in shape.most_common():
    print("   ", k, v)
if nonbip:
    print("非二分：", nonbip[:6], "共", len(nonbip))

# 一族的完整格子表（带 bit）
for name in ["EE2BEG0", "SS6BEG0"]:
    d = beg[name]
    print(f"\n{name}  bit 数 = {len({b for cs in d.values() for _,_,b in cs})}")
    for s in sorted(d):
        print(f"   {s:<16} {sorted(d[s])}")
