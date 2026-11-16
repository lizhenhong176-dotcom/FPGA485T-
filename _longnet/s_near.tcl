read_verilog ./s_near.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN AF25 [get_ports o]
set_property IOSTANDARD LVCMOS18 [get_ports o]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ./s_near.bit
puts "DONE_s_near"
