foreach c [get_cells -hierarchical -filter {REF_NAME == LUT6 || REF_NAME == MUXF7 || REF_NAME == MUXF8}] {
  set_property LOC SLICE_X10Y20 $c
}
