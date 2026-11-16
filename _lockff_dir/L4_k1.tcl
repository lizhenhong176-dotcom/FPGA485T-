read_verilog ./L4_k1.v
synth_design -top top -part xc7vx485tffg1761-2
set_property LOC SLICE_X12Y4 [get_cells u_lut]
set_property BEL A6LUT [get_cells u_lut]
set_property LOCK_PINS {I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6} [get_cells u_lut]
place_design
route_design
proc chk {tag} {
  foreach x [get_cells -hier -filter {NAME =~ *lut* || NAME =~ *ff*}] {
    puts "CHK $tag [get_property NAME $x] SITE=[get_property SITE $x] BEL=[get_property BEL $x] INIT=[get_property INIT $x]"
  }
}
chk L4_k1
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./L4_k1.bit
puts "DONE_L4_k1"
