# Rewrite LUT6 INIT values on the placed+routed checkpoint of the reference
# design, then re-emit a bitstream. Routing is untouched (same placed cells,
# same nets), so the bitstream delta is a pure LUT-functional tamper.
open_checkpoint C:/Temp/tamper_ref/routed.dcp

set luts [get_cells -hier -filter {REF_NAME =~ LUT6}]
puts "LUT6 cells: [llength $luts]"

set i 0
foreach c $luts {
    # deterministic, distinct function per cell: keep it a valid 64-bit INIT
    set v [expr {(0x0123456789ABCDEF ^ ($i * 0x0101010101010101)) & 0xFFFFFFFFFFFFFFFF}]
    set_property INIT [format "64'h%016X" $v] $c
    puts "  $c INIT -> [format %016X $v]"
    incr i
}

# Re-run route on the unchanged placement: the router keeps the existing
# fixed routing (no placer run), so the write must reproduce identical PIPs.
route_design -preserve

# DRC overrides are run-context properties, not stored in the checkpoint.
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.General.UnconstrainedPins {Allow} [current_design]
foreach chk {NSTD-1 UCIO-1} {
    catch { set_property SEVERITY {Warning} [get_drc_checks $chk] }
}
write_bitstream -force C:/Temp/tamper_ref/tamper_init.bit
puts "TAMPER_BIT_DONE"
