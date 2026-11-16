#!/bin/bash
set -u
export LANG=C LC_ALL=C
W=/opt/lzh/v7re/work
rm -rf $W/rhalf && mkdir -p $W/rhalf && cd $W/rhalf
cat > top.v <<'VEOF'
module top(input clk, input [5:0] a, output q1, q2, q3, q4);
  (* DONT_TOUCH *) wire w1,w2,w3,w4;
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h1111111111111111)) L1 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w1));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h2222222222222222)) L2 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w2));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h3333333333333333)) L3 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w3));
  (* DONT_TOUCH *) LUT6 #(.INIT(64'h4444444444444444)) L4 (.I0(a[0]),.I1(a[1]),.I2(a[2]),.I3(a[3]),.I4(a[4]),.I5(a[5]),.O(w4));
  (* DONT_TOUCH *) FDRE F1(.Q(q1),.C(clk),.CE(1'b1),.R(1'b0),.D(w1));
  (* DONT_TOUCH *) FDRE F2(.Q(q2),.C(clk),.CE(1'b1),.R(1'b0),.D(w2));
  (* DONT_TOUCH *) FDRE F3(.Q(q3),.C(clk),.CE(1'b1),.R(1'b0),.D(w3));
  (* DONT_TOUCH *) FDRE F4(.Q(q4),.C(clk),.CE(1'b1),.R(1'b0),.D(w4));
endmodule

VEOF
cat > r1.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
opt_design
place_design
route_design
set fh [open r1.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r1.bit
puts DONE_r1
set_property LOC SLICE_X210Y12 [get_cells L1]
set_property LOC SLICE_X210Y60 [get_cells L2]
set_property LOC SLICE_X210Y110 [get_cells L3]
set_property LOC SLICE_X210Y160 [get_cells L4]
set_property BEL A6LUT [get_cells L1]
set_property BEL A6LUT [get_cells L2]
set_property BEL A6LUT [get_cells L3]
set_property BEL A6LUT [get_cells L4]
set_property LOC SLICE_X210Y12 [get_cells F1]
set_property LOC SLICE_X210Y60 [get_cells F2]
set_property LOC SLICE_X210Y110 [get_cells F3]
set_property LOC SLICE_X210Y160 [get_cells F4]
set_property BEL AFF [get_cells F1]
set_property BEL AFF [get_cells F2]
set_property BEL AFF [get_cells F3]
set_property BEL AFF [get_cells F4]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

TEOF
cat > r2.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
opt_design
place_design
route_design
set fh [open r2.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r2.bit
puts DONE_r2
set_property LOC SLICE_X218Y20 [get_cells L1]
set_property LOC SLICE_X218Y75 [get_cells L2]
set_property LOC SLICE_X218Y130 [get_cells L3]
set_property LOC SLICE_X218Y180 [get_cells L4]
set_property BEL A6LUT [get_cells L1]
set_property BEL A6LUT [get_cells L2]
set_property BEL A6LUT [get_cells L3]
set_property BEL A6LUT [get_cells L4]
set_property LOC SLICE_X218Y20 [get_cells F1]
set_property LOC SLICE_X218Y75 [get_cells F2]
set_property LOC SLICE_X218Y130 [get_cells F3]
set_property LOC SLICE_X218Y180 [get_cells F4]
set_property BEL AFF [get_cells F1]
set_property BEL AFF [get_cells F2]
set_property BEL AFF [get_cells F3]
set_property BEL AFF [get_cells F4]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

TEOF
cat > r3.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
opt_design
place_design
route_design
set fh [open r3.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r3.bit
puts DONE_r3
set_property LOC SLICE_X221Y30 [get_cells L1]
set_property LOC SLICE_X221Y90 [get_cells L2]
set_property LOC SLICE_X221Y140 [get_cells L3]
set_property LOC SLICE_X221Y200 [get_cells L4]
set_property BEL A6LUT [get_cells L1]
set_property BEL A6LUT [get_cells L2]
set_property BEL A6LUT [get_cells L3]
set_property BEL A6LUT [get_cells L4]
set_property LOC SLICE_X221Y30 [get_cells F1]
set_property LOC SLICE_X221Y90 [get_cells F2]
set_property LOC SLICE_X221Y140 [get_cells F3]
set_property LOC SLICE_X221Y200 [get_cells F4]
set_property BEL AFF [get_cells F1]
set_property BEL AFF [get_cells F2]
set_property BEL AFF [get_cells F3]
set_property BEL AFF [get_cells F4]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]

TEOF
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r1.tcl > r1.log 2>&1; echo rc_r1=$?
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r2.tcl > r2.log 2>&1; echo rc_r2=$?
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r3.tcl > r3.log 2>&1; echo rc_r3=$?
ls -l *.bit *.pips 2>&1 | tail -8
tar czf /tmp/rhalf.tgz *.bit *.pips && echo RHALFDONE && ls -l /tmp/rhalf.tgz
