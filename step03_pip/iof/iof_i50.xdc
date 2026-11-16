create_clock -name clk -period 10 [get_ports din] -add
set_property PACKAGE_PIN AF24 [get_ports din]
set_property IOSTANDARD LVCMOS18 [get_ports din]
set_property PACKAGE_PIN AY26 [get_ports p]
set_property IOSTANDARD LVCMOS18 [get_ports p]
