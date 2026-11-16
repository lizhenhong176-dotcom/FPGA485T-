set j $env(JOB)
read_verilog dsp/ia2.v
read_xdc dsp/ia2_$j.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
set d [get_cells -hierarchical -filter {REF_NAME == DSP48E1 && NAME !~ "*/*"}]
foreach c $d { set_property LOC DSP48_X0Y0 $c; set_property IS_LOC_FIXED 1 $c }
place_design
route_design
set pin [get_pins [lindex $d 0]/A[0]]
set net [get_nets -quiet -of_objects $pin]
puts "ROUTEDUMP JOB=$j PIN=[get_property LOC [lindex $d 0]] NET=[get_property NAME $net]"
puts "ROUTEDUMP JOB=$j ROUTE=[get_property ROUTE $net]"
set all [get_nets -quiet -filter {NAME =~ *din*}]
foreach n $all { puts "ROUTEDUMP JOB=$j DINNET=[get_property NAME $n] ROUTE=[get_property ROUTE $n]" }
foreach chk {NSTD-1 UCIO-1 DPIP-1 DPOP-1 DPOP-2 REQP-20 REQP-24 REQP-29 REQP-30 REQP-31 AVAL-4} {
  if {[llength [get_drc_checks -quiet $chk]] > 0} { set_property SEVERITY Warning [get_drc_checks $chk] }
}
write_bitstream -force dsp/ia2_$j.bit
puts "DONE $j"
