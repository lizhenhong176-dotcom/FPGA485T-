set_property LOC SLICE_X10Y20 [get_cells -hierarchical -filter {NAME =~ "*uA*" || NAME =~ "*fA*"}]
set_property BEL SLICEM.A6LUT [get_cells -hierarchical -filter {NAME =~ "*uA*"}]
set_property BEL SLICEM.AFF [get_cells -hierarchical -filter {NAME =~ "*fA*"}]
