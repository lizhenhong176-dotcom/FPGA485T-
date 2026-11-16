read_verilog ./VTAG.v
synth_design -top top -part xc7vx485tffg1157-3
if {[get_property PART [current_design]] ne "xc7vx485tffg1157-3"} { error PART_MISMATCH }
set_property LOC LOCTAG [get_cells u0]
set_property BEL BELTAG [get_cells u0]
set_property LOCK_PINS {LOCKTAG} [get_cells u0]
place_design
route_design
set c [get_cells u0]
puts "CHK BTAG PART=[get_property PART [current_design]] SITE=[get_property SITE $c] BEL=[get_property BEL $c] INIT=[get_property INIT $c] LOCK=[get_property LOCK_PINS $c]"
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force ./BTAG.bit
puts "DONE_BTAG"
