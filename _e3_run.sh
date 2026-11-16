set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e3; rm -rf $D; mkdir -p $D; cd $D || exit 1
# e3_base :  c_base  0
cat > e3_base.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_base.tcl <<'TEOF'
read_verilog ./e3_base.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_base SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_base.bit
puts "DONE_e3_base"
TEOF
# e3_a : 31786  w15 + w14INIT bit0+bit2
cat > e3_a.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000005)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_a.tcl <<'TEOF'
read_verilog ./e3_a.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_a SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_a.bit
puts "DONE_e3_a"
TEOF
# e3_b : 31786  w15,14,13,12INIT bit0,2,4,6
cat > e3_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000055)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_b.tcl <<'TEOF'
read_verilog ./e3_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_b SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_b.bit
puts "DONE_e3_b"
TEOF
# e3_c : bit0->31786.w15, bit1->31787.w15 1
cat > e3_c.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000003)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_c.tcl <<'TEOF'
read_verilog ./e3_c.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_c SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_c.bit
puts "DONE_e3_c"
TEOF
# e3_d : 31786  w14 + w13INIT bit2+bit4
cat > e3_d.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000014)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_d.tcl <<'TEOF'
read_verilog ./e3_d.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_d SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_d.bit
puts "DONE_e3_d"
TEOF
# e3_e : 31786  16 INIT bit 0,2,4,6,16..22,32..38,48..54
cat > e3_e.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0055005500550055)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e3_e.tcl <<'TEOF'
read_verilog ./e3_e.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e3_e SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e3_e.bit
puts "DONE_e3_e"
TEOF
cat > diff_e3.py <<'PYEOF'
# -*- coding: utf-8 -*-
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
            c27 = h & 0x7FFFFFF
            out.extend(words[k:k + c27])
            k += c27
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
    d = sys.argv[1] if len(sys.argv) > 1 else "."
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
PYEOF
runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1; if grep -q "DONE_$t" $t.log; then grep CHK_$t $t.log; echo "OK $t"; else echo "FAIL $t"; tail -n 5 $t.log; fi; }
export -f runone
for t in e3_base e3_a e3_b e3_c e3_d e3_e; do echo $t; done | xargs -P 6 -I{} bash -c 'runone {}'
ls -l *.bit | head -20
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e3.py . e3_base,e3_a,e3_b,e3_c,e3_d,e3_e 2>diff.err > diff.json
cat diff.err
echo E3DIFF_JSON_BEGIN
cat diff.json
echo E3DIFF_JSON_END
echo E3DONE
