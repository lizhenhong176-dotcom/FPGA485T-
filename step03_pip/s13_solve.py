#!/usr/bin/env python3
"""s13_solve.py —— INT PIP 全局一致性求解（bitstream-only, 9 网）。

图：节点 = (tile, wire)
  反向边（输入网用）: (t,fam) -> (t,src)   其中 (t,fam,src) 是候选 PIP
                      (t,end) -> (t2,beg)  其中 beg@t2 经 tileconn 落到 end@t
  正向边（输出网用）: (t,fam) -> (t2,end)  经 tileconn 前向落点
全局约束：每条候选 PIP 最多被一条网使用（9 条网路径互斥）。

用法: python s13_solve.py
输出: s13_solution.json
"""
import json, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
TC = r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'

tg = json.load(open(TG))
name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
pos2tile = {(x, y): (n, t) for n, (x, y, t) in name2pos.items()}
tc = json.load(open(TC))
fwd = collections.defaultdict(list)
bwd = collections.defaultdict(list)
for p in tc:
    t0, t1 = p['tile_types']
    dx, dy = p['grid_deltas']
    for w0, w1 in p['wire_pairs']:
        fwd[(t0, w0)].append((dx, dy, t1, w1))
        bwd[(t1, w1)].append((-dx, -dy, t0, w0))

plist = json.load(open(os.path.join(HERE, 's13_pips.json')))
PIP = {}
for p_ in plist:
    PIP[(p_['tile'], p_['fam'])] = p_['src']

def land_f(T, w):
    x, y, t = name2pos[T]
    out = []
    for dx, dy, t1, w1 in fwd.get((t, w), []):
        T2 = pos2tile.get((x + dx, y + dy))
        if T2 and T2[1] == t1:
            out.append((T2[0], w1))
    return out

def land_b(T, w):
    x, y, t = name2pos[T]
    out = []
    for dx, dy, t1, w1 in bwd.get((t, w), []):
        T2 = pos2tile.get((x + dx, y + dy))
        if T2 and T2[1] == t1:
            out.append((T2[0], w1))
    return out

def prev_nodes(t, w):
    """反向一步（productive 剪枝）：末端线必须被某 PIP 驱动，或本身是 IO 入口。"""
    if PIP.get((t, w)):
        return [((t, PIP[(t, w)]), (t, w))]
    out = []
    for d in land_b(t, w):
        if PIP.get(d) or d[1].startswith('LOGIC_OUTS'):
            out.append((d, None))
    return out

SRC2FAM = collections.defaultdict(list)
for (t, fam), s in PIP.items():
    if s:
        SRC2FAM[(t, s)].append(fam)

def next_nodes(t, w):
    """正向一步（productive 剪枝）：先看 mux 延续，否则只看通向 IO 或可再驱动的落点。"""
    fams = SRC2FAM.get((t, w), [])
    if fams:
        return [((t, f), (t, f)) for f in fams]
    out = []
    for d in land_f(t, w):
        if is_io(d[0]) or SRC2FAM.get(d):
            out.append((d, None))
    return out

def is_io(T):
    return ('IOI' in name2pos[T][2] or 'IOB' in name2pos[T][2])

def walk_back(start, used, budget=[300000]):
    """从 sink 反向走到 IO 入口（src 以 LOGIC_OUTS 开头的 PIP）或无线可走。"""
    def dfs(node, path, pipset, seen):
        budget[0] -= 1
        if budget[0] < 0 or len(path) > 120:
            return None
        for nxt, pipedge in prev_nodes(*node):
            if nxt in seen:
                continue
            pset = set(pipset)
            if pipedge is not None:
                if pipedge in used or pipedge in pset:
                    continue
                pset.add(pipedge)
            if nxt[1].startswith('LOGIC_OUTS'):
                return path + [(nxt, pipedge)]
            r = dfs(nxt, path + [(nxt, pipedge)], pset, seen | {nxt})
            if r:
                return r
        return None
    return dfs(start, [(start, None)], set(), {start})

def walk_fwd(start_pip, used, budget=[300000]):
    def dfs(node, path, pipset, seen):
        budget[0] -= 1
        if budget[0] < 0 or len(path) > 120:
            return None
        exps = next_nodes(*node)
        if not exps and is_io(node[0]):
            return path
        for nxt, pedge in exps:
            if nxt in seen:
                continue
            pset = set(pipset)
            if pedge is not None:
                if pedge in used or pedge in pset:
                    continue
                pset.add(pedge)
            r = dfs(nxt, path + [(nxt, pedge)], pset, seen | {nxt})
            if r:
                return r
        return None
    node = (start_pip[0], start_pip[1])
    return dfs(node, [(node, start_pip)], set(), {node})

def all_solutions(start, mode, used, limit=60):
    """枚举一条网的至多 limit 条候选路径（不与 used 冲突）。"""
    res = []
    budget = [2000000]

    def dfs(node, path, pipset, seen):
        if len(res) >= limit or budget[0] < 0:
            return
        budget[0] -= 1
        if len(path) > 120:
            return
        seq = prev_nodes(*node) if mode == 'back' else next_nodes(*node)
        if mode == 'back':
            for nxt, pedge in seq:
                if nxt in seen:
                    continue
                pset = set(pipset)
                if pedge is not None:
                    if pedge in used or pedge in pset:
                        continue
                    pset.add(pedge)
                if nxt[1].startswith('LOGIC_OUTS'):
                    res.append(path + [(nxt, pedge)])
                    continue
                dfs(nxt, path + [(nxt, pedge)], pset, seen | {nxt})
        else:
            if not seq and is_io(node[0]):
                res.append(path)
                return
            for nxt, pedge in seq:
                if nxt in seen:
                    continue
                pset = set(pipset)
                if pedge is not None:
                    if pedge in used or pedge in pset:
                        continue
                    pset.add(pedge)
                dfs(nxt, path + [(nxt, pedge)], pset, seen | {nxt})

    dfs(start, [(start, None)], set(), {start})
    return res


def main():
    C = 'INT_L_X6Y11'
    nets = [
        ('A1', 'back', (C, 'SW2END3')),
        ('A2', 'back', (C, 'WW2END0')),
        ('A3', 'back', (C, 'WL1END0')),
        ('A4', 'back', (C, 'SR1END1')),
        ('A5', 'back', (C, 'GFAN0')),
        ('A6', 'back', (C, 'WL1END1')),
        ('o', 'fwd', ('INT_L_X6Y11', 'EE4BEG0')),
        ('o2', 'fwd', ('INT_L_X6Y11', 'NE6BEG0')),
        ('o3', 'fwd', ('INT_R_X31Y51', 'NE2BEG0')),
    ]
    # 每网枚举候选
    cands = {}
    for name, mode, start in nets:
        sols = all_solutions(start, mode, set())
        cands[name] = sols
        print(f'{name}: {len(sols)} solutions, lens={[len(x) for x in sols]}')

    order = sorted(nets, key=lambda n: len(cands[n[0]]))
    print('order:', [n[0] for n in order])

    best = {}

    def rec(i, used, chosen):
        if i == len(order):
            return dict(chosen)
        name = order[i][0]
        for sol in cands[name]:
            pset = {edge for _, edge in sol if edge}
            if pset & used:
                continue
            chosen[name] = sol
            r = rec(i + 1, used | pset, chosen)
            if r:
                return r
            chosen.pop(name, None)
        return None

    sol = rec(0, set(), {})
    if not sol:
        print('NO JOINT SOLUTION')
        return
    out = {}
    used = set()
    for name, mode, start in nets:
        r = sol[name]
        pset = {edge for _, edge in r if edge}
        used |= pset
        toks = [w for (t, w), _ in r]
        out[name] = {'status': 'ok', 'nodes': [[t, w] for (t, w), _ in r],
                     'tokens': toks, 'pips': sorted(f'{a}|{b}' for a, b in pset)}
        print(f'{name}: {len(r)} nodes  {toks[:6]} ... {toks[-4:]}')
    json.dump(out, open(os.path.join(HERE, 's13_solution.json'), 'w'), indent=1)
    print('used pips:', len(used), '/', len(PIP))


if __name__ == '__main__':
    main()
