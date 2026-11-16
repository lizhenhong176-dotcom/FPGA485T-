set v [lindex $argv 0]
read_verilog /opt/lzh/step03/s11/s11_$v.v
read_xdc /opt/lzh/step03/s11/s11_$v.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set cells [get_cells -hierarchical -filter {IS_PRIMITIVE && NAME !~ "*/*" && (REF_NAME =~ RAM* || REF_NAME =~ LUT* || REF_NAME =~ SRL* || REF_NAME =~ FD* || REF_NAME =~ MUXF* || REF_NAME =~ LD* || REF_NAME =~ CARRY*)}]
puts "CELLS: [get_property NAME $cells]"
set_property LOC SLICE_X10Y20 $cells
place_design
route_design
set_property SEVERITY Warning [get_drc_checks NSTD-1]
set_property SEVERITY Warning [get_drc_checks UCIO-1]
write_bitstream -force /opt/lzh/step03/s11/s11_$v.bit
