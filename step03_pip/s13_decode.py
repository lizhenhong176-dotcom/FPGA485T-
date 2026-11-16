#!/usr/bin/env python3
"""s13_decode.py —— INT PIP 候选解码（修正 tile_block 规则）。

tile_block 规则（按优先级取第一个能匹配的候选）：
  1) CLB 邻列：INT_L 用 gx-1，INT_R 用 gx+1 的 CLB 块
  2) 西侧最近 CLB 块 + 36（28 帧夹缝块）
  3) 西侧最近 CLB 块 + 68
  4) 下一个 CLB 块 - 28

行字：wof(Y) = 2*(Y%50) + (1 if (Y%50)>=25 else 0)；cell 字 = wof(Y)+parity。
"""
import json, re, sqlite3, collections, os

HERE = os.path.dirname(os.path.abspath(__file__))
TG = r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'
LAW = r'E:\v7work\model\v7_law.sqlite'

tg = json.load(open(TG))
name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
db = sqlite3.connect(LAW)
clb = {(gc, b): base for gc, b, base in
       db.execute('select grid_col, band, base_frame from clb_blocks')}
cols = collections.defaultdict(list)
for (gc, b), base in clb.items():
    cols[b].append((gc, base))
for b in cols:
    cols[b].sort()

fr = {int(k): v for k, v in json.load(open(os.path.join(HERE, 's8_all_frames.json'))).items()}
cells = json.load(open(os.path.join(HERE, 'all_cells.json')))
groups = collections.defaultdict(list)
for c in cells:
    groups[(c['tile_type'], c['family'], c['src_wire'])].append(c)


def wof(Y):
    y = Y % 50
    return 2 * y + (1 if y >= 25 else 0)


def candidates(gx, band, ttype):
    out = []
    nb = clb.get((gx - 1 if ttype == 'INT_L' else gx + 1, band))
    if nb:
        out.append(nb)
    west = [base for gc, base in cols.get(band, []) if gc < gx]
    nxt = [base for gc, base in cols.get(band, []) if gc > gx]
    if west:
        out += [west[-1] + 36, west[-1] + 68]
    if nxt:
        out.append(nxt[0] - 28)
    seen, res = set(), []
    for b in out:
        if b not in seen:
            seen.add(b)
            res.append(b)
    return res


def match(base, w0, ttype):
    hits = []
    for (tt, fam, src), cs in groups.items():
        if tt != ttype:
            continue
        ok = True
        for c in cs:
            f = base + c['frame_off']
            if f not in fr or ((fr[f][w0 + c['parity']] >> c['bit']) & 1) != c['sense']:
                ok = False
                break
        if ok:
            hits.append((fam, src))
    return hits


def main():
    pips = []
    for n, (gx, gy, ttype) in name2pos.items():
        if ttype not in ('INT_L', 'INT_R'):
            continue
        m = re.search(r'_X(\d+)Y(\d+)$', n)
        if not m:
            continue
        Y = int(m.group(2))
        band = Y // 50
        w0 = wof(Y)
        for base in candidates(gx, band, ttype):
            hits = match(base, w0, ttype)
            if hits:
                for fam, src in hits:
                    pips.append({'tile': n, 'type': ttype, 'fam': fam, 'src': src,
                                 'base': base, 'w0': w0})
                break
    keys = collections.defaultdict(list)
    for p in pips:
        keys[(p['tile'], p['fam'])].append(p['src'])
    amb = {k: v for k, v in keys.items() if len(set(v)) > 1}
    json.dump(pips, open(os.path.join(HERE, 's13_pips.json'), 'w'), indent=0)
    print('pips:', len(pips), 'families:', len(keys), 'ambiguous:', len(amb))
    for k, v in list(amb.items())[:5]:
        print('  AMB', k, v)


if __name__ == '__main__':
    main()
