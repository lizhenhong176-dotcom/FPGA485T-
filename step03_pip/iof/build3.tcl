set j $env(JOB)
read_verilog iof/iof.v
read_xdc iof/$j.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set l [get_cells -hierarchical -filter {REF_NAME == LUT6 && NAME !~ "*/*"}]
foreach c $l { set_property LOC SLICE_X47Y52 $c; set_property BEL SLICEL.A6LUT $c; set_property IS_LOC_FIXED 1 $c }
place_design
route_design
write_checkpoint -force iof/$j.dcp
set fo [open iof/pips_$j.tsv w]
foreach tn {LIOB18_SING_X81Y53 LIOB18_X81Y54 LIOI_X82Y53 LIOI_X82Y54 IO_INT_INTERFACE_L_X32Y50 IO_INT_INTERFACE_L_X32Y51 INT_L_X32Y50 INT_L_X32Y51 INT_R_X33Y50 INT_R_X33Y51} {
  set t [get_tiles -quiet $tn]
  if {[llength $t] == 0} { continue }
  foreach p [get_pips -quiet -of_objects $t] {
    set ns [get_nets -quiet -of_objects $p]
    set names {}
    foreach n $ns { lappend names [get_property NAME $n] }
    puts $fo "$tn\t$p\t[join $names ,]"
  }
}
close $fo
foreach chk {NSTD-1 UCIO-1 DPIP-1 DPOP-1 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31} {
  if {[llength [get_drc_checks -quiet $chk]] > 0} { set_property SEVERITY Warning [get_drc_checks $chk] }
}
write_bitstream -force iof/$j.bit
puts DONE
