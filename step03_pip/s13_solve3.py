#!/usr/bin/env python3
"""s13_solve2.py —— 最大覆盖求解：9 条网全局互斥，目标=占用的 PIP 数最大。

物理依据：bitstream 里每个被解码的 PIP 必然属于某条网；9 条网之外还有
clk/ce/rst 等网，因此“覆盖最大”等价于“尽量把已被别的网占用的 PIP 让出来”。
"""
import json, collections, os, sys, time
sys.setrecursionlimit(10000)
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
    t0, t1 = p['tile_types']; dx, dy = p['grid_deltas']
    for w0, w1 in p['wire_pairs']:
        fwd[(t0, w0)].append((dx, dy, t1, w1))
        bwd[(t1, w1)].append((-dx, -dy, t0, w0))

# --- 追加 IO 侧类型级 tileconn（S23 实测拓扑）---
IO_TC = [
    ('LIOI', 'IO_INT_INTERFACE_L', (1, 0), [('IOI_LOGIC_OUTS%d_0' % k, 'INT_INTERFACE_LOGIC_OUTS_L_B%d' % k) for k in range(24)]),
    ('IO_INT_INTERFACE_L', 'IO_INT_INTERFACE_L', (0, 0), [('INT_INTERFACE_LOGIC_OUTS_L_B%d' % k, 'INT_INTERFACE_LOGIC_OUTS_L%d' % k) for k in range(24)]),
    ('IO_INT_INTERFACE_L', 'INT_L', (1, 0), [('INT_INTERFACE_LOGIC_OUTS_L%d' % k, 'LOGIC_OUTS_L%d' % k) for k in range(24)]),
    ('IO_INT_INTERFACE_L', 'INT_R', (-1, 0), [('INT_INTERFACE_LOGIC_OUTS_L%d' % k, 'LOGIC_OUTS%d' % k) for k in range(24)]),
]
for t0, t1, (dx, dy), pairs in IO_TC:
    for w0, w1 in pairs:
        fwd[(t0, w0)].append((dx, dy, t1, w1))
        bwd[(t1, w1)].append((-dx, -dy, t0, w0))

plist = json.load(open(os.path.join(HERE, 's13_pips.json')))
PIP = {(p['tile'], p['fam']): p['src'] for p in plist}
SRC2FAM = collections.defaultdict(list)
for (t, fam), s in PIP.items():
    SRC2FAM[(t, s)].append(fam)

def land_f(T, w):
    x, y, t = name2pos[T]; out = []
    for dx, dy, t1, w1 in fwd.get((t, w), []):
        T2 = pos2tile.get((x + dx, y + dy))
        if T2 and T2[1] == t1: out.append((T2[0], w1))
    return out

def land_b(T, w):
    x, y, t = name2pos[T]; out = []
    for dx, dy, t1, w1 in bwd.get((t, w), []):
        T2 = pos2tile.get((x + dx, y + dy))
        if T2 and T2[1] == t1: out.append((T2[0], w1))
    return out

def is_io(T):
    t = name2pos[T][2]
    return 'IOI' in t or 'IOB' in t

def prev_nodes(t, w):
    if PIP.get((t, w)):
        return [((t, PIP[(t, w)]), (t, w))]
    return [((d), None) for d in land_b(t, w)
            if PIP.get(d) or d[1].startswith('LOGIC_OUTS')]

def next_nodes(t, w):
    fams = SRC2FAM.get((t, w), [])
    if fams:
        return [((t, f), (t, f)) for f in fams]
    return [(d, None) for d in land_f(t, w) if is_io(d[0]) or SRC2FAM.get(d)]

def all_solutions(start, mode, limit=80, budget=[3_000_000]):
    res = []
    def dfs(node, path, pipset, seen):
        budget[0] -= 1
        if len(res) >= limit or budget[0] < 0 or len(path) > 140:
            return
        seq = prev_nodes(*node) if mode == 'back' else next_nodes(*node)
        if mode == 'back' and not seq:
            return
        if mode == 'fwd' and not seq and is_io(node[0]):
            res.append(path); return
        for nxt, pedge in seq:
            if nxt in seen: continue
            pset = pipset
            if pedge is not None:
                if pedge in pset: continue
                pset = pipset | {pedge}
            if mode == 'back' and nxt[1].startswith('LOGIC_OUTS'):
                res.append(path + [(nxt, pedge)]); continue
            dfs(nxt, path + [(nxt, pedge)], pset, seen | {nxt})
    dfs(start, [(start, None)], frozenset(), {start})
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
    cands = {}
    for name, mode, start in nets:
        cands[name] = all_solutions(start, mode)
        print(f'{name}: {len(cands[name])} cands', flush=True)
    order = sorted(nets, key=lambda n: len(cands[n[0]]))
    allpips = set(PIP)
    best = {'used': -1, 'sol': None}
    t0 = time.time()

    def rec(i, used, chosen):
        if time.time() - t0 > 240:
            return
        if i == len(order):
            if len(used) > best['used']:
                best['used'] = len(used); best['sol'] = dict(chosen)
                print('  best ->', best['used'], flush=True)
            return
        name = order[i][0]
        # 剪枝：剩余最大可达
        for sol in cands[name]:
            pset = frozenset(e for _, e in sol if e)
            if pset & used: continue
            chosen[name] = sol
            rec(i + 1, used | pset, chosen)
            chosen.pop(name, None)

    rec(0, frozenset(), {})
    print('BEST used', best['used'], '/', len(PIP))
    out = {}
    LAB = {'A1':'I0','A2':'I1','A6':'I2','A3':'I3','A4':'I4','A5':'I5'}
    def route_beg(f):
        t = open(os.path.join(HERE, 'route_%s.txt' % f), encoding='utf-8', errors='replace').read()
        if 'ROUTE' in t: t = t.split('ROUTE', 1)[1]
        return [x for x in t.replace('{', ' ').replace('}', ' ').split() if 'BEG' in x]
    for name, mode, start in nets:
        sol = best['sol'].get(name)
        if not sol: continue
        if name in LAB:
            beg = [w for (t, w), _ in sol[::-1] if 'BEG' in w]
            rb = route_beg(LAB[name])
            print('==', name, LAB[name], len(beg), len(rb), 'EXACT' if beg == rb else 'DIFF')
            if beg != rb:
                print('   walk ', beg)
                print('   route', rb)
        ps = {e for _, e in sol if e}
        toks = [w for (t, w), _ in sol]
        out[name] = {'status': 'ok', 'nodes': [[t, w] for (t, w), _ in sol],
                     'tokens': toks, 'pips': sorted(f'{a}|{b}' for a, b in ps)}
    json.dump(out, open(os.path.join(HERE, 's13_solution3.json'), 'w'), indent=1)

if __name__ == '__main__':
    main()
