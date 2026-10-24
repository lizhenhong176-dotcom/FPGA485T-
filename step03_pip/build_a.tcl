set part xc7vx485tffg1761-2
create_project -force pip1 ./prj -part $part
add_files ./top.v
add_files ./top.xdc
synth_design -top top -part $part
opt_design
place_design
route_design
write_checkpoint -force ./routed.dcp
set n [get_nets n1]
set fh [open ./pips_a.txt w]
foreach p [get_pips -of_objects $n] { puts $fh [get_property NAME $p] }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file ./a.bit
puts "BUILD_DONE"
