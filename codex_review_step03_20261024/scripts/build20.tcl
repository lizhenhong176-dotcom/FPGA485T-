read_verilog top_y20.v
read_xdc top_y20.xdc
synth_design -top top -part xc7vx485tffg1761-2
opt_design
place_design
route_design
write_checkpoint -force routed20.dcp
write_edif -force top20.edf
write_bitstream -force -bin_file a20.bit
puts "BUILD20_DONE"
