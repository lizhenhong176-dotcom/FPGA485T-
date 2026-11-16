read_verilog ./d1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN AF25 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN AN33 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier *clk*]
set soc [lindex [get_sites -filter {SITE_TYPE =~ "*BUFH*"}] 0]
set_property LOC $soc [get_cells u_bh]
puts "CHK_BH=$soc"
place_design
route_design
set fh [open ./d1.pips w]
foreach n [get_nets -hier] { foreach pi [get_pips -of_objects $n] { puts $fh $pi } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ./d1.bit
puts "DONE_d1"
