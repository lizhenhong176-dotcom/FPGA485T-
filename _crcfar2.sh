#!/bin/bash
export LANG=C LC_ALL=C
mkdir -p /opt/lzh/v7re/work/crcfar && cd /opt/lzh/v7re/work/crcfar || exit 1
cat > f0.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000000)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule

VEOF
cat > f0.tcl <<'TEOF'
read_verilog ./f0.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y200 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./f0.bit
puts "DONE_f0"

TEOF
cat > f1.v <<'VEOF'
module top(input a0,a1,a2,a3,a4,a5, output o);
  (* DONT_TOUCH = "true" *) LUT6 #(.INIT(64'h0000000000000001)) u0 (.O(o), .I0(a0),.I1(a1),.I2(a2),.I3(a3),.I4(a4),.I5(a5));
endmodule

VEOF
cat > f1.tcl <<'TEOF'
read_verilog ./f1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y200 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./f1.bit
puts "DONE_f1"

TEOF
for t in f0 f1; do
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source $t.tcl > $t.log 2>&1
  if grep -q "DONE_$t" $t.log; then echo "OK $t"; else echo "FAIL $t"; tail -n 4 $t.log; fi
done
tar czf /tmp/crcfar.tgz *.bit 2>/dev/null && echo TARDONE
