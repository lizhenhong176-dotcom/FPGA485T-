"""Absolute CRC model test (table-driven, fast).

Differential probe already proved:  st' = L(st XOR w), and the last word fed
is one past the FDRI payload (C=1).  Everything else the algorithm consumes is
either a bitstream word (known) or a device constant.  Since the map is linear
with f(0)=0:

    CRC = model(words) XOR S

with S identical for every bitstream of the same device.  So compute
model XOR CRC_packet for a handful of files and see whether it is constant.
"""
import glob, json, os, sys

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
    return [int.from_bytes(bs[i:i + 4], "big") for i in range(0, len(bs) - 3, 4)]

def crc_packets(W):
    out, i, n = [], 0, len(W)
    while i < n:
        h = W[i]
        t = h >> 29
        if t == 1:
            op, reg, cnt = (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
            if op == 2 and reg == 0 and cnt == 1:
                out.append((i, W[i + 1]))
            i += 1 + (cnt if op == 2 else 0)
        elif t == 2:
            i += 1 + (h & 0x7FFFFFF)
        else:
            i += 1
    return out

def main():
    limit = int(sys.argv[1]) if len(sys.argv) > 1 else 4
    d = r"E:/DEEPSEEK/FPGA比特流逆向/_crcb"
    fs = sorted(glob.glob(os.path.join(d, "*.bit")))[:limit]
    for f in fs:
        W = load(f)
        cp = crc_packets(W)
        hi = next(i for i in range(len(W)) if W[i] >> 29 == 2)
        cnt = W[hi] & 0x7FFFFFF
        first = 12
        last = hi + cnt            # one past the FDRI payload
        st = 0
        for i in range(first, last + 1):
            st = L(st ^ W[i])
        print("%s  model=0x%08X  crc1=0x%08X  S1=0x%08X   crc2=0x%08X  S2=?%s"
              % (os.path.basename(f), st, cp[0][1], st ^ cp[0][1], cp[1][1], ""))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
