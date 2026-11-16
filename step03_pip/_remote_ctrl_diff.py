import sys, json, difflib
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

def diff(a, b):
    fa = frames_from_bit(a); fb = frames_from_bit(b)
    out = []
    for fi in range(len(fa)):
        ra, rb = fa[fi], fb[fi]
        for w in range(len(ra)):
            x = ra[w] ^ rb[w]
            while x:
                bit = x.bit_length() - 1
                out.append([fi, w, bit])
                x ^= 1 << bit
    return out

pairs = [
 ("bufgmux", "/opt/lzh/v7re/work/bufgmux/out/s0sel.bit", "/opt/lzh/v7re/work/bufgmux/out/s1sel.bit"),
 ("clkmux3_y4", "/opt/lzh/v7re/work/clkmux3/out/y4_s0.bit", "/opt/lzh/v7re/work/clkmux3/out/y4_s1.bit"),
 ("clkmux3_y2", "/opt/lzh/v7re/work/clkmux3/out/y2_s0.bit", "/opt/lzh/v7re/work/clkmux3/out/y2_s1.bit"),
]
res = {}
for name, a, b in pairs:
    cells = diff(a, b)
    data = [c for c in cells if c[1] != 50]
    res[name] = {"all": len(cells), "data": len(data), "cells": data}
    print("[%s] all=%d data=%d ecc=%d" % (name, len(cells), len(data), len(cells)-len(data)))
    for c in data[:12]:
        print("    frame=%d word=%d bit=%d" % tuple(c))
json.dump(res, open("/tmp/ctrl_diff.json", "w"))
print("WROTE /tmp/ctrl_diff.json")
print("=== bufgmux .v diff ===")
for l in difflib.unified_diff(open("/opt/lzh/v7re/work/bufgmux/s0sel.v").read().splitlines(),
                              open("/opt/lzh/v7re/work/bufgmux/s1sel.v").read().splitlines(), lineterm=""):
    print(l)