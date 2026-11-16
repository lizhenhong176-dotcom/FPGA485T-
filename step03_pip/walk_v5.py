#!/usr/bin/env python3
"""walk_v5.py —— 在 walk_v1 的图上补齐 IO 侧拓扑（S23 结论），重跑 6 条输入网的后向走线。

新增的 tileconn 三类（类型级，靠 grid 坐标解析具体 tile）：
  1) LIOB18        -> LIOI               (+1,0)  IOB_PADOUT* -> LIOI_I*
  2) LIOI          -> IO_INT_INTERFACE_L (+1,0)  IOI_LOGIC_OUTS{k}_0 -> INT_INTERFACE_LOGIC_OUTS_L_B{k}
  3) IO_INT_INTERFACE_L (同 tile)         (0,0)  INT_INTERFACE_LOGIC_OUTS_L_B{k} -> INT_INTERFACE_LOGIC_OUTS_L{k}
  4) IO_INT_INTERFACE_L -> INT_L          (+1,0)  INT_INTERFACE_LOGIC_OUTS_L{k} -> LOGIC_OUTS_L{k}
     IO_INT_INTERFACE_L -> INT_R          (-1,0)  INT_INTERFACE_LOGIC_OUTS{k} -> LOGIC_OUTS{k}

用法: python walk_v5.py
"""
import json, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
TC = r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'

tg = json.load(open(TG))
name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
pos2tile = {(x, y): (n, t) for n, (x, y, t) in name2pos.items()}
tc = json.load(open(TC))

def build_extra():
    ex = []
    for k in range(24):
        ex.append(dict(tile_types=['LIOI', 'IO_INT_INTERFACE_L'], grid_deltas=[1, 0],
                       wire_pairs=[[f'IOI_LOGIC_OUTS{k}_0', f'INT_INTERFACE_LOGIC_OUTS_L_B{k}']]))
        ex.append(dict(tile_types=['IO_INT_INTERFACE_L', 'IO_INT_INTERFACE_L'], grid_deltas=[0, 0],
                       wire_pairs=[[f'INT_INTERFACE_LOGIC_OUTS_L_B{k}', f'INT_INTERFACE_LOGIC_OUTS_L{k}']]))
        ex.append(dict(tile_types=['IO_INT_INTERFACE_L', 'INT_L'], grid_deltas=[1, 0],
                       wire_pairs=[[f'INT_INTERFACE_LOGIC_OUTS_L{k}', f'LOGIC_OUTS_L{k}']]))
        ex.append(dict(tile_types=['IO_INT_INTERFACE_L', 'INT_R'], grid_deltas=[-1, 0],
                       wire_pairs=[[f'INT_INTERFACE_LOGIC_OUTS_L{k}', f'LOGIC_OUTS{k}']]))
    # IOB -> LIOI : pad 输出进入 ILOGIC 的 D（单源直通，名字按实测）
    ex.append(dict(tile_types=['LIOB18', 'LIOI'], grid_deltas=[1, 0],
                   wire_pairs=[['IOB_PADOUT0', 'LIOI_I0'], ['IOB_PADOUT1', 'LIOI_I1']]))
    ex.append(dict(tile_types=['LIOB18_SING', 'LIOI'], grid_deltas=[1, 0],
                   wire_pairs=[['IOB_PADOUT0', 'LIOI_I0'], ['IOB_PADOUT1', 'LIOI_I1']]))
    # LIOI 内部：IBUF -> ILOGIC -> IOI_LOGIC_OUTS
    for k in range(2):
        ex.append(dict(tile_types=['LIOI', 'LIOI'], grid_deltas=[0, 0],
                       wire_pairs=[[f'LIOI_I{k}', f'LIOI_ILOGIC{k}_D'],
                                   [f'LIOI_ILOGIC{k}_D', f'LIOI_ILOGIC{k}_DDLY'],
                                   [f'LIOI_ILOGIC{k}_D', f'IOI_ILOGIC{k}_O']]))
    for k in range(2):
        ex.append(dict(tile_types=['LIOI', 'LIOI'], grid_deltas=[0, 0],
                       wire_pairs=[[f'IOI_ILOGIC{k}_O', 'IOI_LOGIC_OUTS18_0']]))
    return ex

def main():
    alltc = tc + build_extra()
    bwd = collections.defaultdict(list)
    for p in alltc:
        t0, t1 = p['tile_types']
        dx, dy = p['grid_deltas']
        for w0, w1 in p['wire_pairs']:
            bwd[(t1, w1)].append((-dx, -dy, t0, w0))

    pips = json.load(open(os.path.join(HERE, 's13_pips.json')))
    PIP = {(p['tile'], p['fam']): p['src'] for p in pips}

    def land_b(T, w):
        x, y, t = name2pos[T]
        out = []
        for dx, dy, t1, w1 in bwd.get((t, w), []):
            T2 = pos2tile.get((x + dx, y + dy))
            if T2 and T2[1] == t1:
                out.append((T2[0], w1))
        return out

    def prev_nodes(t, w):
        pips_, lands = [], []
        if PIP.get((t, w)):
            pips_.append(((t, PIP[(t, w)]), (t, w)))
        for d in land_b(t, w):
            lands.append(d)
        drv = [d for d in lands if PIP.get(d)]
        oth = [d for d in lands if not PIP.get(d)]
        return pips_ + [(d, None) for d in drv + oth]

    def walk(start):
        def dfs(node, path, pset, seen):
            if len(path) > 200:
                return None
            for nxt, pe in prev_nodes(*node):
                if nxt in seen:
                    continue
                ps = set(pset)
                if pe is not None:
                    if pe in ps:
                        continue
                    ps.add(pe)
                np = path + [(nxt, pe)]
                if nxt[1].startswith(('IOB_', 'IOI_ILOGIC')) or name2pos[nxt[0]][2].startswith(('LIOB', 'LIOI')):
                    return np
                r = dfs(nxt, np, ps, seen | {nxt})
                if r:
                    return r
            return None
        return dfs(start, [(start, None)], set(), {start})

    C = 'INT_L_X6Y11'
    sinks = {'A1': 'SW2END3', 'A2': 'WW2END0', 'A3': 'WL1END0',
             'A4': 'SR1END1', 'A5': 'GFAN0', 'A6': 'WL1END1'}
    res = {}
    for k, w in sinks.items():
        r = walk((C, w))
        if not r:
            res[k] = {'status': 'fail'}
            print(k, 'FAIL')
            continue
        toks = [w2 for (t, w2), _ in r]
        res[k] = {'status': 'ok', 'nodes': [[t, w2] for (t, w2), _ in r]}
        print(f'{k}: {len(r)} nodes  ... {toks[-6:]}')
    json.dump(res, open(os.path.join(HERE, 's23_walk.json'), 'w'), indent=1)

if __name__ == '__main__':
    main()
