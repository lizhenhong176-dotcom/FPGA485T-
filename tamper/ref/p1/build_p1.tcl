set part xc7vx485tffg1761-2
puts "==== BUILD d1_lut_chain"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d1_lut_chain.v
read_xdc d1_lut_chain.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d1_lut_chain.bit
set fp [open out/d1_lut_chain.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d1_lut_chain"
puts "==== BUILD d2_lut_big"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d2_lut_big.v
read_xdc d2_lut_big.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d2_lut_big.bit
set fp [open out/d2_lut_big.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d2_lut_big"
puts "==== BUILD d3_carry"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d3_carry.v
read_xdc d3_carry.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d3_carry.bit
set fp [open out/d3_carry.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d3_carry"
puts "==== BUILD d4_fanout"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d4_fanout.v
read_xdc d4_fanout.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d4_fanout.bit
set fp [open out/d4_fanout.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d4_fanout"
puts "==== BUILD d5_srl"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d5_srl.v
read_xdc d5_srl.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d5_srl.bit
set fp [open out/d5_srl.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d5_srl"
puts "==== BUILD d6_muxtree"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d6_muxtree.v
read_xdc d6_muxtree.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d6_muxtree.bit
set fp [open out/d6_muxtree.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d6_muxtree"
puts "==== BUILD d7_spread"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d7_spread.v
read_xdc d7_spread.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d7_spread.bit
set fp [open out/d7_spread.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d7_spread"
puts "==== BUILD d8_dense"
catch {close_project} ; catch {remove_files [get_files]}
read_verilog d8_dense.v
read_xdc d8_dense.xdc
synth_design -top top -part xc7vx485tffg1761-2 -flatten_hierarchy none
opt_design
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force out/d8_dense.bit
set fp [open out/d8_dense.pips w]; puts $fp [join [get_pips -of_objects [get_nets -hier]] "\n"]; close $fp
puts "BUILD_OK d8_dense"
puts ALL_DONE
