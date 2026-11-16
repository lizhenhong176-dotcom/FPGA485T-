# -*- coding: utf-8 -*-
"""远端：从 tilepipe 的 ref/v 位流里抽取「配置位增量 → word50(ECC) 增量」样本，用于拟合 ECC 线性码。

输出 /opt/lzh/step03/tilepipe/ecc_samples_all.csv.gz：每行
    tag,src,nbits,w1:b1;w2:b2;...,ecc_ref,ecc_var
只取差异帧（10 帧窗口内），只取 word 0..49 的差异位。
"""
import base64
import gzip
import os

SCRIPT = r'''# -*- coding: utf-8 -*-
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
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/tilepipe"
open(os.path.join(R, "dump_ecc.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("__BLOB__")).decode())
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "dump_ecc.py")], capture_output=True, text=True)
print(p.stdout[-1500:]); print("ERR", p.stderr[-1000:])
import base64 as b64
print("GZ_B64", b64.b64encode(open(os.path.join(R, "ecc_samples_all.csv.gz"), "rb").read()).decode())
'''


def main():
    blob = base64.b64encode(gzip.compress(SCRIPT.encode(), 9)).decode()
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_ecc_dump.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out)


if __name__ == "__main__":
    main()
