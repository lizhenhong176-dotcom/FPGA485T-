#!/bin/bash
export LANG=C LC_ALL=C
python3 - <<'PY'
import json, struct

SYNC = b'\xaa\x99\x55\x66'
NW = 5067776
FW = 101 * 32

def payload(path):
    data = open(path, 'rb').read()
    i = data.find(SYNC)
    j = i + 8
    while j + 4 <= len(data):
        (w,) = struct.unpack_from('>I', data, j)
        if (w >> 29) == 2 and (w & 0x07FFFFFF) == NW:
            return data[j + 4: j + 4 + NW * 4]
        j += 4
    raise SystemExit('no FDRI: ' + path)

def word(payload_bytes, frame, word_i):
    """从载荷里取 (frame, word) 的 32 位值（MSB-first word 顺序）。"""
    off = (frame * 101 + word_i) * 4
    return struct.unpack_from('>I', payload_bytes, off)[0]

def diff_cells(pa, pb):
    a = int.from_bytes(pa, 'big'); b = int.from_bytes(pb, 'big')
    x = (a ^ b).to_bytes(len(pa), 'big')
    out = []
    for idx, by in enumerate(x):
        if by:
            for k in range(8):
                if by & (0x80 >> k):
                    pos = idx * 8 + k
                    f, rem = divmod(pos, FW)
                    w, bit = divmod(rem, 32)
                    sh = len(pa) * 8 - 1 - pos
                    out.append([f, w, bit, (a >> sh) & 1, (b >> sh) & 1])
    return out

res = {"words": {}, "pll_diff": {}}

# 1) HCLK_CMT 字段区的原始字值（band4: base 22118；band6: base 32610）
REGIONS = {
    "hclk5": ("/opt/lzh/v7re/work/hclk5/out", 22118, ['k0','k1','k2','k3','k4','k5','k6']),
    "hclk4": ("/opt/lzh/v7re/work/hclk4/out", 32610, ['g0','g1','g2']),
}
COORDS = [(26, w) for w in (50, 51)] + [(27, w) for w in (50, 51)] \
    + [(29, w) for w in (27, 28, 29, 30)]
for exp, (d, base, names) in REGIONS.items():
    res["words"][exp] = {}
    for nm in names:
        p = payload(f'{d}/{nm}.bit')
        res["words"][exp][nm] = {
            f"off{o}/w{w}": f"0x{word(p, base + o, w):08x}" for o, w in COORDS
        }
        print(exp, nm, res["words"][exp][nm])

# 2) PLL 受控差分（p_i vs p0）
d = '/opt/lzh/v7re/work/hclk6/out'
p0 = payload(f'{d}/p0.bit')
for nm in ['p1','p2','p3','p4','p5']:
    px = payload(f'{d}/{nm}.bit')
    cells = [c for c in diff_cells(p0, px)]
    data = [c for c in cells if c[1] != 50]
    res["pll_diff"][nm] = {"n": len(cells), "n_data": len(data),
                           "frames": sorted({c[0] for c in cells}),
                           "cells": cells}
    print('pll', nm, 'cells', len(cells), 'data', len(data),
          'frames', sorted({c[0] for c in cells})[:8])

json.dump(res, open('/opt/lzh/v7re/work/hclk_regions_20261109.json', 'w'), indent=1)
print('WROTE hclk_regions_20261109.json')
PY
