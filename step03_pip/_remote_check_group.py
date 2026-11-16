import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
print("k    frame  word  value")
for k in (1, 8, 16, 17, 24, 31):
    f = frames_from_bit(D + ("y%d_s0.bit" % k))
    found = []
    for fr in (2586, 2587, 2588, 2589, 2590):
        for w in range(24, 28):
            v = f[fr][w]
            if v:
                found.append((fr, w, "%08x" % v))
    print("%2d  %s" % (k, found))