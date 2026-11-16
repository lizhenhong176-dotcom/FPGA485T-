"""bit -> netlist decoder v0: single slice (CLBLL_L_X6Y11 / SLICE_X8Y11).

Inputs : s8_col.json  (36-frame column dump, from remote)
         tilepipe.json (48 IMUX source bit-sets, anchor = same tile)
         segbits_clbll_l.db (artix7-derived INIT field layout)
         s8_truth.json (Vivado's own view, for closed-loop validation)
Output : decoded slice netlist (JSON) + PASS/FAIL report.
"""
import json, sys, re

D = r'E:\DEEPSEEK\FPGA比特流逆向\step03_pip'
B = 31680          # CLBLL_L_X6Y11 column base (grid_col 16, band 0)
W = 22             # row word = 2*(Y%50), Y=11

col = json.load(open(D + r'\s8_col.json'))
fr = {int(k): v for k, v in col['col'].items()}
obs = set()
for f, words in fr.items():
    for w, word in enumerate(words):
        if word:
            for b in range(32):
                if word >> b & 1:
                    obs.add((f, w, b))

def bitval(f, w, b):
    return (fr[f][w] >> b) & 1

# ---------- 1. LUT INIT decode (A6LUT, SLICEL_X0) ----------
init_layout = {}
for line in open(D + r'\segbits_clbll_l.db'):
    p = line.split()
    if len(p) >= 2 and 'SLICEL_X0.A6LUT.INIT' in p[0]:
        m = re.search(r'INIT\[(\d+)\]', p[0])
        if m:
            off, bt = p[1].split('_')
            init_layout.setdefault(int(m.group(1)), []).append((int(off), int(bt)))
FIELD = B + 32  # X0 LUT INIT field base (off 0-3 in db are field-relative)
init_bits = {}
for k, poss in init_layout.items():
    vals = {bitval(FIELD + off, W, b) for off, b in poss}
    assert len(vals) == 1, f'INIT[{k}] inconsistent {poss}'
    init_bits[k] = vals.pop()
init_val = 0
for k, v in init_bits.items():
    if v: init_val |= 1 << k

# ---------- 2. Pin map via IMUX matching (CSP joint solve) ----------
# NOTE: the naive first-match used here before was WRONG on ambiguous pins (A3/A4/A6).
# csp_imux.py solves all 48 muxes jointly (C1/C2 + MRV) -> unique solution,
# validated 6/6 against Vivado's ROUTE ground truth (route_I*.txt, S9).
import subprocess, os
if not os.path.exists(D + r'\s8_csp_solution.json'):
    subprocess.run([sys.executable, D + r'\csp_imux.py'], check=True)
sol = json.load(open(D + r'\s8_csp_solution.json'))
tj = json.load(open(D + r'\tilepipe.json'))
pin_map = {}
for tag, src in sol.items():
    parts = tag.split('_')
    if parts[1] == 'X8Y11' and parts[2] == 'A6LUT' and src != 'VCC_WIRE':
        pin_map[parts[3]] = {'mux': tj[tag]['sink'], 'source': src, 'ambiguous': False}

# ---------- 3. FF / mux decode (SLICEL_X0, CLBLL_L) ----------
ff = {
    'AFFMUX.O6': bitval(B + 30, W, 3),
    'ZRST':      bitval(B + 30, W, 12),
    'ZINI':      bitval(B + 31, W, 3),
}

# ---------- 4. report ----------
rep = {
    'slice': 'SLICE_X8Y11', 'tile': 'CLBLL_L_X6Y11', 'base': B, 'row_word': W,
    'lut': {'bel': 'SLICEL_X0.A6LUT', 'init_hex': hex(init_val),
            'init_popcount': bin(init_val).count('1'), 'n_layout_bits': len(init_bits)},
    'pin_map': pin_map,
    'ff': ff,
    'n_observed_bits_in_column': len(obs),
}
print(json.dumps(rep, indent=1))

# ---------- 5. closed-loop validation ----------
try:
    truth = json.load(open(D + r'\s8_truth.json'))
    print('\n=== ground truth (Vivado view) ===')
    print(json.dumps(truth, indent=1))
    t_init = int(truth['init'].split("'h")[1], 16)
    print('\nINIT match:', t_init == init_val, f'truth={hex(t_init)} decoded={hex(init_val)}')
    # pin-swap permutation recovery (unique solution expected)
    import itertools
    sols = []
    for P in itertools.permutations(range(6)):
        if all(((init_val >> int(''.join(format(L, '06b')[k] for k in P), 2)) & 1) == ((t_init >> L) & 1)
               for L in range(64)):
            sols.append(P)
    pins = ['A6', 'A5', 'A4', 'A3', 'A2', 'A1']
    if len(sols) == 1:
        P = sols[0]
        print('PIN-SWAP recovered (unique):',
              ', '.join(f'{pins[k]}<-I{P[k]}' for k in range(6)))
        print('CLOSED LOOP: bitstream -> physical INIT -> permutation -> ground-truth INIT OK')
    else:
        print('permutation solutions:', len(sols))
except FileNotFoundError:
    print('truth json not fetched yet')
