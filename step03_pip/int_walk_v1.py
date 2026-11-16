#!/usr/bin/env python3
"""
int_walk_v1.py —— V7 全芯片 INT PIP 解码 + 反向走线（bitstream-only）。

关键规则（本阶段实测+artix7 tilegrid 佐证）：
  INT tile 行字 = 2*(Y%50) + (1 if (Y%50)>=25 else 0)
  （每 50 行时钟区的下半 25 行整体 +1 字；artix7 tilegrid offset 佐证：
   Y0-24 offset=2Y，Y25-49 offset=2Y+1，gy 在 234 处跳一格。）
  cell 字 = tile行字 + parity（prjxray segbits bit>=32 → 第二字）。
  帧基址 = 该 INT 所在列的 CLB 块（clb_blocks），若 X 无 CLB 列
  （INT 处于 BRAM/接口夹缝列）则用 28 帧接口块 = 前一 CLB 块 + 36。

解码：对每个 INT_L/INT_R tile 实例，按 (family,src) 组逐组核对
  sense=1 位全置 1、sense=0 位全清 0 → 该 PIP 激活。

走线：从 IMUX 源线（CSP 解）反向：PIP 源 → tileconn 起点（取被
  PIP 驱动者，按 |dx|+|dy| 近者优先，DFS 回溯），终点 = 无驱动起点
  （IO 入口区域，属已知盲区：INT_INTERFACE↔INT 的 tileconn 不在库中）。

用法：python int_walk_v1.py   （依赖 s8_all_frames.json / all_cells.json /
     E:\\v7work\\db\\prjxray\\xc7vx485t\\{tilegrid,tileconn}.json /
     E:\\v7work\\model\\v7_law.sqlite clb_blocks 表）
输出：s8_int_pips_v2.json（全部激活 INT PIP）、s8_walk_in_v3.json（6 条输入网链）。
"""
import json, re, sqlite3, collections, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
TC = r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'
LAW = r'E:\v7work\model\v7_law.sqlite'


def wof(Y):
    y = Y % 50
    return 2 * y + (1 if y >= 25 else 0)


def main():
    tg = json.load(open(TG))
    name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
    pos2tile = {(x, y): (n, t) for n, (x, y, t) in name2pos.items()}
    db = sqlite3.connect(LAW)
    clb_blocks = {(gc, band): base for gc, band, base in
                  db.execute('select grid_col, band, base_frame from clb_blocks')}
    cells = json.load(open(os.path.join(HERE, 'all_cells.json')))
    fr = {int(k): v for k, v in json.load(
        open(os.path.join(HERE, 's8_all_frames.json'))).items()}
    nz = set(fr)

    # X -> CLB 列 gc
    x2gc = {}
    for n, (x, y, t) in name2pos.items():
        if t.startswith('CLBL'):
            m = re.search(r'_X(\d+)Y', n)
            if m:
                x2gc.setdefault(int(m.group(1)), x)
    # 每带 CLB 列按 grid_x 排序，用于"西侧最近 CLB 列"
    cols_by_band = collections.defaultdict(list)
    for X, gx in x2gc.items():
        for (gc, band), base in clb_blocks.items():
            if gc == gx:
                cols_by_band[band].append((gx, base))
    for band in cols_by_band:
        cols_by_band[band].sort()

    def west_base(x, band):
        best = None
        for gx, base in cols_by_band.get(band, []):
            if gx < x:
                best = base
            else:
                break
        return best

    tile_block = {}
    for n, (x, y, t) in name2pos.items():
        if t not in ('INT_L', 'INT_R'):
            continue
        m = re.search(r'_X(\d+)Y(\d+)$', n)
        if not m:
            continue
        X, Y = int(m.group(1)), int(m.group(2))
        band = Y // 50
        if X in x2gc and (x2gc[X], band) in clb_blocks:
            base = clb_blocks[(x2gc[X], band)]
        else:
            # 夹缝列（BRAM/接口/IO 中心）：西侧 CLB 块 + 36 (INT_L) / +68 (INT_R)
            wb = west_base(x, band)
            base = None if wb is None else wb + (36 if t == 'INT_L' else 68)
        tile_block[n] = (base, band, X, Y, t)

    groups = collections.defaultdict(list)
    for c in cells:
        groups[(c['tile_type'], c['family'], c['src_wire'])].append(c)
    tt_feats = collections.defaultdict(list)
    for (tt, fam, src), cs in groups.items():
        tt_feats[tt].append((fam, src, cs))
    fo_cache = {tt: sorted({c['frame_off'] for c in cells
                            if c['tile_type'] == tt}) for tt in tt_feats}

    pips = []
    for n, (base, band, X, Y, tt) in tile_block.items():
        if base is None:
            continue
        if not any((base + o) in nz for o in fo_cache[tt]):
            continue
        w0 = wof(Y)
        for fam, src, cs in tt_feats[tt]:
            ok = True
            for c in cs:
                f = base + c['frame_off']
                if f not in nz:
                    ok = False
                    break
                v = fr[f][w0 + c['parity']]
                if ((v >> c['bit']) & 1) != c['sense']:
                    ok = False
                    break
            if ok:
                pips.append({'tile': n, 'type': tt, 'fam': fam,
                             'src': src, 'X': X, 'Y': Y})
    json.dump(pips, open(os.path.join(HERE, 's8_int_pips_v2.json'), 'w'))
    print('active INT PIPs:', len(pips))

    # ---- 反向走线 ----
    tc = json.load(open(TC))
    bwd = collections.defaultdict(list)
    for p in tc:
        t0, t1 = p['tile_types']
        dx, dy = p['grid_deltas']
        for w0, w1 in p['wire_pairs']:
            bwd[(t1, w1)].append((dx, dy, t0, w0))
    pipr = {}
    for p in pips:
        pipr.setdefault((p['tile'], p['fam']), []).append((p['tile'], p['src']))

    def origins_sorted(node):
        T, w = node
        t = name2pos[T][2]
        x, y, _ = name2pos[T]
        out = []
        for dx, dy, t0, w0 in bwd.get((t, w), []):
            T2 = pos2tile.get((x - dx, y - dy))
            if T2 and T2[1] == t0:
                out.append((abs(dx) + abs(dy), T2[0], w0))
        out.sort()
        return [(t2, w0) for _, t2, w0 in out]

    used = set()

    def walk(start, seen=None):
        if seen is None:
            seen = set()
        path = [start]
        cur = start
        while True:
            if cur in seen:
                return path, 'revisit'
            seen.add(cur)
            pr = pipr.get(cur)
            if pr:
                edge = (cur, pr[0])
                if edge in used:
                    return path, 'pip-reused'
                used.add(edge)
                cur = pr[0]
                path.append(cur)
                continue
            ogs = origins_sorted(cur)
            drs = [o for o in ogs if pipr.get(o)]
            if not drs:
                return path, 'root' if not ogs else 'undriven'
            for o in drs:
                sub, st = walk(o, set(seen))
                if st in ('root', 'undriven'):
                    path += sub
                    return path, st
            return path, 'deadend'

    csp = {'A1': 'SW2END3', 'A2': 'WW2END0', 'A3': 'WL1END0',
           'A4': 'SR1END1', 'A5': 'GFAN0', 'A6': 'WL1END1'}
    SINK = 'INT_L_X6Y11'
    res = {}
    for pin, w in csp.items():
        used = set()
        p, status = walk((SINK, w))
        res[pin] = [p, status]
        print(f'{pin}: {status}, {len(p)} nodes')
    json.dump(res, open(os.path.join(HERE, 's8_walk_in_v3.json'), 'w'))
    return 0


if __name__ == '__main__':
    sys.exit(main())
