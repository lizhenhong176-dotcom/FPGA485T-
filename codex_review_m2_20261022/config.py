"""Global configuration for the V7 reverse-engineering toolkit."""

from __future__ import annotations

import os
import shutil
from pathlib import Path

PART = os.environ.get("FPGA_PART", "xc7vx485tffg1761-2")

FRAME_WORDS = 101
FRAME_BYTES = FRAME_WORDS * 4

VIVADO_CANDIDATES = [
    Path(r"E:\app\Vivado\2017.2\bin\vivado.bat"),
    Path(r"D:\app\Vivado\2017.2\bin\vivado.bat"),
    Path(r"C:\app\Vivado\2017.2\bin\vivado.bat"),
    Path(r"E:\Xilinx\Vivado\2017.2\bin\vivado.bat"),
    Path(r"D:\Xilinx\Vivado\2017.2\bin\vivado.bat"),
    Path(r"C:\Xilinx\Vivado\2017.2\bin\vivado.bat"),
    Path("/tools/Xilinx/Vivado/2017.2/bin/vivado"),
    Path("/opt/Xilinx/Vivado/2017.2/bin/vivado"),
]

VIVADO_ROOTS = [
    Path(r"E:\app\Vivado"),
    Path(r"D:\app\Vivado"),
    Path(r"C:\app\Vivado"),
    Path(r"E:\Xilinx\Vivado"),
    Path(r"D:\Xilinx\Vivado"),
    Path(r"C:\Xilinx\Vivado"),
    Path("/tools/Xilinx/Vivado"),
    Path("/opt/Xilinx/Vivado"),
]


def work_root() -> Path:
    """Root directory for generated projects and bitstreams."""
    env = os.environ.get("FPGA_WORK")
    if env:
        return Path(env)
    if os.name == "nt":
        return Path(r"E:\v7work")
    return Path.home() / "v7work"


def _search_roots() -> str | None:
    for base in VIVADO_ROOTS:
        if not base.exists():
            continue
        try:
            versions = sorted(
                (p for p in base.iterdir() if p.is_dir()),
                key=lambda p: p.name,
                reverse=True,
            )
        except OSError:
            continue
        for version in versions:
            for name in ("vivado.bat", "vivado"):
                exe = version / "bin" / name
                if exe.exists():
                    return str(exe)
    return None


def find_vivado() -> str:
    """Resolve the Vivado executable (batch mode)."""
    env = os.environ.get("VIVADO_BIN")
    if env:
        return env

    for name in ("vivado.bat", "vivado"):
        found = shutil.which(name)
        if found:
            return found

    for candidate in VIVADO_CANDIDATES:
        if candidate.exists():
            return str(candidate)

    found = _search_roots()
    if found:
        return found

    raise FileNotFoundError(
        "Vivado not found. Set VIVADO_BIN to the vivado/vivado.bat executable."
    )
