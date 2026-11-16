import sys, json
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
                ba = (ra[w] >> bit) & 1
                bb = (rb[w] >> bit) & 1
                out.append([fi, w, bit, ba, bb])
                x ^= 1 << bit
    return out

pairs = [("clkmux3_y%d" % y, "/opt/lzh/v7re/work/clkmux3/out/y%d_s0.bit" % y,
          "/opt/lzh/v7re/work/clkmux3/out/y%d_s1.bit" % y) for y in (2,4,5,6,7)]
pairs.append(("bufgmux", "/opt/lzh/v7re/work/bufgmux/out/s0sel.bit", "/opt/lzh/v7re/work/bufgmux/out/s1sel.bit"))
out = {}
for name, a, b in pairs:
    cells = [c for c in diff(a, b) if c[1] != 50]
    out[name] = cells
    print(name, cells)
json.dump(out, open("/tmp/ctrl_bits.json","w"))
print("WROTE")