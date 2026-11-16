import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
print("k  f2588 w24..w27            f2589 w24..w27")
for k in range(1, 12):
    f = frames_from_bit(D + ("y%d_s0.bit" % k))
    a = ["%08x" % f[2588][w] for w in (24, 25, 26, 27)]
    b = ["%08x" % f[2589][w] for w in (24, 25, 26, 27)]
    print("%2d %s  %s" % (k, " ".join(a), " ".join(b)))