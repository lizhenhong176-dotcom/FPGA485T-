set part xc7vx485tffg1761-2
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d8b_dense.v
read_xdc d8b_dense.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d8b_dense.bit
set fp [open out/d8b_dense.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d8b_dense"
