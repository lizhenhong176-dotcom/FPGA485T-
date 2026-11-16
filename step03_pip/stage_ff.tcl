read_verilog /opt/lzh/step03/fftest/top_ff.v
synth_design -top top -part xc7vx485tffg1761-2
set_property DONT_TOUCH true [get_cells u_aff]
set_property DONT_TOUCH true [get_cells u_bff]
set_property DONT_TOUCH true [get_cells u_cff]
set_property DONT_TOUCH true [get_cells u_dff]
set_property LOC SLICE_X10Y10 [get_cells u_aff]
set_property BEL AFF [get_cells u_aff]
set_property LOC SLICE_X10Y10 [get_cells u_bff]
set_property BEL BFF [get_cells u_bff]
set_property LOC SLICE_X10Y10 [get_cells u_cff]
set_property BEL CFF [get_cells u_cff]
set_property LOC SLICE_X10Y10 [get_cells u_dff]
set_property BEL DFF [get_cells u_dff]
place_design
route_design
write_checkpoint -force /opt/lzh/step03/fftest/stage.dcp
puts "STAGE_DONE"
