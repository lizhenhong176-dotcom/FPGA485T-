read_verilog ./v2_dcout.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_c4]
set_property BEL CARRY4 [get_cells u_c4]
place_design
route_design
puts "CHK [get_property SITE [get_cells -quiet u_lut]] [get_property SITE [get_cells -quiet u_c4]] [get_property SITE [get_cells -quiet q]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./v2_dcout.bit
set fh [open ./v2_dcout.pips w]
foreach pi [get_pips -of_objects [get_tiles -of_objects [get_nets -hier]]] { puts $fh $pi }
close $fh
puts "DONE_v2_dcout"
