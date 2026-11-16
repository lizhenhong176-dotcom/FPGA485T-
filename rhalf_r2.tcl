set_part xc7vx485tffg1157-3
create_project -in_memory -part xc7vx485tffg1157-3
read_verilog /opt/lzh/v7re/work/rhalf/top.v
synth_design -top top -part xc7vx485tffg1157-3
opt_design
place_design
route_design
write_checkpoint -force /opt/lzh/v7re/work/rhalf/r2.dcp
set fh [open /opt/lzh/v7re/work/rhalf/r2.pips w]
foreach pi [get_pips -of_objects [get_nets -hierarchical]] {{ puts $fh $pi }}
close $fh
set_property BITSTREAM.GENERAL.COMPRESS FALSE [current_design]
write_bitstream -force /opt/lzh/v7re/work/rhalf/r2.bit
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
