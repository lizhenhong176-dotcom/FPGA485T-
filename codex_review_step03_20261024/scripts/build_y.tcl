set Y [lindex $argv 0]
set YN [expr {$Y + 1}]
read_verilog top_y20.v
read_xdc top_y$Y.xdc
synth_design -top top -part xc7vx485tffg1761-2
opt_design
place_design
route_design
write_checkpoint -force routed_y$Y.dcp
write_edif -force top_y$Y.edf
puts "BUILD_DONE $Y"
