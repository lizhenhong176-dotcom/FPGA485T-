# -*- coding: utf-8 -*-
"""P1e：BEG 两轴归属 —— Q 轴 = 几何类别？P 轴 = 方向令牌？（96 个 K(5,4)/K(4,5) 族）"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
beg = {f: d for f, d in fam.items() if len(d) == 20}

DIRS = ("EE|WW|NN|SS|NE|NW|SE|SW|NL|SL|EL|WL|NR|SR|ER|WR")

def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)", s):
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"

def tok(s):
    m = re.match(r"^(" + DIRS + ")", s)
    if m:
        return m.group(1)
    if s.startswith("LOGIC_OUTS"):
        return "LOGIC"
    return "other"

def color2(edges):
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b)
        adj[b].add(a)
    col, comp = {}, 0
    for st in adj:
        if st in col:
            continue
        col[st] = 0
        stk = [st]
        while stk:
            u = stk.pop()
            for v in adj[u]:
                if v not in col:
                    col[v] = 1 - col[u]
                    stk.append(v)
    return col

q_pure = 0        # Q 节点是否「一个几何类别」
p_by_tok_ok = 0   # 同一方向令牌是否落在同一 P 节点
cfg = collections.Counter()
tot_q = tot_p = 0
detail = {}
for f, d in beg.items():
    cells = {s: sorted(cs) for s, cs in d.items()}
    edges = [tuple(v) for v in cells.values()]
    col = color2(edges)
    sides = collections.defaultdict(list)
    for n, c in col.items():
        sides[c].append(n)
    # Q 侧 = 每个节点度数 5 的那侧（20 条边 / 5 = 4 个节点）
    deg = collections.Counter()
    for a, b in edges:
        deg[a] += 1
        deg[b] += 1
    big = [n for n in col if deg[n] == 5]
    small = [n for n in col if deg[n] == 4]
    if len(big) != 4 or len(small) != 5:
        detail[f] = ("度数异常", len(big), len(small))
        continue
    Q = set(big)
    node_of = {}
    for s, cs in cells.items():
        q = [c for c in cs if c in Q]
        p = [c for c in cs if c not in Q]
        node_of[s] = (p[0], q[0])
    # Q 纯度
    pure = True
    for q in Q:
        gs = {geo(s) for s, (p, qq) in node_of.items() if qq == q}
        tot_q += 1
        gs_nl = {g for g in gs}
        if len(gs) == 1:
            q_pure += 1
        elif gs <= {"line", "logic"}:
            q_pure += 1  # line/logic 共列是已知的 6/4 分配
        else:
            pure = False
    # P 由方向令牌决定？
    t2p = collections.defaultdict(set)
    for s, (p, q) in node_of.items():
        if tok(s) in ("LOGIC", "other"):
            continue
        t2p[tok(s)].add(p)
    ok = all(len(v) == 1 for v in t2p.values())
    tot_p += 1
    if ok:
        p_by_tok_ok += 1
    # 配置 = 每个方向令牌 -> P 节点（按 frame 排序后的序号）
    key = tuple(sorted((t, min(node_of[s][0] for s, (p, q) in node_of.items() if tok(s) == t)[0:2]) for t in t2p))
    cfg[key] += 1

print(f"Q 轴（度数 5 的 4 个节点）类别纯：{q_pure}/{tot_q}")
print(f"P 轴（度数 4 的 5 个节点）由方向令牌唯一决定：{p_by_tok_ok}/{tot_p}")
print(f"配置种类：{len(cfg)}（每种族数：{sorted(set(cfg.values()))}）")
if detail:
    print("异常族：", list(detail.items())[:5])

# 打印两族的 P 分组
for name in ["EE2BEG0", "WW2BEG0"]:
    if name not in beg:
        continue
    d = beg[name]
    cells = {s: sorted(cs) for s, cs in d.items()}
    edges = [tuple(v) for v in cells.values()]
    deg = collections.Counter()
    for a, b in edges:
        deg[a] += 1
        deg[b] += 1
    big = {n for n in deg if deg[n] == 5}
    grp = collections.defaultdict(list)
    for s, cs in cells.items():
        p = [c for c in cs if c not in big][0]
        grp[p].append(s)
    print(f"\n{name} P 轴（5 组）:")
    for p in sorted(grp):
        print("   ", p, sorted(grp[p]))
