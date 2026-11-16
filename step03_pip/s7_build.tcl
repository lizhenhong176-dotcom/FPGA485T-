set v [lindex $argv 0]
read_verilog s7_$v.v
read_xdc s7_$v.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force s7_$v.bit
