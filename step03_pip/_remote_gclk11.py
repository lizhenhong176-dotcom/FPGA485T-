import sys
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

D = "/opt/lzh/v7re/work/clkmux3/out/"
fa = frames_from_bit(D + "y1_s0.bit")

def cells_of(fb):
    out = []
    for fi in range(len(fa)):
        ra, rb = fa[fi], fb[fi]
        for w in range(len(ra)):
            x = ra[w] ^ rb[w]
            while x:
                b = x.bit_length() - 1
                out.append((fi, w, b, (ra[w] >> b) & 1, (rb[w] >> b) & 1))
                x ^= 1 << b
    return out

print("k  frame  word  bitpattern(set in k only)")
for k in range(2, 12):
    try:
        fb = frames_from_bit(D + ("y%d_s0.bit" % k))
    except Exception as e:
        print(k, "MISSING", e); continue
    cs = [c for c in cells_of(fb) if c[1] != 50]
    kset = [c for c in cs if c[4] == 1]
    # 只看帧 2589 的时钟字区（word 20..40, 69..89）
    clk = [c for c in kset if c[0] == 2589 and (20 <= c[1] <= 40 or 69 <= c[1] <= 89)]
    byw = {}
    for f, w, b, *_ in clk:
        byw.setdefault(w, []).append(b)
    print(k, "2589", {w: sorted(v) for w, v in sorted(byw.items())})
print("PRED: word = 24 + k//2 ; k odd -> high {17,19,31}, k even -> low {1,3,15}")