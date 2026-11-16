#!/bin/bash
export LANG=C LC_ALL=C
python3 - <<'PY'
import json, struct

SYNC = b'\xaa\x99\x55\x66'
NW = 5067776          # expected FDRI words
FW = 101 * 32         # bits per frame

def payload(path):
    data = open(path, 'rb').read()
    i = data.find(SYNC)
    if i < 0:
        raise SystemExit('no sync: ' + path)
    # 找 Type2 包（高 3 位 = 010），字数 == NW
    j = i + 8
    n = len(data)
    while j + 4 <= n:
        (w,) = struct.unpack_from('>I', data, j)
        if (w >> 29) == 2 and (w & 0x07FFFFFF) == NW:
            start = j + 4
            return data[start:start + NW * 4]
        j += 4
    raise SystemExit('no FDRI Type2: ' + path)

def bits_of(x_bytes):
    """返回置位 bit 的全局序号列表（MSB-first within byte）。"""
    out = []
    for idx, by in enumerate(x_bytes):
        if by:
            for k in range(8):
                if by & (0x80 >> k):
                    out.append(idx * 8 + k)
    return out

DIRS = {
    'hclk5': ('/opt/lzh/v7re/work/hclk5/out', ['k0','k1','k2','k3','k4','k5','k6'], 'k0'),
    'hclk6': ('/opt/lzh/v7re/work/hclk6/out', ['c_a','c_b','p0','p1','p2','p3','p4','p5'], 'c_a'),
    'hclk4': ('/opt/lzh/v7re/work/hclk4/out', ['g0','g1','g2'], 'g0'),
}

out = {}
for exp, (d, names, base_name) in DIRS.items():
    pb = payload(f'{d}/{base_name}.bit')
    rec = {'base': base_name, 'samples': {}}
    for nm in names:
        if nm == base_name:
            continue
        ps = payload(f'{d}/{nm}.bit')
        a = int.from_bytes(pb, 'big'); b = int.from_bytes(ps, 'big')
        x = a ^ b
        xb = x.to_bytes(len(pb), 'big')
        nbits = len(pb) * 8
        cells = []
        for pos in bits_of(xb):
            f, rem = divmod(pos, FW)
            w, bit = divmod(rem, 32)
            sh = nbits - 1 - pos
            vb = (a >> sh) & 1
            vs = (b >> sh) & 1
            cells.append([f, w, bit, vb, vs])
        rec['samples'][nm] = {'n_cells': len(cells),
                              'frames': sorted({c[0] for c in cells}),
                              'cells': cells}
        print(exp, nm, 'cells:', len(cells), 'frames:', sorted({c[0] for c in cells})[:10])
    out[exp] = rec

json.dump(out, open('/opt/lzh/v7re/work/hclk_diff_20261109.json', 'w'), indent=1)
print('WROTE /opt/lzh/v7re/work/hclk_diff_20261109.json')
PY
