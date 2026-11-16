"""E3 生成器：造「同帧多位置位」的 LUT6 INIT 变体，用于判决 word50 是 XOR 型还是算术型。

设计沿用 _crcgen_run.sh 的原模板：SLICE_X12Y20 / A6LUT / LOCK_PINS I0:A1..I5:A6 /
part xc7vx485tffg1157-3。INIT 的 64 位按 INIT bit i 映射到 4 帧内的 word40 位：

  i        帧             word40 bit
  0,1      31786,31787   15
  2,3      31786,31787   14
  4,5      31786,31787   13
  6,7      31786,31787   12
  8..15    31784,31785   15,15,14,14,13,13,12,12
  ...      (每组 8 位向后挪 4 个 word40 bit)

单比特实测 ECC（c(w)）：
  w:  0     1     2     3     4     5     6     7
      0860  1861  1862  0863  1864  0865  0866  1867
  w:  8     9     A     B     C     D     E     F
      1868  0869  086A  186B  086C  186D  186E  086F
"""
import os

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "_e3_run.sh")

PART = "xc7vx485tffg1157-3"

# tag -> (INIT 值, 说明)
# 帧 31786 收 INIT bit {0,2,4,6}->w15,14,13,12 ; {16..22}->w11..8 ;
#            {32..38}->w7..4 ; {48..54}->w3..0
VARIANTS = [
    ("e3_base", 0x0000000000000000,
     "负对照：与 c_base 同设计同参数重跑，差分应为 0"),
    ("e3_a", 0x0000000000000005,
     "帧31786 置 w15 + w14（INIT bit0+bit2）"),
    ("e3_b", 0x0000000000000055,
     "帧31786 置 w15,14,13,12（INIT bit0,2,4,6）"),
    ("e3_c", 0x0000000000000003,
     "跨帧控制：bit0->31786.w15, bit1->31787.w15（各帧仍只有 1 位）"),
    ("e3_d", 0x0000000000000014,
     "帧31786 置 w14 + w13（INIT bit2+bit4）"),
    ("e3_e", 0x0055005500550055,
     "帧31786 全部 16 位（INIT bit 0,2,4,6,16..22,32..38,48..54）"),
]

V_TMPL = """module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h{init:016x})) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
"""

T_TMPL = """read_verilog ./{tag}.v
synth_design -top top -part {part}
set_property LOC SLICE_X12Y20 [get_cells u_lut]
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
"""远端差分：按 Xilinx 包结构取 FDRI 数据 -> 50176 x 101 帧，逐字比较。
只回传 JSON，不回传 .bit。"""
import json, struct, sys, os

SYNC = b"\xaa\x99\x55\x66"
FRAME_WORDS = 101


def payload(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync in " + path)
    body = raw[i + 4:]
    words = struct.unpack(">%dI" % (len(body) // 4), body[: (len(body) // 4) * 4])
    out = []
    n = len(words)
    k = 0
    fdri = 0x0002
    while k < n:
        h = words[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            out.extend(words[k:k + cnt])
            k += cnt
            continue
        if typ != 1:
            continue
        if op == 1:          # READ：只有包头，无数据
            continue
        if op != 2:
            continue
        if cnt == 0:
            continue
        if addr == fdri:
            out.extend(words[k:k + cnt])
        k += cnt
    return out


def main():
    d = os.path.dirname(os.path.abspath(sys.argv[1])) if len(sys.argv) > 1 else "."
    tags = sys.argv[2].split(",")
    base_tag = tags[0]
    base = payload(os.path.join(d, base_tag + ".bit"))
    nf = len(base) // FRAME_WORDS
    print(json.dumps({"base_frames": nf, "base_words": len(base)}), file=sys.stderr)
    res = {"frame_words": FRAME_WORDS, "frames": nf, "variants": {}}
    for tag in tags[1:]:
        w = payload(os.path.join(d, tag + ".bit"))
        if len(w) != len(base):
            res["variants"][tag] = {"error": "len %d != %d" % (len(w), len(base))}
            continue
        content = []          # (frame, word, bit) 非 word50
        ecc = {}              # frame -> [base_val, var_val]
        frames_touched = set()
        for idx in range(len(base)):
            a = base[idx]
            b = w[idx]
            if a == b:
                continue
            frame = idx // FRAME_WORDS
            word = idx % FRAME_WORDS
            frames_touched.add(frame)
            x = a ^ b
            bitlist = [bit for bit in range(32) if (x >> bit) & 1]
            if word == 50:
                ecc.setdefault(frame, [a, b])
            else:
                for bit in bitlist:
                    content.append([frame, word, bit])
        res["variants"][tag] = {
            "content_positions": content,
            "n_content": len(content),
            "ecc": {str(k): [v[0], v[1]] for k, v in sorted(ecc.items())},
            "frames_touched": sorted(frames_touched),
        }
        print("done", tag, "content", len(content), "eccframes", len(ecc), file=sys.stderr)
    print(json.dumps(res))


main()
'''


def main():
    parts = []
    parts.append("set -u")
    parts.append("export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE")
    parts.append("export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic")
    parts.append("export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64")
    parts.append("D=/opt/lzh/v7re/work/e3; rm -rf $D; mkdir -p $D; cd $D || exit 1")
    for tag, init, note in VARIANTS:
        parts.append("# %s : %s" % (tag, note))
        parts.append("cat > %s.v <<'VEOF'\n%sVEOF" % (tag, V_TMPL.format(init=init)))
        parts.append("cat > %s.tcl <<'TEOF'\n%sTEOF" % (tag, T_TMPL.format(tag=tag, part=PART)))
    parts.append("cat > diff_e3.py <<'PYEOF'\n%sPYEOF" % DIFF_PY)
    parts.append(
        "runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace "
        "-source $t.tcl > $t.log 2>&1; if grep -q \"DONE_$t\" $t.log; then grep CHK_$t $t.log; "
        "echo \"OK $t\"; else echo \"FAIL $t\"; tail -n 5 $t.log; fi; }\n"
        "export -f runone"
    )
    tags = ",".join(t for t, _, _ in VARIANTS)
    parts.append("printf '%s\\n' %s | xargs -P 6 -I{} bash -c 'runone {}'" % (
        " ".join(t for t, _, _ in VARIANTS), ""))
    # 上面那行写得别扭，改成直接列表
    parts[-1] = "for t in %s; do echo $t; done | xargs -P 6 -I{} bash -c 'runone {}'" % (
        " ".join(t for t, _, _ in VARIANTS))
    parts.append("ls -l *.bit | head -20")
    parts.append("PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3")
    parts.append("$PY diff_e3.py . %s 2>diff.err > diff.json" % tags)
    parts.append("cat diff.err")
    parts.append("echo E3DIFF_JSON_BEGIN")
    parts.append("cat diff.json")
    parts.append("echo E3DIFF_JSON_END")
    parts.append("echo E3DONE")
    text = "\n".join(parts) + "\n"
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote", OUT, len(text), "bytes,", text.count("\n"), "lines")
    for tag, init, note in VARIANTS:
        print("  %-8s INIT=0x%016X  bits=%s  %s" % (
            tag, init, sorted(i for i in range(64) if (init >> i) & 1), note))


main()
