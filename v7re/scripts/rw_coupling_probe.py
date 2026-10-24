"""Feasibility gate for Task 2: can RapidWright 2026.1 drive Vivado 2017.2?

We need RW to (a) read a 2017.2 routed DCP and (b) write a bitstream back
through VivadoTools (which shells out to `vivado`). If both work, the clean
single-PIP path (Net.addPIP -> writeBitstream -> diff) is viable. If not,
Task 2 falls back to the MCD-corpus + linear-algebra approach.

Read-only on the source DCP; writes only under E:\\v7work\\rw_probe.
"""

from __future__ import annotations

import os
import sys
import traceback
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from routing import env  # noqa: E402

VIVADO_BIN = Path(r"E:\app\Vivado\2017.2\bin")
DCP = Path(r"E:\v7work\probe_boundary\SLICE_X10Y24\A6LUT\routed.dcp")
OUT = env.work_root() / "rw_probe"
OUT.mkdir(parents=True, exist_ok=True)


def main() -> int:
    env.bootstrap(OUT)
    # Make VivadoTools able to locate the 2017.2 `vivado` executable.
    os.environ["XILINX_VIVADO"] = str(VIVADO_BIN.parent.parent)
    os.environ["PATH"] = str(VIVADO_BIN) + os.pathsep + os.environ.get("PATH", "")
    # License is ambient to the `vivado` executable (the batch never set it);
    # VivadoTools shells out to the same binary, so do NOT override
    # XILINXD_LICENSE_FILE (a bad path would break it).

    print("== step 0: import rapidwright (starts JVM) ==")
    import rapidwright  # noqa: F401
    from com.xilinx.rapidwright.design import Design, Net
    from com.xilinx.rapidwright.device import Device
    from com.xilinx.rapidwright.util import VivadoTools
    print("   import OK; VivadoTools located")

    print(f"== step 1: read 2017.2 DCP {DCP} ==")
    # RapidWright's auto-generated readable.tcl does not escape Windows
    # backslashes (E:\v7work\...\routed.dcp -> E:7work...), so pass forward
    # slashes; Vivado's open_checkpoint accepts them.
    dcp_fwd = str(DCP).replace("\\", "/")
    try:
        design = Design.readCheckpoint(dcp_fwd)
    except Exception as exc:  # noqa: BLE001
        print("   READ DCP FAILED:", exc)
        traceback.print_exc()
        return 2
    print(f"   read OK; part={design.getPart()} nets={design.getNets().size()} "
          f"cells={design.getCells().size()}")

    print("== step 2: write bitstream via VivadoTools (shells to vivado) ==")
    bit = OUT / "roundtrip.bit"
    if bit.exists():
        bit.unlink()
    try:
        VivadoTools.writeBitstream(design, str(bit).replace("\\", "/"))
    except Exception as exc:  # noqa: BLE001
        print("   WRITE BITSTREAM FAILED:", exc)
        traceback.print_exc()
        return 3
    if bit.exists() and bit.stat().st_size > 1000:
        print(f"   roundtrip OK; {bit} size={bit.stat().st_size}")
    else:
        print("   roundtrip produced no usable .bit")
        return 4

    print("COUPLING GATE: PASS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
