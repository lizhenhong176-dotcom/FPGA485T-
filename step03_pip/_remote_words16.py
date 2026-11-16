import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
print("k  f2587 w24..w27 | f2588 w24..w27 | f2589 w24..w27")
for k in range(1, 17):
    try:
        f = frames_from_bit(D + ("y%d_s0.bit" % k))
    except Exception as e:
        print(k, "MISSING"); continue
    cols = []
    for fr in (2587, 2588, 2589):
        ws = [f[fr][w] for w in (24, 25, 26, 27)]
        nz = ["w%d=%08x" % (24 + i, v) for i, v in enumerate(ws) if v]
        cols.append(",".join(nz) if nz else "-")
    print("%2d  %s | %s | %s" % (k, cols[0], cols[1], cols[2]))