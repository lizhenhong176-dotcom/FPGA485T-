import os
D = "/opt/lzh/step03/lutmap"
B = 31748
base = open(os.path.join(D, "v_0000000000000000.bit"), "rb").read()
ps, pe = 338, 20271442
pay0 = base[ps:pe]
NF = (pe - ps) // 404

def pos(k):
    df = 2 * (1 - ((k >> 3) & 1)) + (k & 1)
    bit = 15 - 4 * (k >> 4) - ((k >> 1) & 3)
    return B + df, bit

ok = 0
bad = []
for k in range(64):
    f = os.path.join(D, "v_%016x.bit" % (1 << k))
    if not os.path.exists(f):
        bad.append((k, "missing")); continue
    buf = open(f, "rb").read()
    pay = buf[ps:pe]
    diffs = []
    for i in range(0, len(pay), 4):
        w4 = pay[i:i+4]
        if w4 != pay0[i:i+4]:
            x = int.from_bytes(w4, "big") ^ int.from_bytes(pay0[i:i+4], "big")
            off = i % 404
            while x:
                lb = x & -x
                diffs.append((i // 404, off // 4, (off % 4) * 8 + lb.bit_length() - 1))
                x ^= lb
    fr, bit = pos(k)
    datahit = [d for d in diffs if d[0] == fr and d[1] == 20 and d[2] == bit]
    ecc = [d for d in diffs if d[0] == fr and d[1] == 50]
    other = [d for d in diffs if not (d[0] == fr and d[1] in (20, 50))]
    if datahit and ecc and not other:
        ok += 1
    else:
        bad.append((k, len(datahit), len(ecc), len(other)))
print("ok", ok, "/ 64")
print("bad", bad[:6])
