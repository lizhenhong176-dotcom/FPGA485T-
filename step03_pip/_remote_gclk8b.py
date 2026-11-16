import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
fa = frames_from_bit(D + "y1_s0.bit")
for k in (8, 9):
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
    from collections import Counter
    frames = Counter(c[0] for c in data)
    print("y%d: data=%d frames(top6)=%s" % (k, len(data), frames.most_common(6)))
    on = [c for c in data if c[4] == 1]
    print("   set-in-k cells:", len(on))
    for c in on[:15]:
        print("     frame=%d word=%d bit=%d" % c[:3])