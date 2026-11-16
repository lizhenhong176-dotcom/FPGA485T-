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

D = "/opt/lzh/v7re/work/clkmux3/out/"
res = {}
for a, b in [(1,2),(2,3),(3,4),(4,5),(5,6),(6,7),(1,7)]:
    pa, pb = D + "y%d_s0.bit" % a, D + "y%d_s0.bit" % b
    cells = [c for c in diff(pa, pb) if c[1] != 50]
    res["y%d_vs_y%d" % (a,b)] = cells
    print("y%d vs y%d : data=%d %s" % (a, b, len(cells), cells[:8]))
json.dump(res, open("/tmp/rowcode.json","w"))
print("WROTE")