set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e4; rm -rf $D; mkdir -p $D; cd $D || exit 1
cat > e4_y4_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y4_b.tcl <<'TEOF'
read_verilog ./e4_y4_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y4_b SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y4_b.bit
puts "DONE_e4_y4_b"
TEOF
cat > e4_y4_1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y4_1.tcl <<'TEOF'
read_verilog ./e4_y4_1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y4_1 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y4_1.bit
puts "DONE_e4_y4_1"
TEOF
cat > e4_y5_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y5_b.tcl <<'TEOF'
read_verilog ./e4_y5_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y5 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y5_b SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y5_b.bit
puts "DONE_e4_y5_b"
TEOF
cat > e4_y5_1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y5_1.tcl <<'TEOF'
read_verilog ./e4_y5_1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y5 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y5_1 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y5_1.bit
puts "DONE_e4_y5_1"
TEOF
cat > e4_y6_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y6_b.tcl <<'TEOF'
read_verilog ./e4_y6_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y6 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y6_b SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y6_b.bit
puts "DONE_e4_y6_b"
TEOF
cat > e4_y6_1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y6_1.tcl <<'TEOF'
read_verilog ./e4_y6_1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y6 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y6_1 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y6_1.bit
puts "DONE_e4_y6_1"
TEOF
cat > e4_y7_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y7_b.tcl <<'TEOF'
read_verilog ./e4_y7_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y7 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y7_b SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y7_b.bit
puts "DONE_e4_y7_b"
TEOF
cat > e4_y7_1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y7_1.tcl <<'TEOF'
read_verilog ./e4_y7_1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y7 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y7_1 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y7_1.bit
puts "DONE_e4_y7_1"
TEOF
cat > e4_y4_3.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000003)) u_lut (.O(o),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e4_y4_3.tcl <<'TEOF'
read_verilog ./e4_y4_3.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
puts "CHK_e4_y4_3 SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] INIT=[get_property INIT [get_cells u_lut]] PART=[get_property PART [current_design]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e4_y4_3.bit
puts "DONE_e4_y4_3"
TEOF
cat > diff_e4.py <<'PYEOF'
# -*- coding: utf-8 -*-
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
PYEOF
runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1; if grep -q "DONE_$t" $t.log; then grep CHK_$t $t.log; echo "OK $t"; else echo "FAIL $t"; tail -n 5 $t.log; fi; }
export -f runone
for t in e4_y4_b e4_y4_1 e4_y5_b e4_y5_1 e4_y6_b e4_y6_1 e4_y7_b e4_y7_1 e4_y4_3; do echo $t; done | xargs -P 9 -I{} bash -c 'runone {}'
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e4.py . e4_y4_b:e4_y4_1,e4_y5_b:e4_y5_1,e4_y6_b:e4_y6_1,e4_y7_b:e4_y7_1,e4_y4_b:e4_y4_3 2>diff.err > diff.json
echo ERR_BEGIN; cat diff.err; echo ERR_END
echo E4DIFF_JSON_BEGIN
cat diff.json
echo E4DIFF_JSON_END
echo E4DONE
