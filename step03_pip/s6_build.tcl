set v [lindex $argv 0]
read_verilog s5_$v.v
synth_design -top top -part xc7vx485t -flatten_hierarchy none
foreach c [get_cells -hierarchical -filter {REF_NAME == LUT6 || REF_NAME == MUXF7 || REF_NAME == MUXF8}] {
  set_property LOC SLICE_X10Y20 $c
}
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force s5_$v.bit
