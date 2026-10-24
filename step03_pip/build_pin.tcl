set PIN [lindex $argv 0]
read_verilog top_y20.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X8Y10 [get_cells lut_a]
set_property LOC SLICE_X8Y11 [get_cells lut_b]
set_property LOCK_PINS "I0:$PIN" [get_cells lut_a]
set_property LOCK_PINS "I0:$PIN" [get_cells lut_b]
place_design
route_design
write_checkpoint -force p_$PIN.dcp
write_edif -force p_$PIN.edf
puts "BUILD_PIN_DONE $PIN"
