export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/ysweep2; mkdir -p $D; cd $D || exit 1
cat > mk.tcl <<'T'
read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y17 [get_cells la]
set_property BEL A6LUT [get_cells la]
set_property LOC SLICE_X9Y17 [get_cells lb]
set_property BEL A6LUT [get_cells lb]
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./top.bit
puts "OK2"
T
cat > top.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output b);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) la (.O(x), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lb (.O(b), .I0(x),.I1(1'b0),.I2(1'b0),.I3(1'b0),.I4(1'b0),.I5(1'b0));
endmodule
V
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source mk.tcl > b.log 2>&1
grep -q OK2 b.log && echo "BUILD_OK $(stat -c %s top.bit)" || { echo FAIL; tail -20 b.log; }
/opt/lzh/venv/bin/python - <<'PY'
import sys, numpy as np
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
base = np.array(frames_from_bit("/opt/lzh/v7re/work/ysweep/base/top.bit"), dtype=np.uint32)
a = np.array(frames_from_bit("top.bit"), dtype=np.uint32)
d = np.argwhere(a != base)
print("总差异格:", len(d))
for f, w in d:
    diff = int(a[f][w]) ^ int(base[f][w])
    if w in (34, 35):
        print("  frame %d word %d diff=0x%08x ecc(base)=0x%x ecc(a)=0x%x"
              % (f, w, diff, int(base[f][50]), int(a[f][50])))
PY