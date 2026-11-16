import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

def diff(a, b):
    fa = frames_from_bit(a); fb = frames_from_bit(b)
    assert len(fa) == len(fb) == 50176, (len(fa), len(fb))
    out = []
    for fi in range(len(fa)):
        ra, rb = fa[fi], fb[fi]
        for w in range(len(ra)):
            x = ra[w] ^ rb[w]
            while x:
                bit = x.bit_length() - 1
                out.append((fi, w, bit))
                x ^= 1 << bit
    return sorted(out)

pairs = [
 ("aoutmux", "/opt/lzh/v7re/work/aoutmux/g_o5.bit", "/opt/lzh/v7re/work/aoutmux/g_o6.bit"),
 ("aoutmux2", "/opt/lzh/v7re/work/aoutmux2/s_a.bit", "/opt/lzh/v7re/work/aoutmux2/s_b.bit"),
 ("bufgmux", "/opt/lzh/v7re/work/bufgmux/s0sel.bit", "/opt/lzh/v7re/work/bufgmux/s1sel.bit"),
]
res = {}
for name, a, b in pairs:
    cells = diff(a, b)
    data = [c for c in cells if c[1] != 50]
    ecc = [c for c in cells if c[1] == 50]
    res[name] = {"n_all": len(cells), "n_data": len(data), "n_ecc": len(ecc), "cells": data[:80]}
    print("[%s] all=%d data=%d ecc=%d" % (name, len(cells), len(data), len(ecc)))
    for c in data[:14]:
        print("    frame=%d word=%d bit=%d" % c)
json.dump(res, open("/tmp/nonint_diff.json", "w"))
print("WROTE /tmp/nonint_diff.json")