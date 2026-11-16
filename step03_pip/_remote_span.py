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
                out.append([fi, w, bit, (ra[w] >> bit) & 1, (rb[w] >> bit) & 1])
                x ^= 1 << bit
    return out

D = "/opt/lzh/v7re/work/clkmux/out/"
pairs = [("g8_vs_g16", D+"g8_s0.bit", D+"g16_s0.bit"),
         ("g8_vs_g24", D+"g8_s0.bit", D+"g24_s0.bit"),
         ("g16_vs_g24", D+"g16_s0.bit", D+"g24_s0.bit")]
res = {}
for name, a, b in pairs:
    cells = [c for c in diff(a, b) if c[1] != 50]
    res[name] = cells
    print("%s: data=%d" % (name, len(cells)))
    for c in cells[:10]:
        print("   frame=%d word=%d bit=%d %d->%d" % tuple(c))
json.dump(res, open("/tmp/clkmux_span.json","w"))
print("WROTE")