# -*- coding: utf-8 -*-
import gzip, os, struct, sys

DIR = "/opt/lzh/step03/tilepipe"
SYNC = b"\xaa\x99\x55\x66"
FW = 101

def frames(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    body = data[pos + 4:]
    n = len(body) // 4
    words = list(struct.unpack(">%dI" % n, body[:n * 4]))
    payload, i = [], 0
    while i < len(words):
        h = words[i]; i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            k = h & 0x7FFFFFF; payload.extend(words[i:i+k]); i += k; continue
        if typ != 1: break
        if op == 0: continue
        if op == 1: i += 1; continue
        if addr == 0x02:
            if cnt == 0:
                t2 = words[i]; i += 1; k = t2 & 0x7FFFFFF
            else:
                k = cnt
            payload.extend(words[i:i+k]); i += k; continue
        i += cnt
    return [payload[k*FW:(k+1)*FW] for k in range(len(payload)//FW)]

def bits(w):
    out = []
    while w:
        b = w & -w; out.append(b.bit_length()-1); w ^= b
    return out

tags = sorted(fn[4:-4] for fn in os.listdir(DIR) if fn.startswith("ref_") and fn.endswith(".bit"))
# 取前 12 个 tag 做拟合样本
tags = tags[:]
out = gzip.open(os.path.join(DIR, "ecc_samples_all.csv.gz"), "wt")
n = 0
for tag in tags:
    rp = os.path.join(DIR, "ref_%s.bit" % tag)
    ref = frames(rp)
    for fn in sorted(os.listdir(DIR)):
        if not (fn.startswith("v_" + tag + "_") and fn.endswith(".bit")):
            continue
        src = fn[len("v_" + tag) + 1:-4]
        var = frames(os.path.join(DIR, fn))
        for k in range(len(ref)):
            a, b = ref[k], var[k]
            if a[0:50] == b[0:50]:
                continue
            pos = []
            for w in range(50):
                if a[w] != b[w]:
                    for bit in bits(a[w] ^ b[w]):
                        pos.append("%d:%d" % (w, bit))
            out.write("%s,%s,%d,%s,%d,%d\n" % (tag, src, len(pos), ";".join(pos), a[50] & 0x1FFF, b[50] & 0x1FFF))
            n += 1
out.close()
print("TAGS", len(tags), "ROWS", n)
