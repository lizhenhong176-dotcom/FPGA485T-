"""E5 生成器：在同一个 frame 里取多个 word 的单比特列，检验 S(word) 对 word 索引的 GF(2) 线性。

E4 已得（frame 31786，word = 2*Y，bit 15，par(15)=0）：
  col(8)=0x144F col(10)=0x148F col(12)=0x04CF col(14)=0x150F  →  S(w)=col^15
  S(8)=0x1440 S(10)=0x1480 S(12)=0x04C0 S(14)=0x1500 S(40)=0x0860
  检验 S(8)^S(10)^S(12)^S(14)=0x1100 != 0  → 对 word 索引不线性（在 8/10/12/14 四点上看）

E5 换一组「基底字」再判：
  word 2,4,8,16,32,64 分别只置一个 word 索引位 → 直接得到 6 个基向量 W_1..W_6
  再取两个复合字：40 = 32^8、96 = 64^32
  判据（若 S 线性）：S(40) ?= W_5 ^ W_3，S(96) ?= W_6 ^ W_5
  任一不等 ⇒ 线性假设否证（这次是在完整基底上）。
设计：8 个 LUT6 固定 LOC 在 SLICE_X12Y{1,2,4,8,16,20,32,48}，共 9 个构建（1 base + 8 变体）。
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "_e5_run.sh")
PART = "xc7vx485tffg1157-3"
# (tag_suffix, Y, word)
JOBS = [
    ("w2", 1, 2),
    ("w4", 2, 4),
    ("w8", 4, 8),
    ("w16", 8, 16),
    ("w32", 16, 32),
    ("w40", 20, 40),
    ("w64", 32, 64),
    ("w96", 48, 96),
]


def verilog(tag, idx_on):
    lines = ["module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3,o4,o5,o6,o7);"]
    for i, (suf, y, w) in enumerate(JOBS):
        init = 1 if i == idx_on else 0
        lines.append(
            "  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT(64'h%016X)) u_lut%d (.O(o%d),\n"
            "      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));" % (init, i, i))
    lines.append("endmodule")
    return "\n".join(lines) + "\n"


def tcl(tag):
    L = ["read_verilog ./%s.v" % tag,
         "synth_design -top top -part %s" % PART]
    for i, (suf, y, w) in enumerate(JOBS):
        L.append("set_property LOC SLICE_X12Y%d [get_cells u_lut%d]" % (y, i))
        L.append("set_property BEL A6LUT [get_cells u_lut%d]" % i)
        L.append("set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut%d]" % i)
    L.append("place_design")
    L.append("route_design")
    L.append('puts "CHK_%s PART=[get_property PART [current_design]]"' % tag)
    for i in range(len(JOBS)):
        L.append('puts "SITE_%s_%d [get_property SITE [get_cells u_lut%d]] INIT=[get_property INIT [get_cells u_lut%d]]"'
                 % (tag, i, i, i))
    L += ['set_property SEVERITY {Warning} [get_drc_checks NSTD-1]',
          'set_property SEVERITY {Warning} [get_drc_checks UCIO-1]',
          'set_property CFGBVS VCCO [current_design]',
          'set_property CONFIG_VOLTAGE 3.3 [current_design]',
          'write_bitstream -force ./%s.bit' % tag,
          'puts "DONE_%s"' % tag]
    return "\n".join(L) + "\n"


DIFF_PY = r'''# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def fdraws(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync " + path)
    body = raw[i + 4:]
    n = len(body) // 4
    w = struct.unpack(">%dI" % n, body[: n * 4])
    out = []
    k = 0
    while k < n:
        h = w[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            c = h & 0x7FFFFFF
            out.extend(w[k:k + c])
            k += c
            continue
        if typ != 1:
            continue
        if op == 2 and cnt:
            k += cnt
        elif op == 1:
            k += 1
    return out


def main():
    d = sys.argv[1]
    pairs = sys.argv[2].split(",")
    cache = {}

    def get(tag):
        if tag not in cache:
            cache[tag] = fdraws(d + "/" + tag + ".bit")
        return cache[tag]

    res = {"variants": {}, "base_words": None}
    for p in pairs:
        base_tag, var_tag = p.split(":")
        a = get(base_tag)
        b = get(var_tag)
        res["base_words"] = len(a)
        if len(a) != len(b):
            res["variants"][var_tag] = {"error": "len %d vs %d" % (len(a), len(b))}
            continue
        content, ecc_changed, frames = [], {}, set()
        for idx in range(len(a)):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            frames.add(fr)
            if wd == 50:
                ecc_changed.setdefault(fr, [a[idx], b[idx]])
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["variants"][var_tag] = {
            "content": content,
            "n_content": len(content),
            "ecc": {str(k): v for k, v in sorted(ecc_changed.items())},
            "frames": sorted(frames),
        }
        print("done", var_tag, len(content), len(ecc_changed), file=sys.stderr)
    print(json.dumps(res))


main()
'''


def main():
    PS = ["set -u",
          "export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE",
          "export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic",
          "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64",
          "D=/opt/lzh/v7re/work/e5; rm -rf $D; mkdir -p $D; cd $D || exit 1"]
    tags = ["e5_b"] + ["e5_" + j[0] for j in JOBS]
    PS.append("cat > e5_b.v <<'VEOF'\n%sVEOF" % verilog("e5_b", -1))
    PS.append("cat > e5_b.tcl <<'TEOF'\n%sTEOF" % tcl("e5_b"))
    for i, (suf, y, w) in enumerate(JOBS):
        t = "e5_" + suf
        PS.append("cat > %s.v <<'VEOF'\n%sVEOF" % (t, verilog(t, i)))
        PS.append("cat > %s.tcl <<'TEOF'\n%sTEOF" % (t, tcl(t)))
    PS.append("cat > diff_e5.py <<'PYEOF'\n%sPYEOF" % DIFF_PY)
    PS.append(
        "runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace "
        "-source $t.tcl > $t.log 2>&1; if grep -q \"DONE_$t\" $t.log; then echo \"OK $t\"; "
        "grep -h 'SITE_' $t.log; else echo \"FAIL $t\"; tail -n 5 $t.log; fi; }\nexport -f runone")
    PS.append("for t in %s; do echo $t; done | xargs -P 9 -I{} bash -c 'runone {}'" % " ".join(tags))
    pairs = ",".join("e5_b:e5_%s" % j[0] for j in JOBS)
    PS.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
    PS.append("$PY diff_e5.py . '%s' 2>diff.err > diff.json" % pairs)
    PS.append("echo ERR_BEGIN; cat diff.err; echo ERR_END")
    PS.append("echo E5JSON_BEGIN")
    PS.append("cat diff.json")
    PS.append("echo E5JSON_END")
    PS.append("echo E5DONE")
    text = "\n".join(PS) + "\n"
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote", OUT, len(text), "B")
    for i, (suf, y, w) in enumerate(JOBS):
        print("  e5_%-4s Y=%-3d word=%-3d lut_idx=%d" % (suf, y, w, i))


main()
