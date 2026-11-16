# T56: 从已 swap 过的 DCP 生成 bitstream（与 step03_pip/bit_any.tcl 同流程）。
# usage: vivado -mode batch -notrace -source t56_bit.tcl -tclargs <in.dcp> <out.bit>
set dcp [lindex $argv 0]
set bit [lindex $argv 1]
if {$dcp eq "" || $bit eq ""} { puts "USAGE_MISSING tclargs"; exit 1 }
open_checkpoint $dcp
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file $bit
puts "BIT_DONE $bit"
