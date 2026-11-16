# s8_route: rerun same design, export ROUTE truth for the 6 LUT input nets + save DCP
create_project -in_memory -part xc7vx485t
read_verilog /opt/lzh/step03/s8/s8_v0.v
read_xdc /opt/lzh/step03/s8/s8_v0.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_checkpoint -force /opt/lzh/step03/s8/s8_v0_routed.dcp
# must match the original bitstream (same flow) -> verify
set fp [open /opt/lzh/step03/s8/s8_route.json w]
puts $fp "{"
set rows {}
foreach p {I0 I1 I2 I3 I4 I5} {
    set pin [get_pins u_l/$p]
    set n [lindex [get_nets -of_objects $pin] 0]
    set r [get_property ROUTE $n]
    regsub -all \" $r \\\" r2
    lappend rows "\"$p\": {\"net\": \"$n\", \"route\": \"...\"}"
    # write full route separately, one file per pin (route strings contain braces)
    set f2 [open /opt/lzh/step03/s8/route_$p.txt w]
    puts $f2 "PIN $p NET $n"
    puts $f2 "ROUTE $r"
    close $f2
}
puts $fp [join $rows ",\n"]
puts $fp "}"
close $fp
puts "S8_ROUTE_DONE"
