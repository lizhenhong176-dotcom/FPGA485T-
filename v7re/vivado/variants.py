"""Generate INIT variants from a routed DCP.

The key idea: open the same DCP for every variant, change only the LUT INIT
property, and write a bitstream.  Placement and routing stay identical, so a
frame diff contains only the LUT memory bits.
"""

from __future__ import annotations

VARIANT_TCL = """\
open_checkpoint {dcp}

set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set cells [get_cells -hier -filter {{REF_NAME =~ LUT6*}}]
if {{[llength $cells] == 0}} {{
    error "no LUT6 cell found in DCP"
}}

set cell [lindex $cells 0]
puts "LUT cell: $cell"

set_property INIT 64'h{init_a} $cell
write_bitstream -force -bin_file {bit_a}
puts "BIT A: {bit_a}"

set_property INIT 64'h{init_b} $cell
write_bitstream -force -bin_file {bit_b}
puts "BIT B: {bit_b}"
"""
