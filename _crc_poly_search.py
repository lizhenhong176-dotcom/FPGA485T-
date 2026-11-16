
import numpy as np, sys
d = open("_full8_i3.bit","rb").read()
s = d.find(b"\xAA\x99\x55\x66"); base = s+4
N = 5067822
w = np.frombuffer(d[base:base+4*N], dtype=">u4")
target = 0xb3b04c17
REV = np.array([int("{:08b}".format(i)[::-1],2) for i in range(256)], dtype=np.uint8)

def wbr(a):
    b = a.astype(">u4").view(np.uint8).reshape(-1,4)[:, ::-1].copy()
    return REV[b].tobytes()

def table(poly):
    t=[]
    for i in range(256):
        c=i<<24
        for _ in range(8): c = ((c<<1)^poly)&0xFFFFFFFF if c&0x80000000 else (c<<1)&0xFFFFFFFF
        t.append(c)
    return t

ranges = {"payload": (12, N), "all": (0, N)}
polys = [0x04C11DB7, 0x1EDC6F41, 0x000000AF, 0x814141AB, 0x741B8CD7]
best = []
for rname,(lo,hi) in ranges.items():
    sub = w[lo:hi]
    bufs = {"be": sub.astype(">u4").tobytes(), "wbr": wbr(sub)}
    for pname, poly in zip(["CR32","CR32C","XFER","AIXM","CASTAG"], polys):
        T = table(poly)
        for bname, data in bufs.items():
            for init in (0xFFFFFFFF, 0):
                c = init
                for byte in data:
                    c = ((c << 8) & 0xFFFFFFFF) ^ T[((c >> 24) ^ byte) & 0xFF]
                for xo in (0, 0xFFFFFFFF):
                    got = c ^ xo
                    dist = bin(got ^ target).count("1")
                    best.append((dist, rname, pname, bname, hex(init), hex(xo), hex(got)))
                    if dist == 0: print("HIT", best[-1], flush=True)
best.sort()
print("最接近 5 个:")
for b in best[:5]: print("  ", b)
