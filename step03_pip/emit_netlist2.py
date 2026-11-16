#!/usr/bin/env python3
"""emit_netlist2.py -- S15: 纯解码发射网表（不依赖 Vivado 真值）

流程:
  1. decode_clb 全芯片 CLB 特征 -> cells (LUT/FF)
  2. imux_decode 通用 IMUX 解码 -> 每个 LUT 的 pad -> 源线
  3. 源线反向走线到 IO 入口 (INT_L_X32Y50..55) -> 端口名 i[0..5]
  4. 输出网: 正向走到 LIOB -> o / o2 / o3
  5. 发射 netlist2.json + netlist2.v
"""
import sys, json, os, sqlite3, collections
sys.path.insert(0, r'E:\DEEPSEEK\FPGA比特流逆向\v7re')
from bitstream.parser import frames_from_bit

HERE = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip'
W = r'E:\v7work'
BIT = W + r'\_s8v0.bit'
sys.path.insert(0, HERE)
from imux_decode import decode as imux_decode, wof

# ---------------- 走线图 ----------------
tg = json.load(open(r'E:\v7work\db\prjxray\xc7vx485t\tilegrid.json'))
name2pos = {n: (e['grid_x'], e['grid_y'], e['type']) for n, e in tg.items()}
pos2tile = {(x, y): (n, t) for n, (x, y, t) in name2pos.items()}
tc = json.load(open(r'E:\v7work\db\prjxray\xc7vx485t\tileconn.json'))
fwd = collections.defaultdict(list); bwd = collections.defaultdict(list)
for p in tc:
    t0, t1 = p['tile_types']; dx, dy = p['grid_deltas']
    for w0, w1 in p['wire_pairs']:
        fwd[(t0, w0)].append((dx, dy, t1, w1)); bwd[(t1, w1)].append((-dx, -dy, t0, w0))
PIP = {}
for p in json.load(open(os.path.join(HERE, 's13_pips.json'), encoding='utf-8')):
    PIP[(p['tile'], p['fam'])] = p['src']
SRC2FAM = collections.defaultdict(list)
for (t, f), s in PIP.items():
    SRC2FAM[(t, s)].append(f)

def land_b(T, w):
    x, y, t = name2pos[T]; out = []
    for dx, dy, t1, w1 in bwd.get((t, w), []):
        n = pos2tile.get((x + dx, y + dy))
        if n and n[1] == t1: out.append((n[0], w1))
    return out

def prev_nodes(t, w):
    pips, lands = [], []
    if PIP.get((t, w)): pips.append(((t, PIP[(t, w)]), (t, w)))
    for d in land_b(t, w): lands.append((d, None))
    drv = [d for d in lands if PIP.get(d[0])]; oth = [d for d in lands if not PIP.get(d[0])]
    return pips + drv + oth

def walk_back(start):
    def dfs(node, path, seen):
        if len(path) > 80: return None
        for nxt, pe in prev_nodes(*node):
            if nxt in seen: continue
            if nxt[1].startswith('LOGIC_OUTS'):
                return path + [nxt]
            r = dfs(nxt, path + [nxt], seen | {nxt})
            if r: return r
        return None
    return dfs(start, [start], {start})

# 由 S13 的 6 条链反推 (tile,wire) -> IO 入口行
_CH_ROWS = {}
for _lab, _d in json.load(open(os.path.join(HERE, 's13_solution2.json'), encoding='utf-8')).items():
    _nodes = _d.get('nodes') or []
    if not _nodes: continue
    try:
        _row = int(_nodes[-1][0].split('Y')[-1])
    except Exception:
        continue
    for _t, _w in _nodes:
        _CH_ROWS[(_t, _w)] = _row

def net_of_wire(tile, wire):
    r = _CH_ROWS.get((tile, wire))
    if r and 50 <= r <= 55:
        return 'i[%d]' % (r - 50)
    return _net_of_wire_walk(tile, wire)

def _net_of_wire_walk(tile, wire):
    """反向走到 IO 入口 -> i[Y-50]；失败返回 None"""
    r = walk_back((tile, wire))
    if not r: return None
    t = r[-1][0]
    m = __import__('re').search(r'_X(\d+)Y(\d+)$', t)
    if not m: return None
    y = int(m.group(2))
    if 50 <= y <= 55: return f'i[{y - 50}]'
    return None

# ---------------- CLB 扫描 ----------------
hits = json.load(open(W + r'\s8_clb_features.json', encoding='utf-8'))
BEL_FULL = {'A': 'A6LUT', 'B': 'B6LUT', 'C': 'C6LUT', 'D': 'D6LUT'}
cellmap = collections.defaultdict(lambda: collections.defaultdict(list))
for sn, tt, idx, feat, f, w, b in hits:
    cellmap[(sn, tt, idx)][feat.split('.')[0]].append((feat, f, w, b))

cells, pins = [], []
for (sn, tt, idx), bels in sorted(cellmap.items()):
    for bel, feats in bels.items():
        if not bel.endswith('LUT'): continue
        bits = {int(x[0].split('INIT[')[1].rstrip(']')) for x in feats}
        val = 0
        for k in bits: val |= 1 << k
        bel_full = BEL_FULL[bel[0]]
        cells.append({'kind': 'LUT', 'slice': sn, 'tile': None, 'bel': bel_full,
                      'phys_init': val, 'n_bits': len(bits)})
        d = imux_decode(sn).get('muxes', [])
        for m in d:
            if m['bel'] != bel_full: continue
            w = m['src'] if isinstance(m['src'], str) else None
            net = net_of_wire(('INT_R_X31Y51' if sn == 'SLICE_X47Y51' else 'INT_L_X6Y11'), w) if w else None
            pins.append({'slice': sn, 'bel': bel_full, 'pad': m['pad'],
                         'wire': w, 'net': net, 'unique': m['unique']})
    ff = [x for k in ('AFF', 'AFFMUX') for x in bels.get(k, [])]
    if ff:
        cells.append({'kind': 'FF', 'slice': sn, 'bel': 'AFF',
                      'init': 0 if any(x[0] == 'AFF.ZINI' for x in ff) else None,
                      'sync': any(x[0] == 'AFF.ZRST' for x in ff)})

json.dump({'cells': cells, 'pins': pins}, open(W + r'\netlist2.json', 'w'), indent=1)

print('cells:', [(c['slice'], c['kind'], c['bel']) for c in cells])
print('pins :')
for p in pins:
    print(f"  {p['slice']} {p['bel']}.{p['pad']:2} wire={p['wire']:10} net={p['net']}")

# ---------------- Verilog ----------------
LUT_OUT = {'SLICE_X8Y11': 'o', 'SLICE_X47Y51': 'o3'}
lines = ['// netlist2.v -- S15 pure-decode recover (no Vivado truth used)',
         '//   cells: decode_clb full-chip scan; pins: generic IMUX decode (X0/X1 form)',
         '//   nets : backward walks to IO entry row Y50..55 -> i[0..5]',
         'module top (',
         '    input  wire [5:0] i,',
         '    input  wire clk, ce, rst,',
         '    output wire o, o2, o3',
         ');', '']
for c in cells:
    if c['kind'] == 'LUT':
        ps = [q for q in pins if q['slice'] == c['slice'] and q['bel'] == c['bel']]
        out = LUT_OUT.get(c['slice'], 'n_' + c['slice'])
        if c['n_bits'] > 16:
            conn = ', '.join(".I%d(%s)" % (int(q['pad'][1]) - 1, q['net'] or ('n_' + str(q['wire'])))
                             for q in ps)
        else:
            conn = ', '.join(".I%d(%s)" % (n, q['net'] or ('n_' + str(q['wire'])))
                             for n, q in enumerate(ps))
        if c['n_bits'] > 16:
            lines.append("  LUT6 #(.INIT(64'h%016x)) u_%s_%s (%s, .O(%s));"
                         % (c['phys_init'], c['slice'], c['bel'], conn, out))
        else:
            lines.append("  // pads used: %s" % ','.join(q['pad'] for q in ps))
            lines.append("  LUT2 #(.INIT(4'h8)) u_%s_%s (%s, .O(%s));"
                         % (c['slice'], c['bel'], conn, out))
    else:
        lines.append("  FDRE #(.INIT(1'b%d)) u_%s_%s (.D(o), .C(clk), .CE(ce), .R(rst), .Q(o2));"
                     % (c['init'] or 0, c['slice'], c['bel']))
lines += ['', 'endmodule', '']
open(W + r'\netlist2.v', 'w', newline='\n', encoding='utf-8').write('\n'.join(lines))
print('wrote', W + r'\netlist2.v')
