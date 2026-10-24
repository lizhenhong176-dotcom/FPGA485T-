"""Enumerate device sites (SLICE/BRAM/DSP/IOB) with stable metadata."""

from __future__ import annotations

import csv
import json
import re
from pathlib import Path

from config import PART
from vivado.runner import run_tcl

DEFAULT_SITE_TYPES = ("SLICE", "SLICEL", "SLICEM")

SITE_ENUM_TCL = """\
link_design -part "{part}"
set fh [open "{csv_path}" w]
puts $fh "site\\ttype\\ttile\\tclock_region\\trow\\tcolumn\\tbels"

proc site_prop {{site prop}} {{
    if {{[catch {{get_property $prop $site}} value]}} {{ return "" }}
    if {{$value eq ""}} {{ return "" }}
    return $value
}}

proc obj_name {{obj}} {{
    if {{$obj eq ""}} {{ return "" }}
    if {{[catch {{get_property NAME $obj}} value]}} {{ return "" }}
    return $value
}}

proc clean {{value}} {{
    regsub -all {{[\\t\\r\\n]+}} $value " " value
    return $value
}}

set type_pattern "{type_pattern}"
set count 0
foreach s [get_sites] {{
    set type [site_prop $s SITE_TYPE]
    if {{$type eq ""}} {{ set type [site_prop $s TYPE] }}
    if {{$type_pattern ne "" && ![regexp $type_pattern $type]}} {{ continue }}

    set tile ""
    set clock_region [site_prop $s CLOCK_REGION]
    set row ""
    set column ""
    set bels {{}}
    puts $fh "[clean [get_property NAME $s]]\\t$type\\t$tile\\t$clock_region\\t$row\\t$column\\t[join $bels ";"]"
    incr count
}}
close $fh
puts "SITE_ENUM_DONE=$count"
"""


def _type_pattern(types: tuple[str, ...] | list[str] | None) -> str:
    if not types:
        return ""
    return "(" + "|".join(re.escape(t) for t in types) + ")"


def _as_int(value: str) -> int | None:
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def _slice_coords(site: str) -> tuple[int | None, int | None]:
    """SLICE_X<col>Y<row> -> (row, column)."""
    match = re.match(r"^SLICE_X(\d+)Y(\d+)$", site)
    if not match:
        return None, None
    return int(match.group(2)), int(match.group(1))


def enumerate_sites(
    workdir: str | Path,
    *,
    part: str = PART,
    types: tuple[str, ...] | list[str] | None = DEFAULT_SITE_TYPES,
    timeout: int = 900,
) -> dict:
    """Run Vivado once and write ``sites.csv`` + ``sites.json``.

    Returns a dict with device, part, types, count and the site list.
    """
    workdir = Path(workdir)
    workdir.mkdir(parents=True, exist_ok=True)

    csv_path = workdir / "sites.csv"
    tcl_path = workdir / "enumerate_sites.tcl"
    tcl_path.write_text(
        SITE_ENUM_TCL.format(
            part=part,
            csv_path=csv_path.as_posix(),
            type_pattern=_type_pattern(types),
        ),
        encoding="utf-8",
    )

    run_tcl(tcl_path, workdir, timeout=timeout)

    sites: list[dict] = []
    with csv_path.open("r", encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh, delimiter="\t")
        for row in reader:
            bels = [b for b in (row.get("bels") or "").split(";") if b]
            site_name = (row.get("site") or "").strip()
            row_index, column_index = _slice_coords(site_name)
            site = {
                "site": site_name,
                "type": (row.get("type") or "").strip(),
                "tile": (row.get("tile") or "").strip(),
                "clock_region": (row.get("clock_region") or "").strip(),
                "row": row_index,
                "column": column_index,
                "bels": bels,
            }
            if site["site"]:
                sites.append(site)

    payload = {
        "device": part,
        "part": part,
        "types": list(types) if types else [],
        "count": len(sites),
        "sites": sites,
    }
    (workdir / "sites.json").write_text(
        json.dumps(payload, indent=2), encoding="utf-8"
    )
    return payload
