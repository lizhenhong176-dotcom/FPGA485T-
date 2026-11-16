# s8_v0: LUT6+FDRE at SLICE_X8Y11 (CLBLL_L_X6Y11), bit->netlist decoder v0 ground truth
create_project -in_memory -part xc7vx485t
read_verilog /opt/lzh/step03/s8/s8_v0.v
read_xdc /opt/lzh/step03/s8/s8_v0.xdc
synth_design -top top -part xc7vx485t -flatten_hierarchy none
place_design
route_design
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
write_bitstream /opt/lzh/step03/s8/s8_v0.bit

# ---- ground truth export ----
set fp [open /opt/lzh/step03/s8/s8_truth.json w]
puts $fp "{"
set lut [get_cells u_l]
puts $fp "  \"init\": \"[get_property INIT $lut]\","
puts $fp "  \"ref_name\": \"[get_property REF_NAME $lut]\","
puts $fp "  \"pin_map\": \"[get_property PIN_MAP $lut]\","
puts $fp "  \"site\": \"[get_property SITE $lut]\","
puts $fp "  \"bel\": \"[get_property BEL $lut]\","
set nets {}
foreach p {I0 I1 I2 I3 I4 I5} {
    set n [get_nets -quiet -of_objects [get_pins u_l/$p]]
    lappend nets "\"$p\": \"[lindex $n 0]\""
}
puts $fp "  \"lut_pins\": { [join $nets ", "] },"
set f [get_cells u_f]
puts $fp "  \"ff\": { \"ref\": \"[get_property REF_NAME $f]\", \"init\": \"[get_property INIT $f]\", \"site\": \"[get_property SITE $f]\", \"bel\": \"[get_property BEL $f]\" }"
puts $fp "}"
close $fp
puts "S8_TRUTH_DONE"
