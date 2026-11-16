set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx_Vivado_license_2037.lic
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e7
cd $D || exit 1

cat > e7_true.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut0 (.O(o0),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut1 (.O(o1),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u_lut2 (.O(o2),
      .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
VEOF

cat > e7_true.tcl <<'TEOF'
read_verilog ./e7_true.v
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
puts "CHK_e7_true PART=[get_property PART [current_design]]"
puts "SITE0 [get_property SITE [get_cells u_lut0]] INIT=[get_property INIT [get_cells u_lut0]]"
puts "SITE1 [get_property SITE [get_cells u_lut1]] INIT=[get_property INIT [get_cells u_lut1]]"
puts "SITE2 [get_property SITE [get_cells u_lut2]] INIT=[get_property INIT [get_cells u_lut2]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./e7_true.bit
puts "DONE_e7_true"
TEOF

/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source e7_true.tcl > e7_true.log 2>&1
if grep -q DONE_e7_true e7_true.log; then echo "OK e7_true"; grep -h SITE e7_true.log; else echo "FAIL e7_true"; tail -n 8 e7_true.log; fi

cat > diff_probe.py <<'PYEOF'
import json, struct, sys
SYNC = b"\xaa\x99\x55\x66"; FW = 101
def fdraws(path):
    raw = open(path, "rb").read(); i = raw.find(SYNC)
    n = (len(raw) - i - 4) // 4
    w = struct.unpack(">%dI" % n, raw[i+4:i+4+n*4]); out = []; k = 0
    while k < n:
        h = w[k]; typ = (h >> 29) & 7; op = (h >> 27) & 3; cnt = h & 0x7FF; k += 1
        if typ == 2:
            c = h & 0x7FFFFFF; out.extend(w[k:k+c]); k += c; continue
        if typ != 1: continue
        if op == 2 and cnt: k += cnt
        elif op == 1: k += 1
    return out
base = sys.argv[1]
a = fdraws(base + ".bit")
res = {}
for t in sys.argv[2:]:
    b = fdraws(t + ".bit"); content = []; ecc = {}
    for idx in range(min(len(a), len(b))):
        if a[idx] == b[idx]: continue
        fr, wd = idx // FW, idx % FW
        if wd == 50: ecc[fr] = [a[idx], b[idx]]
        else:
            x = a[idx] ^ b[idx]
            for bit in range(32):
                if (x >> bit) & 1: content.append([fr, wd, bit])
    res[t] = {"content": content, "ecc": {str(k): v for k, v in ecc.items()}}
print(json.dumps({"base": base, "base_words": len(a), "items": res}))
PYEOF

PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
echo E7FIXJSON_BEGIN
$PY diff_probe.py e7_true e7_a e7_c
echo E7FIXJSON_END
echo E7FIXDONE
