read_verilog m01.v
synth_design -top top -part xc7vx485tffg1157-3
set_property LOC MMCME2_ADV_X1Y6 [get_cells u_cmt]
set reg [get_clock_regions -of_objects [get_sites MMCME2_ADV_X1Y6]]
set bh [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "BUFHCE"}] 0]
set sl [lindex [get_sites -of_objects $reg -filter {SITE_TYPE == "SLICE"}] 0]
set_property LOC $bh [get_cells u_bh]
set_property LOC $sl [get_cells u_ff]
create_clock -period 10.000 [get_ports clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets c]
place_design
route_design
set fh [open m01.pips w]
foreach nt [get_nets -hier] { foreach p [get_pips -of_objects $nt] { puts $fh "$nt [get_property NAME $p]" } }
close $fh
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force m01.bit
puts "DONE_m01"
