read_verilog ./B6_X12Y20_z.v
synth_design -top top -part xc7vx485tffg1157-3
if {[get_property PART [current_design]] ne "xc7vx485tffg1157-3"} { error PART_MISMATCH }
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL B6LUT [get_cells u0]
set_property LOCK_PINS {I0:B1 I1:B2 I2:B3 I3:B4 I4:B5 I5:B6} [get_cells u0]
place_design
route_design
set c [get_cells u0]
puts "CHK B6_X12Y20_z PART=[get_property PART [current_design]] SITE=[get_property SITE $c] BEL=[get_property BEL $c] INIT=[get_property INIT $c] LOCK=[get_property LOCK_PINS $c]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./B6_X12Y20_z.bit
puts "DONE_B6_X12Y20_z"
