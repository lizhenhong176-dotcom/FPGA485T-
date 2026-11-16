create_project -in_mem -part xc7vx485tffg1761-2
add_files top_clkinv.v
synth_design -top top -mode out_of_context

set_property DONT_TOUCH 1 [get_cells u_*]

# Place 4 FFs in SLICE_X10Y10 (CLBLM_R_X7Y10 / SLICEM_X0)
set_property LOC SLICE_X10Y10 [get_cells u_aff]
set_property LOC SLICE_X10Y10 [get_cells u_bff]
set_property LOC SLICE_X10Y10 [get_cells u_cff]
set_property LOC SLICE_X10Y10 [get_cells u_dff]
set_property BEL AFF    [get_cells u_aff]
set_property BEL BFF    [get_cells u_bff]
set_property BEL CFF    [get_cells u_cff]
set_property BEL DFF    [get_cells u_dff]

place_design
route_design

# Disable DRC checks that block bitgen
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property IS_ENABLED 0 [get_drc_checks PDCN-1568]
set_property IS_ENABLED 0 [get_drc_checks PDCN-1569]

write_checkpoint -force stage.dcp
write_bitstream -force v_clkinv.bit
