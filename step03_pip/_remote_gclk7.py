import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
fa = frames_from_bit(D + "y1_s0.bit")
for k in range(2, 8):
    fb = frames_from_bit(D + ("y%d_s0.bit" % k))
    cells = []
    for fi in range(len(fa)):
        ra, rb = fa[fi], fb[fi]
        for w in range(len(ra)):
            x = ra[w] ^ rb[w]
            while x:
                b = x.bit_length() - 1
                cells.append((fi, w, b, (ra[w] >> b) & 1, (rb[w] >> b) & 1))
                x ^= 1 << b
    data = [c for c in cells if c[1] != 50]
    on1 = [c for c in data if c[3] == 1]
    on2 = [c for c in data if c[4] == 1]
    words = sorted(set([c[1] for c in data]))
    print("y1->y%d data=%d words=%s" % (k, len(data), words))
    print("   y1 中为1:", [(c[0], c[1], c[2]) for c in on1])
    print("   y%d 中为1:" % k, [(c[0], c[1], c[2]) for c in on2])