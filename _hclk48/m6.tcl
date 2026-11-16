read_verilog ./m6.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC MMCME2_ADV_X0Y6 [get_cells u_prim]
set_property LOC BUFHCE_X0Y72 [get_cells u_bufh]
set_property LOC SLICE_X0Y349 [get_cells u_ff]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
create_clock -name clk -period 10.000 [get_ports clk]
place_design
route_design
set fh [open m6.pips w]
foreach n [get_nets -hier] { foreach p [get_pips -of_objects $n] { puts $fh "$n [get_property NAME $p]" } }
close $fh
puts "CHK_SITE=[get_property SITE [get_cells u_prim]]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force ./m6.bit
puts "DONE_m6"
