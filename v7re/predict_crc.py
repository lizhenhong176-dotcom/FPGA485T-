"""Predict the CRC of a bitstream and compare with what the file says.

Uses the recovered model:
    st = 0; for w in words[a..b]: st = L(st ^ w);  crc = st ^ S
with S = 0x06F99760 for range 1 (device constant for 7vx485t), verified on
every _crcb bitstream.
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

S = 0x06F99760

def check(path):
    W = load(path)
    c = parse(W)
    if not c:
        return "no CRC packet"
    idx, val = c[0]
    st = 0
    for i in range(12, idx):
        st = L(st ^ W[i])
    pred = st ^ S
    return "%s crc=0x%08X pred=0x%08X" % ("OK  " if pred == val else "FAIL", val, pred)

def main():
    pats = sys.argv[1:] or [r"E:/DEEPSEEK/FPGA比特流逆向/**/*.bit"]
    seen = set()
    files = []
    for p in pats:
        for f in sorted(glob.glob(p, recursive=True)):
            if f not in seen and os.path.getsize(f) > 1000000:
                seen.add(f)
                files.append(f)
    print("%d candidate bitstreams" % len(files))
    for f in files[: int(os.environ.get("N", "12"))]:
        print("  %-52s %s" % (os.path.relpath(f, r"E:/DEEPSEEK/FPGA比特流逆向")[-52:], check(f)))
        sys.stdout.flush()

if __name__ == "__main__":
    main()
