read_verilog ./_sw1.v
synth_design -top top -part xc7vx485tffg1157-3
set_property PACKAGE_PIN AF25 [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports a]
set_property PACKAGE_PIN AN33 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property LOC SLICE_X12Y20 [get_cells u0]
set_property BEL A6LUT [get_cells u0]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u0]

place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set fh [open _sw1.pips w]
foreach pi [get_pips -of_objects [get_nets -hier -filter {NAME =~ "*"}]] { puts $fh $pi }
close $fh
write_bitstream -force ./_sw1.bit
puts "DONE__sw1"
