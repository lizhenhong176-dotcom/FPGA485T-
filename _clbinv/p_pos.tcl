read_verilog ./p_pos.v
synth_design -top top -part xc7vx485tffg1157-3
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL AFF [get_cells q_reg]
set_property LOC SLICE_X12Y20 [get_cells q_reg]
place_design
route_design
puts "CHK [get_property SITE [get_cells u_lut]] [get_property BEL [get_cells u_lut]] [get_property BEL [get_cells q_reg]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./p_pos.bit
puts "DONE_p_pos"
