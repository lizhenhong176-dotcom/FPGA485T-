read_verilog r1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC RAMB18_X3Y42 [get_cells u_lo]
place_design
route_design
set fh [open r1.pips w]
foreach nt [get_nets -hier] { foreach p [get_pips -of_objects $nt] { puts $fh "$nt [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force r1.bit
puts "DONE_r1"
