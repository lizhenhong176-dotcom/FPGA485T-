set PIN [lindex $argv 0]
set SL  [lindex $argv 1]
set BEL [lindex $argv 2]
set TAG [lindex $argv 3]
read_verilog top_y20.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property LOC $SL [get_cells lut_b]
set_property BEL $BEL [get_cells lut_b]
set_property LOCK_PINS "I0:$PIN" [get_cells lut_a]
set_property LOCK_PINS "I0:$PIN" [get_cells lut_b]
place_design
route_design
write_checkpoint -force $TAG.dcp
write_edif -force $TAG.edf
puts "BEL_DONE $TAG"
