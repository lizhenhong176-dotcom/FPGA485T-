#!/usr/bin/env python3
"""walk_out.py —— S12: 输出网正向走线（bitstream-only）。

种子 = 解码出的 LOGIC_OUTS 驱动 PIP（INT_L_X6Y11 侧）。
正向步进：
  1. PIP (T, fam, src) → 驱动节点 (T, fam)
  2. 节点 (T, w) 的 tileconn 前向落点 (T+delta, w2)（要求落点 tile 类型匹配）
  3. 落点若被某 PIP 的 src 命中 → 下一跳（可能多分支，DFS 回溯）
  4. 终点 = 落点 tile 非 INT 类型（IO 侧）或无前向连接
验证：与远端 route_o*.txt 的节点序列对账（fabric 段）。
"""
import json, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
TC = r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'


def main():
    tg = json.load(open(TG))
    name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
    pos2tile = {(x, y): (n, t) for n, (x, y, t) in name2pos.items()}
    tc = json.load(open(TC))
    fwd = collections.defaultdict(list)
    for p in tc:
        t0, t1 = p['tile_types']
        dx, dy = p['grid_deltas']
        for w0, w1 in p['wire_pairs']:
            fwd[(t0, w0)].append((dx, dy, t1, w1))

    pips = json.load(open(os.path.join(HERE, 's8_int_pips_v2.json')))
    by_src = collections.defaultdict(list)
    for p in pips:
        by_src[(p['tile'], p['src'])].append(p)

    seeds = [p for p in pips if p['src'].startswith('LOGIC_OUTS')]

    def dests(T, w):
        x, y, t = name2pos[T]
        out = []
        for dx, dy, t1, w1 in fwd.get((t, w), []):
            T2 = pos2tile.get((x + dx, y + dy))
            if T2 and T2[1] == t1:
                out.append((T2[0], w1))
        return out

    def walk(node, seen):
        """从已驱动节点 (T, fam) 前向走；返回 (节点链, 状态)。
        只有到达 IOI/IOB tile 才算成功（'io'）。"""
        path = [node]
        cur = node
        while True:
            BUDGET[0] -= 1
            if BUDGET[0] < 0 or len(path) > 200:
                return path, 'budget'
            if cur in seen:
                return path, 'revisit'
            seen.add(cur)
            nxt = by_src.get(cur)
            if nxt:
                if len(nxt) > 1:
                    for p in nxt:
                        sub, st = walk((p['tile'], p['fam']), set(seen))
                        if st == 'io':
                            return path + sub, st
                    return path, 'deadend'
                p = nxt[0]
                cur = (p['tile'], p['fam'])
                path.append(cur)
                continue
            ds = dests(*cur)
            if not ds:
                t = name2pos[cur[0]][2]
                return path, ('io' if ('IOI' in t or 'IOB' in t) else 'deadend')

            def rank(d):
                if by_src.get(d):
                    return 0
                t = name2pos[d[0]][2]
                return 1 if ('IOI' in t or 'IOB' in t) else 2

            for d in sorted(ds, key=rank):
                sub, st = walk(d, set(seen))
                if st == 'io':
                    return path + sub, st
            return path, 'deadend'

    BUDGET = [200000]
    res = {}
    for p in seeds:
        chain, st = walk((p['tile'], p['fam']), set())
        tokens = [w for _, w in chain[::1]]
        res[p['src']] = {'seed_pip': f"{p['fam']}<-{p['src']}",
                         'status': st, 'n_nodes': len(chain),
                         'chain': [[t, w] for t, w in chain]}
        print(f"{p['src']}: {st}, {len(chain)} nodes, tokens[:12]={tokens[:12]}")
        print('  ... tail:', tokens[-8:])
    json.dump(res, open(os.path.join(HERE, 's8_walk_out.json'), 'w'), indent=1)
    return 0


if __name__ == '__main__':
    sys.exit(main())
