set j $env(JOB)
read_verilog iof/iof.v
read_xdc iof/$j.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set l [get_cells -hierarchical -filter {REF_NAME == LUT6 && NAME !~ "*/*"}]
set loc $env(LOC); set bel $env(BEL)
foreach c $l { set_property LOC $loc $c; set_property BEL $bel $c; set_property IS_LOC_FIXED 1 $c }
place_design
route_design
foreach chk {NSTD-1 UCIO-1 DPIP-1 DPOP-1 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31} {
  if {[llength [get_drc_checks -quiet $chk]] > 0} { set_property SEVERITY Warning [get_drc_checks $chk] }
}
write_bitstream -force iof/$j.bit
puts DONE
