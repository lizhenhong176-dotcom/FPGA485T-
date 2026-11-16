# -*- coding: utf-8 -*-
"""P1：96 个 20 源 BEG 族 —— 二分结构定轴、两轴归属、配置种类、全量重建。

做法：
1. 每个 20 源族 = 一张二分图（源 = 边，两条 cell = 两端点），用 2-着色判定它是不是完全二分图；
2. 两端点分别记为 A 池（大）、B 池（小）；
3. 检验 B 是否只由「源的几何类别」决定、A 是否只由「源的方向令牌」决定；
4. 统计配置种类，并做「只用族名 + 一条配置表」的重建测试。
"""
import sqlite3, collections, re, json, os

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)1", s):
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    if s.startswith("GFAN"):
        return "gfan"
    if s.startswith(("BYP_", "FAN_")):
        return "bounce"
    return "other"

def direc(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|NL|SL|EL|WL|NR|SR|ER|WR)", s)
    if m:
        return m.group(1)
    if s.startswith("LOGIC_OUTS"):
        return "LOGIC_OUTS"
    if s.startswith("GFAN"):
        return "GFAN"
    if s.startswith("BYP_"):
        return "BYP_BOUNCE"
    if s.startswith("FAN_"):
        return "FAN_BOUNCE"
    return "other"

def two_color(cells_edges):
    """cells_edges: [(c1, c2)]，返回 ({node: 0/1}) 或 None（非二分）。"""
    adj = collections.defaultdict(set)
    for a, b in cells_edges:
        adj[a].add(b)
        adj[b].add(a)
    color = {}
    for start in adj:
        if start in color:
            continue
        color[start] = 0
        stack = [start]
        while stack:
            u = stack.pop()
            for v in adj[u]:
                if v in color:
                    if color[v] == color[u]:
                        return None
                else:
                    color[v] = 1 - color[u]
                    stack.append(v)
    return color

def complete_bipartite(edges, color):
    pos = collections.defaultdict(set)
    for a, b in edges:
        pos[a].add(b)
        pos[b].add(a)
    side0 = [n for n, c in color.items() if c == 0]
    side1 = [n for n, c in color.items() if c == 1]
    ok = all(len(pos[n]) == len(side1) for n in side0) and \
         all(len(pos[n]) == len(side0) for n in side1)
    return ok, side0, side1

stat = collections.Counter()
recs = {}
for f, d in fam.items():
    if len(d) != 20:
        continue
    cells = {s: sorted(cs) for s, cs in d.items()}
    if any(len(v) != 2 for v in cells.values()):
        stat["非 2 格源"] += 1
        continue
    edges = [(v[0], v[1]) for v in cells.values()]
    color = two_color(edges)
    if color is None:
        stat["非二分"] += 1
        continue
    ok, s0, s1 = complete_bipartite(edges, color)
    a_side, b_side = (s0, s1) if len(s0) >= len(s1) else (s1, s0)
    stat[f"{'完全' if ok else '非完全'}二分 A{len(a_side)}×B{len(b_side)}"] += 1
    recs[f] = (cells, a_side, b_side, ok)

print("结构统计：")
for k, v in sorted(stat.items()):
    print("  ", k, v)

# 只用「完全二分 K(5,4)」的族做规则检验
K54 = {f: v for f, v in recs.items() if v[3] and (len(v[1]), len(v[2])) == (5, 4)}
print(f"\nK(5,4) 族：{len(K54)}")

b_of_geo = collections.defaultdict(collections.Counter)   # geo -> 该族里出现的 B cell 槽位
a_of_dir = collections.defaultdict(collections.Counter)
per_fam_okb = per_fam_oka = 0
for f, (cells, A, B, _) in K54.items():
    # 把 A/B 变成「槽位序号」，以便跨族比较（按 frame_off 排序）
    aord = {c: i for i, c in enumerate(sorted(A))}
    bord = {c: i for i, c in enumerate(sorted(B))}
    g2b = collections.defaultdict(set)
    d2a = collections.defaultdict(set)
    for s, (x, y) in cells.items():
        a, b = (x, y) if x in aord else (y, x)
        g2b[geo(s)].add(bord[b])
        d2a[direc(s)].add(aord[a])
    if all(len(v) == 1 for v in g2b.values()):
        per_fam_okb += 1
        for g, v in g2b.items():
            b_of_geo[g][list(v)[0]] += 1
    if all(len(v) == 1 for v in d2a.values()):
        per_fam_oka += 1
        for k, v in d2a.items():
            a_of_dir[k][list(v)[0]] += 1

print(f"族内 B=f(几何类)：{per_fam_okb}/{len(K54)}")
print(f"族内 A=f(方向令牌)：{per_fam_oka}/{len(K54)}")
print("\n几何类 -> B 槽位分布：")
for g in sorted(b_of_geo):
    print("  ", g.ljust(8), dict(sorted(b_of_geo[g].items())))
print("\n方向令牌 -> A 槽位分布（前 6）：")
for k in sorted(a_of_dir)[:6]:
    print("  ", k.ljust(12), dict(sorted(a_of_dir[k].items())))
