set j $env(JOB)
read_verilog dsp/ia2.v
read_xdc dsp/ia2_$j.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set d [get_cells -hierarchical -filter {REF_NAME == DSP48E1 && NAME !~ "*/*"}]
foreach c $d { set_property LOC DSP48_X0Y0 $c; set_property IS_LOC_FIXED 1 $c }
place_design
route_design
write_checkpoint -force dsp/route_$j.dcp
# ---- DSP tile PIP truth ----
set tf [open dsp/pips_$j.tsv w]
foreach tn {DSP_L_X14Y0} {
  set t [get_tiles $tn]
  foreach p [get_pips -quiet -of_objects $t] {
    set nets [get_nets -quiet -of_objects $p]
    set nl {}
    foreach n $nets { lappend nl [get_property NAME $n] }
    puts $tf "$tn\t$p\t[join $nl ,]"
  }
}
close $tf
foreach chk {NSTD-1 UCIO-1 DPIP-1 DPOP-1 DPOP-2 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31 AVAL-4} {
  if {[llength [get_drc_checks -quiet $chk]] > 0} { set_property SEVERITY Warning [get_drc_checks $chk] }
}
write_bitstream -force dsp/r$j.bit
puts "DONE $j"
