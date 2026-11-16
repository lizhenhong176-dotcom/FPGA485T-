export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/slicem_rows || exit 1
cat > vr3.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'ha5a5f0f01234abcd)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > vr3.tcl <<'T'
read_verilog ./vr3.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X2Y3 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./vr3.bit
puts "DONE_vr3"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source vr3.tcl > vr3.log 2>&1
grep -q DONE_vr3 vr3.log && gzip -9 -c vr3.bit | base64 -w 0 > vr3.bit.b64 && echo OK || { echo FAIL; tail -6 vr3.log; }