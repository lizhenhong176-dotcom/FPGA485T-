"""Differential CRC probe, clean implementation.

Two bitstreams of the same base design differ only in a handful of FDRI data
words (plus the CRC packets themselves).  Every other word - including all the
masked constant feeds - is byte-identical and cancels out of the difference, so

    delta(CRC packet) = XOR_{changed w}  L^k( delta(w) ),  k = words fed after w

verifies the linear map, the bit order and the feed order simultaneously,
without needing the device mask strings at all.

We try both recovered matrices (Vivado librdi_bitstream.so and ISE
libBsFuji_Bitstream.so) x both word bit-orders x a range of trailing counts C.
"""
import glob, itertools, json, os

# ------------------------------------------------------------------ matrices
LIB = json.load(open(r"E:/DEEPSEEK/FPGA比特流逆向/step03_pip/crc_matrix.json"))
ISE = json.load(open(r"E:/v7work/vivado_re/crc32_37_matrix.json"))
MATS = {
    "librdi(32/32)": [int(x, 16) for x in LIB["matrix"][:32]],
    "ise_crc32_37":  [int(x, 16) for x in ISE["data_cols"]],
}

def apply_op(op, v):
    a = 0
    for i in range(32):
        if (v >> i) & 1:
            a ^= op[i]
    return a

def compose(f, g):
    return [apply_op(f, g[i]) for i in range(32)]

def pow_op(cols, k):
    r = [1 << i for i in range(32)]
    b = cols[:]
    while k:
        if k & 1:
            r = compose(b, r)
        b = compose(b, b)
        k >>= 1
    return r

# ------------------------------------------------------------------ bitstream
def load(path):
    d = open(path, "rb").read()
    Lh = int.from_bytes(d[98:102], "big")
    bs = d[102:102 + Lh]
    return [int.from_bytes(bs[i:i + 4], "big") for i in range(0, len(bs) - 3, 4)]

def packets(W):
    out, i, n = [], 0, len(W)
    while i < n:
        h = W[i]
        t = h >> 29
        if t == 1:
            op, reg, cnt = (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
            out.append(("t1", i, op, reg, cnt))
            i += 1 + (cnt if op == 2 else 0)
        elif t == 2:
            out.append(("t2", i, None, None, h & 0x7FFFFFF))
            i += 1 + (h & 0x7FFFFFF)
        else:
            out.append(("other", i, None, None, None))
            i += 1
    return out

def main():
    d = r"E:/DEEPSEEK/FPGA比特流逆向/_crcb"
    fs = sorted(glob.glob(os.path.join(d, "*.bit")))
    A = load(fs[0])
    pk = packets(A)
    fdri = next(p for p in pk if p[0] == "t2")
    hi, cnt = fdri[1], fdri[4]
    crc_pk = [(p[1], A[p[1] + 1]) for p in pk
              if p[0] == "t1" and p[2] == 2 and p[3] == 0 and p[4] == 1]
    print("base %s: FDRI w%d cnt=%d, CRC packets %s"
          % (os.path.basename(fs[0]), hi, cnt,
             [("w%d" % i, "0x%08X" % v) for i, v in crc_pk]))
    crcidx = set()
    for i, _ in crc_pk:
        crcidx |= {i, i + 1}

    pairs = []
    for f in fs[1:10]:
        B = load(f)
        cpb = [(p[1], B[p[1] + 1]) for p in packets(B)
               if p[0] == "t1" and p[2] == 2 and p[3] == 0 and p[4] == 1]
        if not cpb:
            continue
        diff = [i for i in range(len(A)) if A[i] != B[i]]
        bad = [i for i in diff if i not in crcidx and not (hi < i <= hi + cnt)]
        if bad:
            continue
        inside = [i for i in diff if hi < i <= hi + cnt]
        pairs.append((os.path.basename(f), inside, A, B, crc_pk[0][1] ^ cpb[0][1]))
    print("usable pairs:", [(p[0], len(p[1])) for p in pairs])

    for mname, cols0 in MATS.items():
        for order in ("char=k->bit k", "char=k->bit 31-k"):
            cols = cols0 if order.endswith("bit k") else \
                   [cols0[31 - b] for b in range(32)]
            for C in range(0, 96):
                ok = True
                for name, inside, a, b, act in pairs:
                    exp = 0
                    for i in inside:
                        k = (hi + cnt - i) + C
                        exp ^= apply_op(pow_op(cols, k), a[i] ^ b[i])
                    if exp != act:
                        ok = False
                        break
                if ok:
                    print("*** HIT  matrix=%-14s %s  C=%d" % (mname, order, C))

if __name__ == "__main__":
    main()
