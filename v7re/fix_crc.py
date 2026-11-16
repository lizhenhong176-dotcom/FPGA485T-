"""Repair the CRC packet of a bitstream after manual frame edits.

Both CRC packets are recomputed with the recovered model:
    range1: words[12 .. crc1_index-1]        S = 0x06F99760
    range2: words[crc1_index+2 .. crc2_index-1]  S derived from a reference file
and written back in place.  The second packet's constant depends on the device
and on FAR/CTL state, so it is taken from a known-good file of the same design
family (its S2), not hard-coded.
"""
import json, os, shutil, sys

LIB = json.load(open(r"E:/DEEPSEEK/FPGA比特流逆向/step03_pip/crc_matrix.json"))
COLS = [int(x, 16) for x in LIB["matrix"][:32]]
T = []
for b in range(4):
    tb = [0] * 256
    for v in range(256):
        acc = 0
        for i in range(8):
            if (v >> i) & 1:
                acc ^= COLS[b * 8 + i]
        tb[v] = acc
    T.append(tb)
T0, T1, T2, T3 = T

def L(x):
    return T0[x & 0xFF] ^ T1[(x >> 8) & 0xFF] ^ T2[(x >> 16) & 0xFF] ^ T3[(x >> 24) & 0xFF]

def load(path):
    d = open(path, "rb").read()
    Lh = int.from_bytes(d[98:102], "big")
    bs = d[102:102 + Lh]
    return d, [int.from_bytes(bs[i:i + 4], "big") for i in range(0, len(bs) - 3, 4)]

def parse(W):
    crcs, i, n = [], 0, len(W)
    while i < n:
        h = W[i]
        t = h >> 29
        if t == 1:
            op, reg, cnt = (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
            if op == 2 and reg == 0 and cnt == 1 and i + 1 < n:
                crcs.append((i, W[i + 1]))
            i += 1 + (cnt if op == 2 else 0)
        elif t == 2:
            i += 1 + (h & 0x7FFFFFF)
        else:
            i += 1
    return crcs

def run(W, a, b):
    st = 0
    for i in range(a, b + 1):
        st = L(st ^ W[i])
    return st

def offsets(W):
    """word index -> byte offset inside payload"""
    return lambda i: i * 4

def recalc(src, ref, dst):
    d, W = load(src)
    _, R = load(ref)
    rc = parse(R)
    S2 = run(R, rc[0][0] + 2, rc[1][0] - 1) ^ rc[1][1]
    S1 = 0x06F99760

    c = parse(W)
    if len(c) < 2:
        print("need two CRC packets, found %d" % len(c))
        return False
    i1, _ = c[0]
    i2, _ = c[1]
    v1 = run(W, 12, i1 - 1) ^ S1
    v2 = run(W, i1 + 2, i2 - 1) ^ S2

    out = bytearray(d)
    base = 102
    out[base + (i1 + 1) * 4: base + (i1 + 1) * 4 + 4] = v1.to_bytes(4, "big")
    out[base + (i2 + 1) * 4: base + (i2 + 1) * 4 + 4] = v2.to_bytes(4, "big")
    shutil.copyfile(src, dst)
    with open(dst, "r+b") as f:
        f.seek(base + (i1 + 1) * 4)
        f.write(v1.to_bytes(4, "big"))
        f.seek(base + (i2 + 1) * 4)
        f.write(v2.to_bytes(4, "big"))
    print("wrote %s\n  crc1 w%d: 0x%08X -> 0x%08X\n  crc2 w%d: 0x%08X -> 0x%08X"
          % (os.path.basename(dst), i1, c[0][1], v1, i2, c[1][1], v2))
    return True

if __name__ == "__main__":
    src, ref, dst = sys.argv[1], sys.argv[2], sys.argv[3]
    recalc(src, ref, dst)
