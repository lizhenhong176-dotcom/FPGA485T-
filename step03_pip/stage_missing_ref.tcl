create_project -in_memory -part xc7vx485tffg1761-2
set_property target_language Verilog [current_project]
read_verilog top_missing_REF.v
synth_design -top top -flatten_hierarchy none
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property IS_ENABLED false [get_drc_checks {NSTD-1 UCIO-1}]
set_property SEVERITY {Warning} [get_drc_checks {NSTD-1 UCIO-1}]
set_property LOC SLICE_X14Y11 [get_cells lut_a]
set_property LOC SLICE_X14Y11 [get_cells lut_b]
set_property BEL A6LUT [get_cells lut_a]
set_property BEL B6LUT [get_cells lut_b]
place_design
route_design
write_bitstream -force ref.bit
