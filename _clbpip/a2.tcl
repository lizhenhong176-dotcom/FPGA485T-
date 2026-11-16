read_verilog ./a2.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A2} [get_cells u_lut]
place_design
route_design
puts "CHK_SITE=[get_property SITE [get_cells u_lut]] BEL=[get_property BEL [get_cells u_lut]] LOCK=[get_property LOCK_PINS [get_cells u_lut]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./a2.bit
puts "DONE_a2"
