#!/bin/bash
export LANG=C LC_ALL=C
cd /opt/lzh/v7re/work/rhalf
cat > r1.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
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
opt_design
place_design
route_design
set fh [open r1.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r1.bit
puts DONE_r1

TEOF
cat > r2.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
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
opt_design
place_design
route_design
set fh [open r2.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r2.bit
puts DONE_r2

TEOF
cat > r3.tcl <<'TEOF'
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog top.v
synth_design -top top -part xc7vx485tffg1157-3
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
opt_design
place_design
route_design
set fh [open r3.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] { puts $fh $pi }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force r3.bit
puts DONE_r3

TEOF
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r1.tcl > r1.log 2>&1; echo rc_r1=$?
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r2.tcl > r2.log 2>&1; echo rc_r2=$?
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -source r3.tcl > r3.log 2>&1; echo rc_r3=$?
grep -h '^set_property \|Placed' *.log | head -3
ls -l *.bit *.pips | tail -6
tar czf /tmp/rhalf.tgz *.bit *.pips && echo RHALFDONE
