"""E4 生成器：换 tile 行（Y），取不同 word 上的单比特列向量，检验「字常数」规律。

已知（E1/E2/E3）：
  - A6LUT @ SLICE_X12Y20 的 64 个 INIT 位落在 word 40（= 2*Y + 0），
    单比特列 col(40,w) = 0x860 ^ w ^ (popcount(w)%2 ? 0x1000 : 0)  (w = word40 内的 bit)
  - word50 = XOR over 置位位置的 col，仿射且常数为 0。

E4 要回答：换一行（word 变），列向量里的「字相关常数」C(word) 是什么？是否对 word 索引线性？
判据（不依赖 C 的绝对形状）：
  取 Y=4,5,6,7 → word 8,10,12,14，它们满足 8^10^12^14 = 0（GF(2)）。
  若 C(word) 对 word 线性，则四个单比特的列向量异或必须为 0。
  已知的 word40 常数 0x860 作为独立第二点参与检验。
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "_e4_run.sh")
PART = "xc7vx485tffg1157-3"
YS = [4, 5, 6, 7]

V_TMPL = """module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h{init:016x})) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
"""

T_TMPL = """read_verilog ./{tag}.v
synth_design -top top -part {part}
set_property LOC SLICE_X12Y{y} [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {{I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}} [get_cells u_lut]
place_design
route_design
puts "CHK_{tag} SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./{tag}.bit
puts "DONE_{tag}"
"""

DIFF_PY = r'''# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def payload(path):
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
        if typ != 1 or op != 2 or cnt == 0:
            continue
        out.extend(w[k:k + cnt])
        k += cnt
    return out


def main():
    d = sys.argv[1]
    pairs = sys.argv[2].split(",")
    cache = {}

    def get(tag):
        if tag not in cache:
            cache[tag] = payload(d + "/" + tag + ".bit")
        return cache[tag]

    res = {"variants": {}}
    for p in pairs:
        base_tag, var_tag = p.split(":")
        a = get(base_tag)
        b = get(var_tag)
        if len(a) != len(b):
            res["variants"][var_tag] = {"error": "len"}
            continue
        content, ecc, frames = [], {}, set()
        for idx in range(len(a)):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            frames.add(fr)
            if wd == 50:
                ecc.setdefault(fr, [a[idx], b[idx]])
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["variants"][var_tag] = {
            "base": base_tag,
            "base_frames": len(a) // FW,
            "content_positions": content,
            "n_content": len(content),
            "ecc": {str(k): v for k, v in sorted(ecc.items())},
            "frames_touched": sorted(frames),
        }
        print("done", var_tag, "content", len(content), "ecc", len(ecc), file=sys.stderr)
    print(json.dumps(res))


main()
'''


def main():
    jobs = []
    for y in YS:
        jobs.append(("e4_y%d_b" % y, y, 0x0))
        jobs.append(("e4_y%d_1" % y, y, 0x1))
    jobs.append(("e4_y4_3", 4, 0x3))

    ps = []
    ps.append("set -u")
    ps.append("export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE")
    ps.append("export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic")
    ps.append("export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64")
    ps.append("D=/opt/lzh/v7re/work/e4; rm -rf $D; mkdir -p $D; cd $D || exit 1")
    for tag, y, init in jobs:
        ps.append("cat > %s.v <<'VEOF'\n%sVEOF" % (tag, V_TMPL.format(init=init)))
        ps.append("cat > %s.tcl <<'TEOF'\n%sTEOF" % (tag, T_TMPL.format(tag=tag, part=PART, y=y)))
    ps.append("cat > diff_e4.py <<'PYEOF'\n%sPYEOF" % DIFF_PY)
    ps.append(
        "runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace "
        "-source $t.tcl > $t.log 2>&1; if grep -q \"DONE_$t\" $t.log; then grep CHK_$t $t.log; "
        "echo \"OK $t\"; else echo \"FAIL $t\"; tail -n 5 $t.log; fi; }\n"
        "export -f runone")
    ps.append("for t in %s; do echo $t; done | xargs -P 9 -I{} bash -c 'runone {}'" % (
        " ".join(t for t, _, _ in jobs)))
    pairs = []
    for y in YS:
        pairs.append("e4_y%d_b:e4_y%d_1" % (y, y))
    pairs.append("e4_y4_b:e4_y4_3")
    ps.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
    ps.append("$PY diff_e4.py . %s 2>diff.err > diff.json" % ",".join(pairs))
    ps.append("echo ERR_BEGIN; cat diff.err; echo ERR_END")
    ps.append("echo E4DIFF_JSON_BEGIN")
    ps.append("cat diff.json")
    ps.append("echo E4DIFF_JSON_END")
    ps.append("echo E4DONE")
    text = "\n".join(ps) + "\n"
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote", OUT, len(text), "B,", text.count("\n"), "lines")
    for tag, y, init in jobs:
        print("  %-10s Y=%-3d word=%-3d INIT=0x%016X" % (tag, y, 2 * y, init))


main()
