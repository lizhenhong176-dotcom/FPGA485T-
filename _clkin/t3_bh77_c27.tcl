read_verilog ./t3_bh77_c27.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN C27 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN AF25 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property LOC MMCME2_ADV_X0Y6 [get_cells u_mmcm]
set_property LOC BUFHCE_X0Y77 [get_cells u_bh]
set_property LOC SLICE_X0Y349 [get_cells u_ff]
place_design
route_design
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier clk2]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier ck]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
create_clock -period 10.000 [get_ports clk]
set fh [open t3_bh77_c27.pips w]
foreach pi [get_pips -of_objects [get_nets -hier -filter {NAME =~ "*"}]] { puts $fh $pi }
close $fh
write_bitstream -force ./t3_bh77_c27.bit
puts "DONE_t3_bh77_c27"
