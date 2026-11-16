"""E6 生成器：把 frame 31786 的全部 50 个「偶数字槽」的 F(word) 一次测完。

E4/E5 已确定的结构（frame 31786、bit 15、par(15)=0）：
    col(word, bit) = F(word) ^ bit ^ (popcount(bit)%2 ? 0x1000 : 0)      (bit < 16)
    F(word) = col ^ 0xF
已测：F(2)=0x1360 F(4)=0x13A0 F(8)=0x1440 F(10)=0x1480 F(12)=0x04C0
      F(14)=0x1500 F(16)=0x0540 F(32)=0x1740 F(40)=0x0860 F(65)=0x1B80 F(97)=0x0F80
已否证：F 对 word 索引 GF(2) 线性
      F(32)^F(8)=0x0300 != F(40)=0x0860
      F(65)^F(32)=0x0C40 != F(97)=0x0F80
      F(8)^F(10)^F(12)^F(14)=0x1100 != 0

E6：SLICE_X12Y0..Y49（word = 2Y，A6LUT 只写偶数字槽），50 个变体 + 1 个 base = 51 构建。
产出 F(0..98 偶数) 完整表，供离线拟合（递推/幂次/查表/CRC 假设）。
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "_e6_run.sh")
PART = "xc7vx485tffg1157-3"
YS = list(range(50))
N = len(YS)


def verilog(tag, on):
    L = ["module top(input a0,a1,a2,a3,a4,a5,"]
    L.append("  output " + ",".join("o%d" % i for i in range(N)) + ");")
    for i, y in enumerate(YS):
        init = 1 if i == on else 0
        L.append("  (* DONT_TOUCH = \"true\" *) LUT6 #(.INIT(64'h%016X)) u_lut%d (.O(o%d),\n"
                 "      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));" % (init, i, i))
    L.append("endmodule")
    return "\n".join(L) + "\n"


def tcl(tag, on):
    L = ["read_verilog ./%s.v" % tag, "synth_design -top top -part %s" % PART]
    for i, y in enumerate(YS):
        L.append("set_property LOC SLICE_X12Y%d [get_cells u_lut%d]" % (y, i))
        L.append("set_property BEL A6LUT [get_cells u_lut%d]" % i)
        L.append("set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut%d]" % i)
    L += ["place_design", "route_design",
          'puts "CHK_%s PART=[get_property PART [current_design]]"' % tag]
    if on >= 0:
        L.append('puts "SITEON [get_property SITE [get_cells u_lut%d]] INIT=[get_property INIT [get_cells u_lut%d]]"'
                 % (on, on))
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
    a = fdraws(d + "/e6_b.bit")
    res = {"base_words": len(a), "items": {}}
    for tag in sys.argv[2].split(","):
        b = fdraws(d + "/" + tag + ".bit")
        if len(a) != len(b):
            res["items"][tag] = {"error": "len"}
            continue
        content, ecc = [], {}
        for idx in range(len(a)):
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
        print("done", tag, file=sys.stderr)
    print(json.dumps(res))


main()
'''


def main():
    tags = ["e6_b"] + ["e6_y%d" % y for y in YS]
    PS = ["set -u",
          "export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE",
          "export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic",
          "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64",
          "D=/opt/lzh/v7re/work/e6; rm -rf $D; mkdir -p $D; cd $D || exit 1"]
    PS.append("cat > e6_b.v <<'VEOF'\n%sVEOF" % verilog("e6_b", -1))
    PS.append("cat > e6_b.tcl <<'TEOF'\n%sTEOF" % tcl("e6_b", -1))
    for i, y in enumerate(YS):
        t = "e6_y%d" % y
        PS.append("cat > %s.v <<'VEOF'\n%sVEOF" % (t, verilog(t, i)))
        PS.append("cat > %s.tcl <<'TEOF'\n%sTEOF" % (t, tcl(t, i)))
    PS.append("cat > diff_e6.py <<'PYEOF'\n%sPYEOF" % DIFF_PY)
    PS.append(
        "runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace "
        "-source $t.tcl > $t.log 2>&1; if grep -q \"DONE_$t\" $t.log; then echo \"OK $t\"; "
        "grep -h SITEON $t.log; else echo \"FAIL $t\"; fi; }\nexport -f runone")
    PS.append("for t in %s; do echo $t; done | xargs -P 8 -I{} bash -c 'runone {}'" % " ".join(tags))
    PS.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
    PS.append("$PY diff_e6.py . '%s' 2>diff.err > diff.json" % ",".join("e6_y%d" % y for y in YS))
    PS.append("echo ERR_BEGIN; cat diff.err; echo ERR_END")
    PS.append("echo E6JSON_BEGIN")
    PS.append("cat diff.json")
    PS.append("echo E6JSON_END")
    PS.append("echo E6DONE")
    text = "\n".join(PS) + "\n"
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote", OUT, len(text), "B, builds =", len(tags))


main()
