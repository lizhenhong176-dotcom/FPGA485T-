export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/trans
mkdir -p $D; cd $D || exit 1
cat > t1.v <<'V'
module top(input a0,a1,a2,a3,a4,a5, output o0,o1,o2,o3);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hdeadbeefcafebabe)) u0 (.O(o0), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0123456789abcdef)) u1 (.O(o1), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h00000000ffffffff)) u2 (.O(o2), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'hffffffff00000000)) u3 (.O(o3), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > t1.tcl <<'T'
read_verilog ./t1.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X2Y8 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOC SLICE_X2Y8 [get_cells u1]
set_property BEL B6LUT [get_cells u1]
set_property LOC SLICE_X3Y8 [get_cells u2]
set_property BEL A6LUT [get_cells u2]
set_property LOC SLICE_X3Y8 [get_cells u3]
set_property BEL B6LUT [get_cells u3]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./t1.bit
puts "DONE_t1"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source t1.tcl > t1.log 2>&1
grep -q DONE_t1 t1.log && gzip -9 -c t1.bit | base64 -w 0 > t1.bit.b64 && echo "OK $(stat -c %s t1.bit.b64)" || { echo FAIL; tail -8 t1.log; }