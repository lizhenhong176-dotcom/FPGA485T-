#!/usr/bin/env python3
"""S7 cross-tile prediction test: generate predictions + designs + scripts."""
import json, sqlite3, re, collections, os

D = os.path.dirname(os.path.abspath(__file__))
REF = r'E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7'

# ---- targets: tag, slice, tile_type, site_inst, base B, row word w
law = sqlite3.connect(r'E:\v7work\model\v7_law.sqlite')
def target(tag, slice_name):
    tt, gc, inst, y = law.execute("select tile_type, grid_col, inst, y from clb_tiles where slice_name=?", (slice_name,)).fetchone()
    B = law.execute("select base_frame from clb_blocks where grid_col=? and band=?", (gc, y // 50)).fetchone()[0]
    w = 2 * (y % 50)
    site_inst = 'SLICEL_X1' if inst == 1 else ('SLICEM_X0' if tt.startswith('CLBLM') else 'SLICEL_X0')
    return dict(tag=tag, slice=slice_name, tile_type=tt, site_inst=site_inst, B=B, w=w, y=y)

T = [target('A', 'SLICE_X3Y10'), target('B', 'SLICE_X5Y10'),
     target('C', 'SLICE_X0Y10'), target('D', 'SLICE_X10Y300')]

# ---- artix7 segbits loader
def load(fname):
    rows = collections.defaultdict(list)
    for line in open(os.path.join(REF, fname)):
        line = line.strip()
        if not line or line.startswith('#'):
            continue
        p = line.split()
        key = '.'.join(p[0].split('.')[1:])   # strip tile prefix
        for b in p[1:]:
            sense = 0 if b.startswith('!') else 1
            bb = b.lstrip('!')
            off, bit = bb.split('_')
            rows[key].append((int(off), int(bit) + 32 * 0, sense))
    return rows

AF = {'CLBLM_L': load('segbits_clblm_l.db'), 'CLBLM_R': load('segbits_clblm_r.db'),
      'CLBLL_L': load('segbits_clbll_l.db'), 'CLBLL_R': load('segbits_clbll_r.db')}

preds = {}
for t in T:
    fam = f"{t['site_inst']}.ALUT.INIT"
    init = AF[t['tile_type']].get(fam, [])
    init_bits = []
    VAL = 0x9E3779B97F4A7C15
    for i in range(64):
        if VAL >> i & 1:
            k = f"{t['site_inst']}.ALUT.INIT[{i:02d}]"
            rows = AF[t['tile_type']][k]
            for off, bit, s in rows:
                if s:
                    init_bits.append((t['B'] + off, t['w'], bit))
    mux = AF[t['tile_type']].get(f"{t['site_inst']}.AFFMUX.O6", [])
    affmux = [(t['B'] + off, t['w'], bit) for off, bit, s in mux if s]
    zrst = [(t['B'] + off, t['w'], bit) for off, bit, s in AF[t['tile_type']][f"{t['site_inst']}.AFF.ZRST"] if s]
    zini = [(t['B'] + off, t['w'], bit) for off, bit, s in AF[t['tile_type']][f"{t['site_inst']}.AFF.ZINI"] if s]
    preds[t['tag']] = dict(target=t, init_5555=sorted(init_bits),
                           affmux_o6=sorted(affmux), zrst=sorted(zrst), zini=sorted(zini),
                           aoutmux_o6=[])
json.dump(preds, open(os.path.join(D, 's7b_predictions.json'), 'w'), indent=1)
for k, v in preds.items():
    t = v['target']
    print(k, t['slice'], t['tile_type'], t['site_inst'], 'B=%d w=%d' % (t['B'], t['w']),
          'init:%d bits' % len(v['init_5555']), 'affmux', v['affmux_o6'], 'zrst', v['zrst'], 'zini', v['zini'])

# ---- designs
V = """module top(input clk, input [6:0] i, output o{OUT2});
  wire lo6;
  (* DONT_TOUCH = "yes" *) LUT6 #(.INIT(64'h9E3779B97F4A7C15)) u_la
    (.I0(i[0]), .I1(i[1]), .I2(i[2]), .I3(i[3]), .I4(i[4]), .I5(i[5]), .O(lo6));
{FF}
  assign o = lo6;
endmodule
"""
FF = """  (* DONT_TOUCH = "yes" *) FDRE #(.INIT(1'b0)) u_ff
    (.C(clk), .D(lo6), .CE(1'b1), .R(1'b0), .Q(o2));
"""
XDC = """set_property LOC {SLICE} [get_cells -hierarchical u_la]
set_property BEL A6LUT [get_cells -hierarchical u_la]
{FFX}
"""
FFX = """set_property LOC {SLICE} [get_cells -hierarchical u_ff]
set_property BEL AFF [get_cells -hierarchical u_ff]
"""
for t in T:
    for d, hasff in (('d1', False), ('d2', True)):
        name = f"s7b_{t['tag']}_{d}"
        open(os.path.join(D, name + '.v'), 'w').write(
            V.format(OUT2=', output o2' if hasff else '', FF=FF if hasff else ''))
        open(os.path.join(D, name + '.xdc'), 'w').write(
            XDC.format(SLICE=t['slice'], FFX=FFX.format(SLICE=t['slice']) if hasff else ''))
print('designs written')


