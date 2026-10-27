set SL   [lindex $argv 0]
set BEL  [lindex $argv 1]
set INIT [lindex $argv 2]
set TAG  [lindex $argv 3]
read_verilog top_y20.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property LOC $SL [get_cells lut_b]
set_property BEL $BEL [get_cells lut_b]
set_property INIT $INIT [get_cells lut_b]
set_property LOCK_PINS "I0:A1" [get_cells lut_a]
set_property LOCK_PINS "I0:A1" [get_cells lut_b]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force $TAG.bit
puts "S3_DONE $TAG"
