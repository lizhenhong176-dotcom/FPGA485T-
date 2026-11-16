open_checkpoint /opt/lzh/step03/fftest/stage.dcp
set init_val [lindex $argv 0]
set ff_name [lindex $argv 1]
set_property INIT ${init_val} [get_cells ${ff_name}]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force /opt/lzh/step03/fftest/v_${ff_name}_${init_val}.bit
puts "VAR_DONE ${ff_name} ${init_val}"
