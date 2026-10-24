read_verilog /data/lzh/v7re/work/liccheck/top.v
synth_design -top top -part xc7vx485tffg1761-2
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force /data/lzh/v7re/work/liccheck/top.bit
puts "BITSTREAM_OK"
