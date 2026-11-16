export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/clk; cd $D || exit 1
mkdir -p $D/d2; printf '%s\n' 'module top(input clk, input clk2, input d, output q1, output q2);
  wire c1, c2;
  (* DONT_TOUCH = "true" *) BUFG b1 (.I(clk), .O(c1));
  (* DONT_TOUCH = "true" *) BUFG b2 (.I(clk2), .O(c2));
  (* DONT_TOUCH = "true" *) FDRE f1 (.Q(q1), .C(c1), .CE(1'"'"'b1), .R(1'"'"'b0), .D(d));
  (* DONT_TOUCH = "true" *) FDRE f2 (.Q(q2), .C(c2), .CE(1'"'"'b1), .R(1'"'"'b0), .D(d));
endmodule' > $D/d2/top.v
cat > $D/d2/d2.tcl <<'T'
read_verilog /opt/lzh/v7re/work/clk/d2/top.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y20 [get_cells f1]
set_property BEL AFF [get_cells f1]
set_property LOC SLICE_X48Y20 [get_cells f2]
set_property BEL AFF [get_cells f2]
opt_design
place_design
route_design
set fh [open /opt/lzh/v7re/work/clk/d2/top.pips w]
foreach n [get_nets -hier] { foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force /opt/lzh/v7re/work/clk/d2/top.bit
puts "OK d2"
T
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $D/d2/d2.tcl > $D/d2/build.log 2>&1
if grep -q "OK d2" $D/d2/build.log; then
  gzip -9 -c $D/d2/top.bit | base64 -w 0 > $D/d2/top.bit.b64
  echo "DONE d2 b64=$(stat -c %s $D/d2/top.bit.b64)"
  grep -E "GCLK_L_B|CLK_L[01]" $D/d2/top.pips
else echo FAIL; grep -m3 "^ERROR" $D/d2/build.log; fi