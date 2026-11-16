import os, struct
D = "/opt/lzh/step03/lutmap"
B = 31748
base = open(os.path.join(D, "v_0000000000000000.bit"), "rb").read()
# payload span for base file
ps, pe = 338, 20271442
pay0 = base[ps:pe]

def pos(k):
    df = 2 * (1 - ((k >> 3) & 1)) + (k & 1)
    bit = 15 - 4 * (k >> 4) - ((k >> 1) & 3)
    return B + df, bit

def load(k):
    f = os.path.join(D, "v_%016x.bit" % (1 << k))
    return open(f, "rb").read()

for k in (0, 1, 2, 3, 5, 7, 16, 63):
    buf = load(k)
    pay = buf[ps:pe]
    diffs = []
    for i in range(0, len(pay), 4):
        if pay[i:i+4] != pay0[i:i+4]:
            fi, off = divmod(i, 404)
            w = off // 4
            b = (off % 4) * 8
            x = int.from_bytes(pay[i:i+4], "big") ^ int.from_bytes(pay0[i:i+4], "big")
            while x:
                lb = x & -x
                diffs.append((fi, w, b + lb.bit_length() - 1))
                x ^= lb
    fr, bit = pos(k)
    hits = [d for d in diffs if d[0] == fr and d[1] == 20 and d[2] == bit]
    ecc = [d for d in diffs if d[0] == fr and d[1] == 50]
    other = [d for d in diffs if not (d[0] == fr and d[1] in (20, 50))]
    print(k, "frame", fr, "bit", bit, "| datahit", len(hits), "| ecc bits", len(ecc),
          "| other", len(other), other[:4])
