export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clk; mkdir -p $D/b1; cd $D/b1 || exit 1
cat > top.v <<'V'
module top(input clk, input a0,a1,a2,a3,a4,a5, output o);
  wire f;
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) la (.O(f), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
  (* DONT_TOUCH = "true" *) FDRE ff (.Q(q), .C(clk), .CE(1'b1), .R(1'b0), .D(f));
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h8000000000000000)) lb (.O(o), .I0(q),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule
V
cat > b.tcl <<'T'
read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y20 [get_cells la]
set_property BEL A6LUT [get_cells la]
set_property LOC SLICE_X12Y20 [get_cells ff]
set_property BEL AFF [get_cells ff]
set_property LOC SLICE_X13Y20 [get_cells lb]
set_property BEL A6LUT [get_cells lb]
opt_design
place_design
route_design
set fh [open top.pips w]
foreach n [get_nets -hier] { foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./top.bit
puts "B1_OK"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source b.tcl > b.log 2>&1
grep -q B1_OK b.log && echo OK || { echo FAIL; tail -20 b.log; }
grep -E "BYP|FAN" top.pips | head
gzip -9 -c top.bit | base64 -w 0 > top.bit.b64
echo "b64=$(stat -c %s top.bit.b64)"