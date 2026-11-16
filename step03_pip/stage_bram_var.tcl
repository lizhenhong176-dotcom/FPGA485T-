create_project -in_memory -part xc7vx485tffg1761-2
set_property target_language Verilog [current_project]
read_verilog top_bram_VAR.v
synth_design -top top -flatten_hierarchy none
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property IS_ENABLED false [get_drc_checks {NSTD-1 UCIO-1}]
set_property SEVERITY {Warning} [get_drc_checks {NSTD-1 UCIO-1}]
place_design
route_design
set_property LOC RAMB18_X10Y0 [get_cells u_bram]
write_bitstream -force var_init1.bit
