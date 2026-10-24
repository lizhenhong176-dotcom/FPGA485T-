"""RapidWright / JVM environment bootstrap.

The JVM must be configured *before* ``import rapidwright``: JPype reads
JAVA_HOME when the VM starts. Every entry point that touches RapidWright
calls :func:`bootstrap` first.
"""

from __future__ import annotations

import os
import shutil
import sys
from pathlib import Path

PART = os.environ.get("FPGA_PART", "xc7vx485tffg1761-2")

JAVA_CANDIDATES = [
    Path(r"E:\tools\jdk17\jdk-17.0.20.1+1"),
    Path(r"E:\tools\jdk17"),
    Path(r"D:\tools\jdk17"),
    Path(r"C:\Program Files\Java\jdk-17"),
    Path(r"C:\Program Files\Eclipse Adoptium\jdk-17"),
    Path(r"C:\Program Files\Java\jdk-21"),
]


def work_root() -> Path:
    """Root for generated data (outside the source tree by default)."""
    env = os.environ.get("FPGA_WORK")
    if env:
        return Path(env)
    return Path(r"E:\v7work") if os.name == "nt" else Path.home() / "v7work"


def _java_major(home: Path) -> int:
    """Read the JDK major version from its ``release`` file (0 = unknown)."""
    release = home / "release"
    try:
        for line in release.read_text(encoding="utf-8", errors="ignore").splitlines():
            if line.startswith("JAVA_VERSION="):
                version = line.split("=", 1)[1].strip().strip('"')
                parts = version.split(".")
                if parts[0] == "1" and len(parts) > 1:  # 1.8.0_131
                    return int(parts[1])
                return int(parts[0].split("-")[0].split("+")[0])
    except (OSError, ValueError):
        pass
    return 0


def _usable(home: Path) -> bool:
    if not ((home / "bin" / "java.exe").exists() or (home / "bin" / "java").exists()):
        return False
    major = _java_major(home)
    return major == 0 or major >= 9


def find_java() -> Path:
    env = os.environ.get("JAVA_HOME")
    if env:
        home = Path(env)
        if _usable(home):
            return home
        print(f"warning: JAVA_HOME={env} is not JDK 9+; looking for a newer JDK",
              file=sys.stderr)
    for cand in JAVA_CANDIDATES:
        if _usable(cand):
            return cand
    which = shutil.which("java")
    if which:
        home = Path(which).resolve().parent.parent
        if _usable(home):
            return home
    raise FileNotFoundError("No JDK 9+ found. Set JAVA_HOME to a JDK 17+ installation.")


def bootstrap(workdir: Path | None = None) -> Path:
    """Prepare env vars for JPype and return the temp directory used."""
    home = find_java()
    tmp = (workdir or work_root()) / "tmp"
    tmp.mkdir(parents=True, exist_ok=True)
    os.environ.setdefault("JAVA_HOME", str(home))
    os.environ["JAVA_HOME"] = str(home)
    path = os.environ.get("PATH", "")
    if str(home / "bin") not in path:
        os.environ["PATH"] = str(home / "bin") + os.pathsep + path
    # Vivado loader.bat infers 32-bit when this is unset (sandbox scrubbing).
    os.environ["PROCESSOR_ARCHITECTURE"] = "AMD64"
    os.environ.setdefault("ARCHITEW6432", "AMD64")
    os.environ["TEMP"] = str(tmp)
    os.environ["TMP"] = str(tmp)
    return tmp


def device(part: str | None = None):
    """Open the RapidWright device (import happens after bootstrap)."""
    import rapidwright  # noqa: F401  (starts the JVM)
    from com.xilinx.rapidwright.device import Device

    return Device.getDevice(part or PART)


def logical_xy(tile) -> tuple[int, int]:
    """Logical tile coordinates, invariant to double-width grid columns.

    Tile *names* use logical X/Y for INT/CLB/BRAM columns, while a few types
    (VBRK, HCLK*, CMT*) are numbered in grid columns; callers that compare
    coordinates across types must know which convention they are in.
    """
    return int(tile.getTileXCoordinate()), int(tile.getTileYCoordinate())
