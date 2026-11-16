read_verilog ./u1_mmcm2mmcm.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN C27 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN AF25 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property LOC MMCME2_ADV_X0Y6 [get_cells u_a]
set_property LOC MMCME2_ADV_X1Y6 [get_cells u_b]
set regB [get_clock_regions -of_objects [get_sites MMCME2_ADV_X1Y6]]
set ff_site [lindex [get_sites -of_objects $regB -filter {SITE_TYPE == "SLICE"}] 0]
set_property LOC $ff_site [get_cells u_ff]
puts "CHK_FF=$ff_site"
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier ck_a]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier ck_p]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier ck_q]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
create_clock -period 10.000 [get_ports clk]
set fh [open u1_mmcm2mmcm.pips w]
foreach pi [get_pips -of_objects [get_nets -hier -filter {NAME =~ "*"}]] { puts $fh $pi }
close $fh
write_bitstream -force ./u1_mmcm2mmcm.bit
puts "DONE_u1_mmcm2mmcm"
