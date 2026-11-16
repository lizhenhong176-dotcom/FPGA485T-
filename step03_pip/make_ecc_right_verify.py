# -*- coding: utf-8 -*-
"""远端 D 步：用 ecc_table.json 在右半实验（CLBLM_R/IMUX6 的 24 个变体）上验证 word50 预测。"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

SCRIPT = r'''# -*- coding: utf-8 -*-
import json, os, struct

R = "/opt/lzh/step03/right"
SYNC = b"\xaa\x99\x55\x66"
FW = 101
COL = __COL__


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


ref = frames(os.path.join(R, "ref_rA1.bit"))
ok = bad = unknown = 0
for fn in sorted(os.listdir(R)):
    if not (fn.startswith("v_rA1_") and fn.endswith(".bit")):
        continue
    var = frames(os.path.join(R, fn))
    for k in range(len(ref)):
        a, b = ref[k], var[k]
        if a[:50] == b[:50]:
            continue
        syn = 0
        miss = False
        for w in range(50):
            d = a[w] ^ b[w]
            for bit in bits(d):
                v = COL.get("%d:%d" % (w, bit))
                if v is None:
                    miss = True
                    break
                syn ^= v
            if miss:
                break
        if miss:
            unknown += 1
            continue
        pred = (a[50] ^ syn) & 0x1FFF
        actual = b[50] & 0x1FFF
        if pred == actual:
            ok += 1
        else:
            bad += 1
            if bad <= 5:
                print("MISMATCH", fn, k, bin(pred), bin(actual))
print("RIGHT ECC ok=%d bad=%d unknown=%d" % (ok, bad, unknown))
high = sum(1 for fn in os.listdir(R) if fn.startswith("v_rA1_") and fn.endswith(".bit")
           for fr in frames(os.path.join(R, fn)) for w in [50] if fr[w] >> 13)
print("frames with word50 high bits:", high)
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/right"
open(os.path.join(R, "verify_right_ecc.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("__BLOB__")).decode())
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "verify_right_ecc.py")], capture_output=True, text=True)
print(p.stdout[-3000:]); print("ERR", p.stderr[-1200:])
'''


def main():
    col = json.load(open(os.path.join(HERE, "ecc_table.json"), encoding="utf-8"))
    script = SCRIPT.replace("__COL__", json.dumps(col))
    blob = base64.b64encode(gzip.compress(script.encode(), 9)).decode()
    out = os.path.join(HERE, "_ecc_right.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out, os.path.getsize(out))


if __name__ == "__main__":
    main()
