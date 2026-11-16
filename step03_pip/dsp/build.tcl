set v $env(V)
read_verilog dsp/d_$v.v
read_xdc dsp/d.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set d [get_cells -hierarchical -filter {REF_NAME == DSP48E1 && NAME !~ "*/*"}]
foreach c $d { set_property LOC DSP48_X0Y0 $c; set_property IS_LOC_FIXED 1 $c }
place_design
route_design
foreach chk {NSTD-1 UCIO-1 DPIP-1 DPOP-1 DPOP-2 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31 AVAL-4} {
  if {[llength [get_drc_checks -quiet $chk]] > 0} { set_property SEVERITY Warning [get_drc_checks $chk] }
}
write_bitstream -force dsp/out_$v.bit
puts "DONE $v"
