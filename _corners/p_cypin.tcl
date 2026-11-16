read_verilog ./p_cypin.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC SLICE_X12Y20 [get_cells u_cy]
set_property PACKAGE_PIN AF25 [get_ports {o}]
set_property IOSTANDARD LVCMOS18 [get_ports {o}]
set_property PACKAGE_PIN AK34 [get_ports {a}]
set_property IOSTANDARD LVCMOS18 [get_ports {a}]
set_property PACKAGE_PIN AL34 [get_ports {b}]
set_property IOSTANDARD LVCMOS18 [get_ports {b}]
set_property PACKAGE_PIN AP32 [get_ports {c}]
set_property IOSTANDARD LVCMOS18 [get_ports {c}]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
write_bitstream -force ./p_cypin.bit
puts "DONE_p_cypin"
