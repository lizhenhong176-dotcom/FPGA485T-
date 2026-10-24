"""End-to-end clean probe: build DCP, generate variants, measure diff."""

from __future__ import annotations

import json
import re
from pathlib import Path

from bitstream.frames import diff_bits_in_frame, diff_frame_indices
from bitstream.parser import frames_from_words, parse_bit
from config import PART
from vivado.design import lut_probe_tcl, lut_probe_verilog, lut_probe_xdc
from vivado.runner import run_tcl
from vivado.variants import VARIANT_TCL


def build_lut_probe(
    workdir: str | Path,
    loc: str,
    bel: str,
    init_a: str,
    part: str = PART,
    init_b: str | None = None,
) -> Path:
    """Create the Verilog + Tcl, implement once, and return the routed DCP.

    If *init_b* is given, the same Vivado session also writes ``a.bit`` and
    ``b.bit``.  Otherwise callers use :func:`run_variants` afterwards.
    """
    workdir = Path(workdir)
    workdir.mkdir(parents=True, exist_ok=True)

    (workdir / "top.v").write_text(
        lut_probe_verilog(loc, bel, init_a), encoding="utf-8"
    )
    (workdir / "top.xdc").write_text(
        lut_probe_xdc(loc, bel), encoding="utf-8"
    )

    tcl = workdir / "build.tcl"
    tcl.write_text(
        lut_probe_tcl(workdir, part, init_a=init_a, init_b=init_b),
        encoding="utf-8",
    )
    run_tcl(tcl, workdir)

    dcp = workdir / "routed.dcp"
    if not dcp.exists():
        raise FileNotFoundError(f"DCP was not produced: {dcp}")

    # Catch invalid LOC constraints: Vivado silently places the cell elsewhere
    # when the requested SLICE site does not exist.
    log = workdir / "vivado.log"
    if log.exists():
        text = log.read_text(encoding="utf-8", errors="replace")
        match = re.search(r"^PROBE_LOC=(\S+)", text, re.MULTILINE)
        if match and match.group(1) != loc:
            raise ValueError(
                f"LOC not honored: requested {loc}, placed at {match.group(1)}"
            )

    return dcp


def run_variants(
    workdir: str | Path,
    dcp: str | Path,
    init_a: str,
    init_b: str,
) -> tuple[Path, Path]:
    """Write bitstream A (init_a) and B (init_b) from the same DCP."""
    workdir = Path(workdir)
    bit_a = workdir / "a.bit"
    bit_b = workdir / "b.bit"

    tcl = workdir / "variants.tcl"
    tcl.write_text(
        VARIANT_TCL.format(
            dcp=Path(dcp).as_posix(),
            bit_a=bit_a.as_posix(),
            bit_b=bit_b.as_posix(),
            init_a=init_a,
            init_b=init_b,
        ),
        encoding="utf-8",
    )
    run_tcl(tcl, workdir)
    return bit_a, bit_b


def measure(bit_a: str | Path, bit_b: str | Path) -> dict:
    """Parse two bitstreams and report frame / word / bit differences."""
    bs_a = parse_bit(bit_a)
    bs_b = parse_bit(bit_b)

    if bs_a.leftover or bs_b.leftover:
        raise ValueError(
            f"frame split failed: leftover {bs_a.leftover} / {bs_b.leftover}"
        )

    fa = frames_from_words(bs_a.payload_words)
    fb = frames_from_words(bs_b.payload_words)

    frames = diff_frame_indices(fa, fb)
    bits = {str(f): diff_bits_in_frame(fa, fb, f) for f in frames}

    return {
        "count_a": len(fa),
        "count_b": len(fb),
        "diff_frames": frames,
        "bits": bits,
    }


def probe(
    workdir: str | Path,
    loc: str,
    bel: str,
    init_a: str,
    init_b: str,
    part: str = PART,
    rebuild: bool = False,
) -> dict:
    """Full clean-probe flow for one (LOC, BEL)."""
    workdir = Path(workdir)
    dcp = workdir / "routed.dcp"

    if rebuild or not dcp.exists():
        dcp = build_lut_probe(workdir, loc, bel, init_a, part, init_b=init_b)

    bit_a = workdir / "a.bit"
    bit_b = workdir / "b.bit"
    if not (bit_a.exists() and bit_b.exists()):
        bit_a, bit_b = run_variants(workdir, dcp, init_a, init_b)
    result = measure(bit_a, bit_b)
    result.update(
        {
            "loc": loc,
            "bel": bel,
            "init_a": init_a,
            "init_b": init_b,
            "dcp": str(dcp),
        }
    )

    (workdir / "result.json").write_text(
        json.dumps(result, indent=2), encoding="utf-8"
    )
    return result
