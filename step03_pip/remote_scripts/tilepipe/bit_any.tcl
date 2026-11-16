set DCP [lindex $argv 0]
set BIT [lindex $argv 1]
open_checkpoint $DCP
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file $BIT
puts "BIT_DONE"
