"""Generate a Tcl script that sweeps every LUT INIT bit from one DCP."""

from __future__ import annotations

HEAD = """\
open_checkpoint {dcp}

set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

set cell [lindex [get_cells -hier -filter {{REF_NAME =~ LUT6*}}] 0]
if {{$cell eq ""}} {{
    error "no LUT6 cell found in DCP"
}}
puts "LUT cell: $cell"

# Baseline: all INIT bits zero.
set_property INIT 64'h{base_init} $cell
write_bitstream -force {out_dir}/bit_base.bit
puts "BASE: {out_dir}/bit_base.bit"
"""


def bits_tcl(
    dcp: str,
    out_dir: str,
    base_init: str = "0000000000000000",
    count: int = 64,
) -> str:
    """Return Tcl that writes one bitstream per one-hot INIT bit."""
    lines = [HEAD.format(dcp=dcp, out_dir=out_dir, base_init=base_init)]

    for i in range(count):
        value = 1 << i
        bit = f"{out_dir}/bit_{i:02d}.bit"
        lines.append(f"set_property INIT 64'h{value:016x} $cell")
        lines.append(f"write_bitstream -force {bit}")
        lines.append(f'puts "BIT {i:02d}: {bit}"')

    return "\n".join(lines)
