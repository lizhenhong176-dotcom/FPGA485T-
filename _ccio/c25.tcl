export LANG=C LC_ALL=C
read_verilog ./c25.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN P31 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier *clk*]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -hier i]
set_property LOC MMCME2_ADV_X0Y6 [get_cells u_mmcm]
set reg [get_clock_regions -of_objects [get_sites MMCME2_ADV_X0Y6]]
set bh [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "BUFHCE"}] 0]
set sl [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "SLICE"}] 0]
set_property LOC $bh [get_cells u_bh]
set_property LOC $sl [get_cells u_ff]
place_design
route_design
set fh [open ./c25.pips w]
foreach n [get_nets -hier] { foreach pi [get_pips -of_objects $n] { puts $fh $pi } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ./c25.bit
puts "DONE_c25"
