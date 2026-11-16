read_verilog n3.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC RAMB36_X3Y21 [get_cells u_bram]
place_design
route_design
set fh [open n3.pips w]
foreach nt [get_nets -hier] { foreach p [get_pips -of_objects $nt] { puts $fh "$nt [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force n3.bit
puts "DONE_n3"
