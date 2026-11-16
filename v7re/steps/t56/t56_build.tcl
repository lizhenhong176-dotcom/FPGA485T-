# T56 build script: T1 的 PIP 设计搬到 INT_L_X6Y61 / SLICE_X8Y60,61。
# usage: vivado -mode batch -notrace -source t56_build.tcl -tclargs <tag> <part>
set tag  [lindex $argv 0]
set part [lindex $argv 1]
if {$tag eq "" || $part eq ""} { puts "USAGE_MISSING tclargs"; exit 1 }

set part_expect "xc7vx485tffg1761-2"
if {$part ne $part_expect} { puts "PART_ARG_MISMATCH $part != $part_expect"; exit 1 }

set dir ./$tag
file mkdir $dir
create_project -force $tag $dir/prj -part $part
add_files ./t56_top.v
add_files ./t56_top.xdc
synth_design -top top -part $part
opt_design
place_design
route_design

set actual [get_property PART [current_design]]
puts "PART_OK $actual"
if {$actual ne $part_expect} { puts "PART_READBACK_MISMATCH $actual"; exit 1 }

write_edif -force $dir/top.edf
write_checkpoint -force $dir/routed.dcp

set n [get_nets n1]
set fh [open $dir/pips_$tag.txt w]
foreach p [get_pips -of_objects $n] { puts $fh [get_property NAME $p] }
close $fh

set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file $dir/$tag.bit
puts "BUILD_DONE $tag"
