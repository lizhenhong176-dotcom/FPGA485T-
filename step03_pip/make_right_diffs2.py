# -*- coding: utf-8 -*-
"""远端：用「全局最小帧」作基准，重新导出 rA1 差异位（每个源的 df 都相对同一窗口起点）。"""
import base64
import gzip
import os

SCRIPT = r'''# -*- coding: utf-8 -*-
import os, struct

R = "/opt/lzh/step03/right"
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

ref = frames(os.path.join(R, "ref_rA1.bit"))
per = {}
allf = []
for fn in sorted(os.listdir(R)):
    if not fn.startswith("v_rA1_") or not fn.endswith(".bit"):
        continue
    src = fn[len("v_rA1_"):-4]
    var = frames(os.path.join(R, fn))
    diffs = []
    for i, (a, b) in enumerate(zip(ref, var)):
        if a != b:
            for w in range(50):
                if a[w] != b[w]:
                    for bit in bits(a[w] ^ b[w]):
                        diffs.append((i, w, bit))
    per[src] = diffs
    allf += [d[0] for d in diffs]
base = min(allf)
print("GLOBAL_BASE", base, "min/max", base, max(allf))
with open(os.path.join(R, "diffs2.csv"), "w") as f:
    for src, diffs in sorted(per.items()):
        for i, w, bit in diffs:
            f.write("%s,%d,%d,%d\n" % (src, i - base, w, bit))
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/right"
open(os.path.join(R, "dump_diffs2.py"), "w", newline="\n").write(
    gzip.decompress(base64.b64decode("__BLOB__")).decode())
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "dump_diffs2.py")], capture_output=True, text=True)
print(p.stdout[-1500:]); print("ERR", p.stderr[-800:])
import base64 as b64
print("CSV_B64", b64.b64encode(open(os.path.join(R, "diffs2.csv")).read().encode()).decode())
'''


def main():
    blob = base64.b64encode(gzip.compress(SCRIPT.encode(), 9)).decode()
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_right_diffs2.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out)


if __name__ == "__main__":
    main()
