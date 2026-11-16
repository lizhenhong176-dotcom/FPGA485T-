set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e7; rm -rf $D; mkdir -p $D; cd $D || exit 1
cat > e7_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e7_b.tcl <<'TEOF'
read_verilog ./e7_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y54 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X20Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
place_design
route_design
puts "CHK_e7_b PART=[get_property PART [current_design]]"
puts "SITE_e7_b_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e7_b_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e7_b_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e7_b.bit
puts "DONE_e7_b"
TEOF
cat > e7_a.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e7_a.tcl <<'TEOF'
read_verilog ./e7_a.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y54 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X20Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
place_design
route_design
puts "CHK_e7_a PART=[get_property PART [current_design]]"
puts "SITE_e7_a_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e7_a_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e7_a_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e7_a.bit
puts "DONE_e7_a"
TEOF
cat > e7_b.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e7_b.tcl <<'TEOF'
read_verilog ./e7_b.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y54 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X20Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
place_design
route_design
puts "CHK_e7_b PART=[get_property PART [current_design]]"
puts "SITE_e7_b_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e7_b_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e7_b_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e7_b.bit
puts "DONE_e7_b"
TEOF
cat > e7_c.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF
cat > e7_c.tcl <<'TEOF'
read_verilog ./e7_c.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y4 [get_cells u_lut0]
set_property BEL A6LUT [get_cells u_lut0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut0]
set_property LOC SLICE_X12Y54 [get_cells u_lut1]
set_property BEL A6LUT [get_cells u_lut1]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut1]
set_property LOC SLICE_X20Y4 [get_cells u_lut2]
set_property BEL A6LUT [get_cells u_lut2]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut2]
place_design
route_design
puts "CHK_e7_c PART=[get_property PART [current_design]]"
puts "SITE_e7_c_0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE_e7_c_1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE_e7_c_2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e7_c.bit
puts "DONE_e7_c"
TEOF
cat > diff_e7.py <<'PYEOF'
# -*- coding: utf-8 -*-
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
PYEOF
runone() { t=$1; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1; if grep -q "DONE_$t" $t.log; then echo "OK $t"; grep -h SITE_ $t.log; else echo "FAIL $t"; tail -n 5 $t.log; fi; }
export -f runone
for t in e7_b e7_a e7_b e7_c; do echo $t; done | xargs -P 4 -I{} bash -c 'runone {}'
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY diff_e7.py . 'e7_a,e7_b,e7_c'
echo E7JSON_BEGIN
$PY diff_e7.py . 'e7_a,e7_b,e7_c'
echo E7JSON_END
echo E7DONE
