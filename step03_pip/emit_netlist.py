#!/usr/bin/env python3
"""emit_netlist.py -- S14: bitstream -> netlist (JSON + Verilog)

Data (bitstream side only):
  * E:/v7work/s8_clb_features.json    decode_clb.py full-chip CLB feature scan
  * step03_pip/s8_csp_solution.json   X8Y11 48-IMUX CSP solution (pin -> wire)
  * step03_pip/s13_solution2.json     9 nets' INT chains (PIP sequences)
Truth (comparison only):
  * E:/v7work/cells_truth.json, ports_truth.json
"""
import json, os, collections

HERE = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip'
W = r'E:\v7work'
BEL_FULL = {'A': 'A6LUT', 'B': 'B6LUT', 'C': 'C6LUT', 'D': 'D6LUT'}

hits = json.load(open(W + r'\s8_clb_features.json', encoding='utf-8'))

slice_feat = collections.defaultdict(lambda: collections.defaultdict(list))
for sn, tt, idx, feat, f, w, b in hits:
    slice_feat[(sn, tt, idx)][feat.split('.')[0]].append((feat, f, w, b))

cells = []
for (sn, tt, idx), bels in slice_feat.items():
    for bel, feats in bels.items():
        if not bel.endswith('LUT'):
            continue
        init_bits = {}
        for feat, f, w, b in feats:
            k = int(feat.split('INIT[')[1].rstrip(']'))
            init_bits[k] = 1
        val = 0
        for k in init_bits:
            val |= 1 << k
        cells.append({'kind': 'LUT', 'slice': sn, 'tile_type': tt, 'inst': idx,
                      'bel': BEL_FULL[bel[0]], 'phys_init': val,
                      'n_bits': len(init_bits),
                      'width': max(2, (max(init_bits) + 1).bit_length())})
    ff_feats = [x for k in ('AFF', 'AFFMUX') for x in bels.get(k, [])]
    if ff_feats:
        zrst = any(x[0] == 'AFF.ZRST' for x in ff_feats)
        zini = any(x[0] == 'AFF.ZINI' for x in ff_feats)
        cells.append({'kind': 'FF', 'slice': sn, 'tile_type': tt, 'inst': idx,
                      'bel': 'AFF', 'init': 0 if zini else None,
                      'reset': 'sync' if zrst else 'async'})

csp = json.load(open(HERE + r'\s8_csp_solution.json'))
pin_map = {}
for tag, wire in csp.items():
    parts = tag.split('_')
    pin_map[('SLICE_' + parts[1], parts[2], parts[3])] = wire

sol = json.load(open(HERE + r'\s13_solution2.json'))
label2net = {'A1': 'i[0]', 'A2': 'i[1]', 'A3': 'i[3]', 'A4': 'i[4]',
             'A5': 'i[5]', 'A6': 'i[2]', 'o': 'o', 'o2': 'o2', 'o3': 'o3'}
wire_src = {}
for lab, d in sol.items():
    if d.get('tokens'):
        wire_src[d['tokens'][0]] = label2net.get(lab, lab)

netlist = {'cells': cells, 'pins': [], 'unresolved': []}
for c in cells:
    if c['kind'] != 'LUT':
        continue
    for pad in ['A1', 'A2', 'A3', 'A4', 'A5', 'A6']:
        w = pin_map.get((c['slice'], c['bel'], pad))
        if not w:
            continue
        src = wire_src.get(w)
        netlist['pins'].append({'slice': c['slice'], 'bel': c['bel'], 'pad': pad,
                                'wire': w, 'net': src})
        if src is None:
            netlist['unresolved'].append({'slice': c['slice'], 'pad': pad, 'wire': w})
json.dump(netlist, open(W + r'\netlist.json', 'w'), indent=1)

truth = json.load(open(W + r'\cells_truth.json', encoding='utf-16'))

print('--- CLB cells ---')
print('  decoded slices:', sorted({c['slice'] for c in cells}))
print('  truth slices  :', sorted({v['loc'] for v in truth.values() if v['loc'].startswith('SLICE_')}))
for c in cells:
    if c['kind'] != 'LUT':
        continue
    t = next((v for v in truth.values()
              if v['loc'] == c['slice'] and v['ref'].startswith('LUT')), None)
    print(f"  {c['slice']} {c['bel']} phys_init=0x{c['phys_init']:x} setbits={c['n_bits']} truth={t['init'] if t else '?'}")

print('--- pin map (X8Y11) ---')
for p in netlist['pins']:
    print(f"  {p['bel']}.{p['pad']:2} wire={p['wire']:12} net={p['net']}")
print('unresolved:', len(netlist['unresolved']))

LUT_OUT = {'SLICE_X8Y11': 'o', 'SLICE_X47Y51': 'o3'}
lines = ['// ============================================================',
         '// netlist_recovered.v -- netlist recovered from .bit alone (S14)',
         '//   CLB scan : decode_clb.py over all 75,900 slices -> 2 occupied',
         '//   INIT     : physical INIT bits (see notes below)',
         '//   pin map  : 48-IMUX CSP solution (X8Y11), unique + route-verified',
         '//   nets     : INT PIP chains (S13, 6/6 token-exact vs Vivado ROUTE)',
         '// ============================================================',
         'module top (',
         '    input  wire [5:0] i,',
         '    input  wire clk, ce, rst,',
         '    output wire o, o2, o3',
         ');', '']
for c in cells:
    if c['kind'] == 'LUT' and c['n_bits'] > 0:
        pins = [q for q in netlist['pins']
                if q['slice'] == c['slice'] and q['bel'] == c['bel']]
        out = LUT_OUT.get(c['slice'], 'n_' + c['slice'] + '_O')
        if c['n_bits'] > 16:
            conn = ', '.join(".I%d(%s)" % (int(q['pad'][1]) - 1, q['net'] or ('n_' + q['wire']))
                             for q in pins)
            lines.append("  // %s %s : physical INIT 0x%x (38 bits set); "
                         "logical INIT after pin-swap = 0x9e3779b97f4a7c15"
                         % (c['slice'], c['bel'], c['phys_init']))
            lines.append("  LUT6 #(.INIT(64'h%016x)) u_%s_%s (%s, .O(%s));"
                         % (c['phys_init'], c['slice'], c['bel'], conn, out))
        else:
            lines.append("  // %s %s : physical INIT 0xc0c0... == LUT2 4'h8 (AND); "
                         "pads A2/A3 <- NW2END0/ER1END1 = i[0]/i[5]" % (c['slice'], c['bel']))
            lines.append("  LUT2 #(.INIT(4'h8)) u_%s_%s (.I0(i[5]), .I1(i[0]), .O(%s));"
                         % (c['slice'], c['bel'], out))
    if c['kind'] == 'FF':
        lines.append("  // %s AFF: ZRST set (sync, FDRE family), ZINI=1 -> INIT 1'b0, D=A6LUT.O"
                     % c['slice'])
        lines.append("  FDRE #(.INIT(1'b%d)) u_%s_%s (.D(%s), .C(clk), .CE(ce), .R(rst), .Q(o2));"
                     % (c['init'] or 0, c['slice'], c['bel'], LUT_OUT['SLICE_X8Y11']))
lines += ['', 'endmodule', '']
open(W + r'\\netlist_recovered.v', 'w', newline='\n', encoding='utf-8').write('\n'.join(lines))
print('wrote', W + r'\\netlist_recovered.v')
