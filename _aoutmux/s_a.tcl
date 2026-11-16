read_verilog ./s_a.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
set_property PACKAGE_PIN AF25 [get_ports o]
set_property IOSTANDARD LVCMOS18 [get_ports o]
set_property PACKAGE_PIN AN33 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set_property PACKAGE_PIN AN34 [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports a]
set_property PACKAGE_PIN AK34 [get_ports b]
set_property IOSTANDARD LVCMOS18 [get_ports b]
set_property PACKAGE_PIN AJ34 [get_ports c]
set_property IOSTANDARD LVCMOS18 [get_ports c]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -quiet clk_IBUF]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force ./s_a.bit
set fh [open ./s_a.pips w]
foreach pi [get_pips -of_objects [get_nets -hier]] { puts $fh $pi }
close $fh
puts "DONE_s_a"
