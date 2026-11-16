read_verilog ./e0.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN AF25 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN AN33 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier *]
set_property LOC MMCME2_ADV_X0Y6 [get_cells u_mmcm]
set_property LOC BUFHCE_X0Y72 [get_cells u_bh]
place_design
route_design
set fh [open ./e0.pips w]
foreach n [get_nets -hier] { foreach pi [get_pips -of_objects $n] { puts $fh $pi } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ./e0.bit
puts "DONE_e0"
