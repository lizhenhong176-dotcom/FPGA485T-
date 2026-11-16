read_verilog ./top.v
synth_design -top top -part xc7vx485tffg1157-3
set all [get_sites -filter {SITE_TYPE =~ "SLICEL*" || SITE_TYPE =~ "SLICEM*"}]
set n [llength $all]
set stride [expr {$n / 840}]
puts "SITES=$n STRIDE=$stride"
for {set i 0} {$i < 800} {incr i} {
  set s [lindex $all [expr {$i * $stride}]]
  set c [get_cells u[format %04d $i]]
  set_property LOC $s $c
  set_property BEL A6LUT $c
}
place_design
route_design
write_checkpoint -force cov2.dcp
set fh [open cov2.pips w]
foreach nn [get_nets -hier] { foreach p [get_pips -of_objects $nn] { puts $fh "$nn [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force cov2.bit
puts "COV2_DONE"
