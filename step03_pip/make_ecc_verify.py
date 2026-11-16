# -*- coding: utf-8 -*-
"""远端 C 步：用拟合出的 24 列 ECC 线性模型，在「没用过拟合的 24 个 tag」上验证 word50。"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

SCRIPT = r'''# -*- coding: utf-8 -*-
import gzip, json, os, struct

R = "/opt/lzh/step03/tilepipe"
SYNC = b"\xaa\x99\x55\x66"
FW = 101
FIT = __FIT__

# position (word*32+bit) -> 13-bit 列向量
colvec = {}
for i, pos in enumerate(FIT["cols"]):
    v = 0
    for k, m in enumerate(FIT["M"]):
        if (m >> i) & 1:
            v |= 1 << k
    colvec[pos] = v


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


def predict(delta_words):
    v = 0
    for w, bw in delta_words:
        for bit in bits(bw):
            v ^= colvec.get(w * 32 + bit, 0)
    return v


tags = sorted(fn[4:-4] for fn in os.listdir(R) if fn.startswith("ref_") and fn.endswith(".bit"))
tags = tags[12:]   # 拟合用掉前 12 个，这里用剩下的
ok = bad = missing = high = 0
examples = []
for tag in tags:
    ref = frames(os.path.join(R, "ref_%s.bit" % tag))
    for fn in sorted(os.listdir(R)):
        if not (fn.startswith("v_" + tag + "_") and fn.endswith(".bit")):
            continue
        var = frames(os.path.join(R, fn))
        for k in range(len(ref)):
            a, b = ref[k], var[k]
            if a[0:50] == b[0:50]:
                continue
            delta = [(w, a[w] ^ b[w]) for w in range(50) if a[w] != b[w]]
            unknown = [(w, x) for w, x in delta for bit in bits(x) if (w * 32 + bit) not in colvec]
            if unknown:
                missing += 1
                continue
            pred = predict(delta)
            actual = (a[50] ^ b[50]) & 0x1FFF
            if (a[50] >> 13) or (b[50] >> 13):
                high += 1
            if pred == actual:
                ok += 1
            else:
                bad += 1
                if len(examples) < 5:
                    examples.append((tag, fn, bin(pred), bin(actual)))
print("tags", len(tags))
print("ECC predict ok=%d bad=%d unknown-positions=%d highbits-nonzero=%d" % (ok, bad, missing, high))
for e in examples:
    print("  ", e)
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/tilepipe"
open(os.path.join(R, "verify_ecc.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("__BLOB__")).decode())
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "verify_ecc.py")], capture_output=True, text=True)
print(p.stdout[-3000:]); print("ERR", p.stderr[-1200:])
'''


def main():
    fit = json.load(open(os.path.join(HERE, "ecc_fit.json"), encoding="utf-8"))
    script = SCRIPT.replace("__FIT__", json.dumps({"cols": fit["cols"], "M": fit["M"]}))
    blob = base64.b64encode(gzip.compress(script.encode(), 9)).decode()
    out = os.path.join(HERE, "_ecc_verify.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out, os.path.getsize(out))


if __name__ == "__main__":
    main()
