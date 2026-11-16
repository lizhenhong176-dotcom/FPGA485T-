"""E7 生成器：F(word) 是否与 frame 无关（跨行带 / 跨列）。

E6 已得 frame 31786 上 word 0..48（偶）与 51..99（奇）的完整 F 表。
但全部落在同一个 frame，无法区分「F 只依赖 word」还是「F 依赖 (frame,word)」。

E7 取同一 word=8（行 Y%50=4）在三个不同位置：
  A: SLICE_X12Y4   （已知，frame 31786）
  B: SLICE_X12Y54  （同一 tile 列、下一个 clock region 行带 → 不同 frame）
  C: SLICE_X20Y4   （不同 tile 列 → 不同 frame）
若三者 col 完全相同 ⇒ F 只依赖 word ⇒ 101 个字常数可通用于全器件 CLB tile。
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "_e7_run.sh")
PART = "xc7vx485tffg1157-3"
SITES = [("a", 12, 4), ("b", 12, 54), ("c", 20, 4)]


def verilog(tag, on):
    L = ["module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);"]
    for i, (s, x, y) in enumerate(SITES):
        init = 1 if i == on else 0
        L.append("  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT(64'h%016X)) u_lut%d (.O(o%d),\n"
                 "      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));" % (init, i, i))
    L.append("endmodule")
    return "\n".join(L) + "\n"


def tcl(tag, on):
    L = ["read_verilog ./%s.v" % tag, "synth_design -top top -part %s" % PART]
    for i, (s, x, y) in enumerate(SITES):
        L.append("set_property LOC SLICE_X%dY%d [get_cells u_lut%d]" % (x, y, i))
        L.append("set_property BEL A6LUT [get_cells u_lut%d]" % i)
        L.append("set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut%d]" % i)
    L += ["place_design", "route_design",
          'puts "CHK_%s PART=[get_property PART [current_design]]"' % tag]
    for i, (s, x, y) in enumerate(SITES):
        L.append('puts "SITE_%s_%d [get_property SITE [get_cells u_lut%d]] INIT=[get_property INIT [get_cells u_lut%d]]"'
                 % (tag, i, i, i))
    L += ["set_property SEVERITY {Warning} [get_drc_checks NSTD-1]",
          "set_property SEVERITY {Warning} [get_drc_checks UCIO-1]",
          "set_property CFGBVS VCCO [current_design]",
          "set_property CONFIG_VOLTAGE 3.3 [current_design]",
          "write_bitstream -force ./%s.bit" % tag,
          'puts "DONE_%s"' % tag]
    return "\n".join(L) + "\n"


DIFF_PY = r'''# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def fdraws(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
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
    a = fdraws(d + "/e7_b.bit")
    res = {"base_words": len(a), "items": {}}
    for tag in sys.argv[2].split(","):
        b = fdraws(d + "/" + tag + ".bit")
        content, ecc = [], {}
        for idx in range(min(len(a), len(b))):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            if wd == 50:
                ecc[fr] = [a[idx], b[idx]]
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["items"][tag] = {"content": content, "ecc": {str(k): v for k, v in ecc.items()}}
    print(json.dumps(res))


main()
'''


def main():
    tags = ["e7_b"] + ["e7_" + s for s, _, _ in SITES]
    PS = ["set -u",
          "export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE",
          "export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic",
          "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64",
          "D=/opt/lzh/v7re/work/e7; rm -rf $D; mkdir -p $D; cd $D || exit 1"]
    PS.append("cat > e7_b.v <<'VEOF'\n%sVEOF" % verilog("e7_b", -1))
    PS.append("cat > e7_b.tcl <<'TEOF'\n%sTEOF" % tcl("e7_b", -1))
    for i, (s, x, y) in enumerate(SITES):
        t = "e7_" + s
        PS.append("cat > %s.v <<'VEOF'\n%sVEOF" % (t, verilog(t, i)))
        PS.append("cat > %s.tcl <<'TEOF'\n%sTEOF" % (t, tcl(t, i)))
    PS.append("cat > diff_e7.py <<'PYEOF'\n%sPYEOF" % DIFF_PY)
    PS.append("runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace "
              "-source $t.tcl > $t.log 2>&1; if grep -q \"DONE_$t\" $t.log; then echo \"OK $t\"; "
              "grep -h SITE_ $t.log; else echo \"FAIL $t\"; tail -n 5 $t.log; fi; }\nexport -f runone")
    PS.append("for t in %s; do echo $t; done | xargs -P 4 -I{} bash -c 'runone {}'" % " ".join(tags))
    PS.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
    PS.append("$PY diff_e7.py . '%s'" % ",".join("e7_" + s for s, _, _ in SITES))
    PS.append("echo E7JSON_BEGIN")
    PS.append("$PY diff_e7.py . '%s'" % ",".join("e7_" + s for s, _, _ in SITES))
    PS.append("echo E7JSON_END")
    PS.append("echo E7DONE")
    text = "\n".join(PS) + "\n"
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote", OUT, len(text), "B")


main()
