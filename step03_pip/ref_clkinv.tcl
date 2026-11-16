open_checkpoint stage.dcp
# Remove IS_C_INVERTED to create reference (NOCLKINV)
set_property IS_C_INVERTED 0 [get_cells u_bff]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property IS_ENABLED 0 [get_drc_checks PDCN-1568]
set_property IS_ENABLED 0 [get_drc_checks PDCN-1569]
write_bitstream -force ref.bit
