read_verilog top_dsp_REF.v
synth_design -part xc7vx485tffg1761-2 -top top
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property LOC DSP48_X13Y0 [get_cells u_dsp]
set_property DONT_TOUCH true [get_cells u_dsp]
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream -force ref.bit
