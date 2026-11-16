# CARRY4 experiment: synth → LOC → place → route → DRC bypass → write_bitstream
# Usage: vivado -mode batch -notrace -source stage_carry.tcl -tclargs <verilog> <outdir> <bitname>

set verilog [lindex $argv 0]
set outdir  [lindex $argv 1]
set bitname [lindex $argv 2]

file mkdir $outdir
cd $outdir

read_verilog /opt/lzh/step03/carrytest/$verilog
synth_design -top top -flatten_hierarchy none

set_property LOC SLICE_X10Y10 [get_cells u_carry]
place_design
route_design

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

write_bitstream -force $bitname
puts "BITSTREAM_DONE: $bitname"
exit
