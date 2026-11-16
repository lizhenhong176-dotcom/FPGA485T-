open_checkpoint /opt/lzh/step03/lutmap/stage.dcp
puts "count=[llength [get_drc_checks NSTD-1]]"
if {[catch {set_property SEVERITY Warning [get_drc_checks NSTD-1]} e]} { puts "ERR1 $e" }
puts "sev=[get_property SEVERITY [get_drc_checks NSTD-1]]"
if {[catch {set_property IS_ENABLED false [get_drc_checks PDCN-1569]} e]} { puts "ERR2 $e" }
puts "done"
