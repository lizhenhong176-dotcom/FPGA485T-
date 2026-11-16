read_verilog -sv ./_mixed.sv
synth_design -top top -part xc7vx485tffg1157-3 -flatten_hierarchy none
set_property PACKAGE_PIN AF25 [get_ports a]
set_property IOSTANDARD LVCMOS18 [get_ports a]
set_property PACKAGE_PIN AN33 [get_ports q]
set_property IOSTANDARD LVCMOS18 [get_ports q]
set_property CFGBVS GND [current_design]
set_property CONFIG_VOLTAGE 1.8 [current_design]
create_clock -period 10.000 [get_ports clk]
set_property PACKAGE_PIN C27 [get_ports clk]
set_property IOSTANDARD LVCMOS18 [get_ports clk]
set dsp [lsort [get_sites -filter {SITE_TYPE == "DSP48E1"}]]
set br  [lsort [get_sites -filter {SITE_TYPE =~ "RAMB36*"}]]
puts "DSP_SITES=[llength $dsp] BRAM_SITES=[llength $br]"
set i 0
foreach c [get_cells -hier -filter {REF_NAME == "DSP48E1"}] {
  set n [expr {($i * 1000 / [llength $dsp])}]
  set_property LOC [lindex $dsp $n] $c
  incr i
}
set i 0
foreach c [get_cells -hier -filter {REF_NAME =~ "RAMB36*"}] {
  set n [expr {($i * 1000 / [llength $br])}]
  set_property LOC [lindex $br $n] $c
  incr i
}
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ./mixed.bit
puts "DONE_mixed"
