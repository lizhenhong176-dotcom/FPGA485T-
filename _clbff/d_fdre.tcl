read_verilog ./d_fdre.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
set_property LOC SLICE_X12Y20 [get_cells u_ff]
set_property BEL AFF [get_cells u_ff]
set_property PACKAGE_PIN AF25 [get_ports o]
set_property PACKAGE_PIN AN33 [get_ports qo]
set_property PACKAGE_PIN AN34 [get_ports clk]
set_property PACKAGE_PIN AK34 [get_ports a]
set_property PACKAGE_PIN AL34 [get_ports b]
set_property PACKAGE_PIN AP32 [get_ports c]
set_property PACKAGE_PIN AP33 [get_ports rst]
set_property PACKAGE_PIN AK32 [get_ports ce]
set_property IOSTANDARD LVCMOS18 [get_ports {o qo clk a b c rst ce}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -quiet clk_IBUF]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force ./d_fdre.bit
puts "DONE_d_fdre"
