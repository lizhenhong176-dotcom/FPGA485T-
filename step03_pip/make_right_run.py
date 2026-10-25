# -*- coding: utf-8 -*-
"""远端 B 步：对右半 CLBLM_R 的 IMUX6 做 24 源变体 + bitgen，并把每个变体与我们的编码器预测逐位比对。

比对方式不依赖基址：先在变体里找「与 ref 不同的帧」，取最小帧号作窗口起点 base，
然后断言差异集合 == { (base+df, word, bit) }（word = 22 + ((6//4)%2) = 22）。
同时统计 word 50（ECC）是否被 Vivado 重算。
"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

RUN = r'''#!/bin/bash
set -u
R=/opt/lzh/step03/right; cd $R || exit 1
export LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
# 1) 枚举 IMUX 源并生成 ref/v_*.dcp（sink 过滤已放宽为 IMUX 前缀）
DCP=rA1.dcp EDF=rA1.edf OUT=$R TAG=rA1 /opt/lzh/venv/bin/python p6_make.py 2>&1 | tail -4
echo "dcps=$(ls v_*.dcp 2>/dev/null | wc -l)"
ls v_*.dcp ref_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; '$V' -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_*.bit 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l)"
'''

VERIFY = r'''# -*- coding: utf-8 -*-
import gzip, json, os, struct, sys, base64

DATA = json.loads(gzip.decompress(base64.b64decode("__BLOB__")))
CELLS = DATA["cells"]          # {src: [[df,bit],...]}
DOMAIN = DATA["domain"]        # [[df,bit],...]
GLOB = DATA["glob"]            # 通配位 [[df,bit],...]
R = "/opt/lzh/step03/right"
SYNC = b"\xaa\x99\x55\x66"
FW = 101


def frames(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    body = data[pos + 4:]
    n = len(body) // 4
    words = list(struct.unpack(">%dI" % n, body[:n * 4]))
    payload = []
    i = 0
    while i < len(words):
        h = words[i]; i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            k = h & 0x7FFFFFF
            payload.extend(words[i:i + k]); i += k; continue
        if typ != 1:
            break
        if op == 0:
            continue
        if op == 1:
            i += 1; continue
        if addr == 0x02:
            if cnt == 0:
                t2 = words[i]; i += 1
                k = t2 & 0x7FFFFFF
            else:
                k = cnt
            payload.extend(words[i:i + k]); i += k; continue
        i += cnt
    return [payload[k * FW:(k + 1) * FW] for k in range(len(payload) // FW)]


def bits_of(word):
    out = []
    v = word
    while v:
        b = v & -v
        out.append(b.bit_length() - 1)
        v ^= b
    return out


W = 22
refp = os.path.join(R, "ref_rA1.bit")
ref = frames(refp)
ok = fail = 0
ecc_files = 0
for src, cells in sorted(CELLS.items()):
    vp = os.path.join(R, "v_rA1_%s.bit" % src)
    if not os.path.exists(vp):
        print("missing", src); continue
    var = frames(vp)
    diffs = []
    for i, (a, b) in enumerate(zip(ref, var)):
        if a != b:
            for w in range(50):
                if a[w] != b[w]:
                    for bit in bits_of(a[w] ^ b[w]):
                        diffs.append((i, w, bit))
    if not diffs:
        print("%-14s NO-DIFF" % src); fail += 1; continue
    base = min(d[0] for d in diffs)
    expect = {(base + df, W, bit) for df, bit in cells}
    got = set(diffs)
    # 允许窗口外的全局控制位（domain 里的通配位）
    extra = got - expect
    missing = expect - got
    good = not extra and not missing
    ok += good
    fail += (not good)
    print("%-14s %s base=%d bits=%d extra=%d missing=%d" % (
        src, "PASS" if good else "FAIL", base, len(got), len(extra), len(missing)))
    for e in sorted(extra)[:3]:
        print("    extra", e)
    for m in sorted(missing)[:3]:
        print("    missing", m)
    # word50 是否被重算
    e50 = sum(1 for k in range(base, min(base + 10, len(ref))) if ref[k][50] != var[k][50])
    if e50:
        ecc_files += 1
print("RESULT ok=%d fail=%d ecc_files=%d" % (ok, fail, ecc_files))
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, json, os, subprocess
FILES = json.loads(gzip.decompress(base64.b64decode("__BLOB__")))
R = "/opt/lzh/step03/right"
for name, txt in FILES["files"].items():
    open(os.path.join(R, name), "w", newline="\n").write(txt)
os.chmod(os.path.join(R, "run.sh"), 0o755)
p = subprocess.run(["bash", os.path.join(R, "run.sh")], capture_output=True, text=True)
print(p.stdout[-3000:])
print("ERR", p.stderr[-1000:])
open(os.path.join(R, "verify.py"), "w", newline="\n").write(FILES["verify"])
v = subprocess.run(["/usr/bin/python3", os.path.join(R, "verify.py")], capture_output=True, text=True)
print(v.stdout[-4000:])
print("VERR", v.stderr[-1500:])
'''


def main():
    cells_raw = json.load(open(os.path.join(HERE, "imux_cells.json"), encoding="utf-8"))
    # 本次只关心 INT_R|IMUX6
    cells = {}
    for r in cells_raw:
        if r["tile_type"] != "INT_R" or r["mux"] != "IMUX6":
            continue
        cells.setdefault(r["src_wire"], []).append([r["df"], r["bit"]])
    dom_raw = json.load(open(os.path.join(HERE, "imux_domain.json"), encoding="utf-8"))
    domain = dom_raw.get("INT_R|IMUX6", [])
    p6 = open(os.path.join(HERE, "p6_make.py"), encoding="utf-8").read().replace(
        'startswith("IMUX_")', 'startswith("IMUX")')
    files = {"p6_make.py": p6, "run.sh": RUN}
    verify = VERIFY.replace("__BLOB__", base64.b64encode(gzip.compress(json.dumps(
        {"cells": cells, "domain": domain, "glob": []}, separators=(",", ":")).encode(), 9)).decode())
    blob = base64.b64encode(gzip.compress(json.dumps(
        {"files": files, "verify": verify}).encode(), 9)).decode()
    out = os.path.join(HERE, "_right_run.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out, os.path.getsize(out), "sources", len(cells), "domain", len(domain))


if __name__ == "__main__":
    main()
