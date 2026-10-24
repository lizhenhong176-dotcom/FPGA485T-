"""Generate a fixed-LOC/BEL LUT probe design and its build script."""

from __future__ import annotations

import re
from pathlib import Path

from config import PART

VERILOG_TEMPLATE = """\
module top(
  input a0, a1, a2, a3, a4, a5,
  output b
);
  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'h{init})) lut (
    .O(b), .I0(a0), .I1(a1), .I2(a2), .I3(a3), .I4(a4), .I5(a5)
  );
endmodule
"""

XDC_TEMPLATE = """\
set_property LOC {loc} [get_cells lut]
set_property BEL {bel} [get_cells lut]
set_property LOCK_PINS {{I0:{p}1 I1:{p}2 I2:{p}3 I3:{p}4 I4:{p}5 I5:{p}6}} [get_cells lut]
"""


def lut_probe_verilog(loc: str, bel: str, init: str) -> str:
    # LOC/BEL are applied through XDC (more reliable than Verilog attributes
    # for BEL).  The attributes are kept out of the Verilog on purpose.
    return VERILOG_TEMPLATE.format(init=init)


def lut_probe_xdc(loc: str, bel: str) -> str:
    # A6LUT uses A1..A6, B6LUT uses B1..B6, etc.  The pin prefix follows the
    # slice half selected by the BEL.
    prefix = bel[0].upper() if bel and bel[0].upper() in "ABCD" else "A"
    return XDC_TEMPLATE.format(loc=loc, bel=bel, p=prefix)


def _project_name(workdir: Path) -> str:
    raw = f"{workdir.parent.name}_{workdir.name}"
    name = re.sub(r"[^A-Za-z0-9_]", "_", raw)
    if not name or name[0].isdigit():
        name = "probe_" + name
    return name


def lut_probe_tcl(
    workdir: Path,
    part: str = PART,
    init_a: str | None = None,
    init_b: str | None = None,
) -> str:
    """Tcl that synthesizes, implements and saves a routed DCP.

    When ``init_a``/``init_b`` are given, both bitstreams are written in the
    same Vivado session.  This avoids a second launcher start, which on this
    machine occasionally hangs before creating ``vivado.log``.
    """
    workdir = Path(workdir)
    name = _project_name(workdir)
    path = workdir.as_posix()

    bits = ""
    if init_a is not None and init_b is not None:
        bits = f"""\
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property INIT 64'h{init_a} $c
write_bitstream -force -bin_file {path}/a.bit
set_property INIT 64'h{init_b} $c
write_bitstream -force -bin_file {path}/b.bit
"""

    return f"""\
create_project -force {name} {path} -part {part}
add_files {path}/top.v
add_files {path}/top.xdc
synth_design -top top -part {part}
opt_design
place_design
set c [get_cells -hier -filter {{REF_NAME =~ LUT6*}}]
puts "PROBE_LOC=[get_property LOC $c]"
puts "PROBE_BEL=[get_property BEL $c]"
puts "PROBE_LOCK=[get_property LOCK_PINS $c]"
route_design
write_checkpoint -force {path}/routed.dcp
puts "DCP: {path}/routed.dcp"
{bits}"""

