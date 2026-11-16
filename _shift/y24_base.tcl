read_verilog ./y24_base.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y24 [get_cells u_l]
set_property BEL A6LUT [get_cells u_l]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./y24_base.bit
puts "DONE_y24_base"
