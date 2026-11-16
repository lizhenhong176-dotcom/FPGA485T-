read_verilog ./A6_X12Y21_z.v
synth_design -top top -part xc7vx485tffg1157-3
if {[get_property PART [current_design]] ne "xc7vx485tffg1157-3"} { error PART_MISMATCH }
set_property LOC SLICE_X12Y21 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]
place_design
route_design
set c [get_cells u0]
puts "CHK A6_X12Y21_z PART=[get_property PART [current_design]] SITE=[get_property SITE $c] BEL=[get_property BEL $c] INIT=[get_property INIT $c] LOCK=[get_property LOCK_PINS $c]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./A6_X12Y21_z.bit
puts "DONE_A6_X12Y21_z"
