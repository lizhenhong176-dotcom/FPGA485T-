set part xc7vx485tffg1761-2
create_project -force tamper_ref ./prj -part $part
add_files ./top.v
add_files ./top.xdc
synth_design -top top -part $part
opt_design
place_design
route_design
write_checkpoint -force ./routed.dcp

# ---- ground truth: every routed PIP of the whole design ----
set fh [open ./pips_all.txt w]
set np 0
foreach n [get_nets -hier -quiet] {
  foreach p [get_pips -of_objects $n -quiet] {
    puts $fh "[get_property NAME $p]"
    incr np
  }
}
close $fh
puts "PIPS_DUMPED=$np"

# ---- ground truth: LUT INIT words and placements ----
set fh [open ./cells.txt w]
foreach c [get_cells -hier -filter {REF_NAME =~ LUT6*}] {
  puts $fh "[get_property NAME $c] [get_property INIT $c] [get_property LOC $c] [get_property BEL $c]"
}
close $fh

set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file ./ref.bit
puts "BUILD_DONE"
