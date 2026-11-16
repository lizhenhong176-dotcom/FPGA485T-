read_verilog probe.v
synth_design -top top -part xc7vx485tffg1157-3
set fh [open probe_ports.txt w]
foreach p [get_pins -of_objects [get_cells u_bram]] { puts $fh [get_property NAME $p] }
close $fh
puts "PROBEDONE"