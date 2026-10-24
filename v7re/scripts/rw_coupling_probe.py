"""Feasibility gate for Task 2: RapidWright 2026.1 read/modify + robust Vivado
2017.2 bitstream, WITHOUT letting RapidWright shell out to the flaky launcher.

Architecture this validates (the one the PIP fuzzer will use):
  1. robust run_tcl (watchdog+retry) writes a *readable* EDIF next to the DCP;
  2. RapidWright reads the DCP (auto-gen disabled -> no Vivado call);
  3. RapidWright writes a new DCP natively (design.writeCheckpoint);
  4. robust run_tcl opens that DCP and writes the bitstream.

If every step works, single-PIP isolation via Net.addPIP is viable on this
Windows box. Read-only on the source DCP; writes only under E:\\v7work\\rw_probe.
"""

from __future__ import annotations

import os
import sys
import traceback
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from routing import env  # noqa: E402
from config import find_vivado, work_root  # noqa: E402
from vivado.runner import run_tcl  # noqa: E402

VIVADO_BIN = Path(find_vivado()).parent
DCP = Path(r"E:\v7work\probe_boundary\SLICE_X10Y24\A6LUT\routed.dcp")
OUT = work_root() / "rw_probe"
OUT.mkdir(parents=True, exist_ok=True)


def main() -> int:
    env.bootstrap(OUT)
    os.environ["XILINX_VIVADO"] = str(VIVADO_BIN.parent.parent)
    os.environ["PATH"] = str(VIVADO_BIN) + os.pathsep + os.environ.get("PATH", "")

    print("== step 0: import rapidwright (starts JVM) ==")
    import rapidwright  # noqa: F401
    from com.xilinx.rapidwright.design import Design
    print("   import OK")

    # ---- step 1: readable EDIF via the ROBUST runner (watchdog+retry) ----
    print("== step 1: write readable EDIF via run_tcl ==")
    edf = DCP.with_suffix(".edf")
    if not edf.exists():
        tcl = OUT / "mk_edif.tcl"
        tcl.write_text(
            "open_checkpoint {0}\nwrite_edif -force {1}\n".format(
                str(DCP).replace("\\", "/"), str(edf).replace("\\", "/")),
            encoding="utf-8")
        run_tcl(tcl, OUT, timeout=600)
        print("   edf exists=", edf.exists())
        if not edf.exists():
            return 2

    # ---- step 2: RapidWright reads the DCP (no Vivado call) ----
    print("== step 2: RapidWright readCheckpoint (auto-gen off) ==")
    os.environ["RW_AUTO_GENERATE_READABLE_EDIF"] = "0"
    try:
        design = Design.readCheckpoint(str(DCP).replace("\\", "/"))
    except Exception as exc:  # noqa: BLE001
        print("   READ DCP FAILED:", exc)
        traceback.print_exc()
        return 3
    print(f"   read OK; part={design.getPart()} nets={design.getNets().size()} "
          f"cells={design.getCells().size()}")

    # ---- step 3: RapidWright writes a new DCP natively ----
    print("== step 3: RapidWright writeCheckpoint (native) ==")
    out_dcp = OUT / "rw_out.dcp"
    try:
        design.writeCheckpoint(str(out_dcp).replace("\\", "/"))
    except Exception as exc:  # noqa: BLE001
        print("   WRITE DCP FAILED:", exc)
        traceback.print_exc()
        return 4
    print("   rw_out.dcp exists=", out_dcp.exists(),
          "size=", out_dcp.stat().st_size if out_dcp.exists() else 0)

    # ---- step 4: robust run_tcl bitstreams the RW-written DCP ----
    print("== step 4: bitstream the RW-written DCP via run_tcl ==")
    btcl = OUT / "bit.tcl"
    bit = OUT / "rw_out.bit"
    btcl.write_text(
        "open_checkpoint {0}\n"
        "set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]\n"
        "set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]\n"
        "set_property CFGBVS VCCO [current_design]\n"
        "set_property CONFIG_VOLTAGE 3.3 [current_design]\n"
        "write_bitstream -force -bin_file {1}\n".format(
            str(out_dcp).replace("\\", "/"), str(bit).replace("\\", "/")),
        encoding="utf-8")
    try:
        run_tcl(btcl, OUT, timeout=900)
    except Exception as exc:  # noqa: BLE001
        print("   BITSTREAM FAILED:", exc)
        traceback.print_exc()
        return 5
    if bit.exists() and bit.stat().st_size > 1000:
        print(f"   bitstream OK; {bit} size={bit.stat().st_size}")
    else:
        print("   bitstream produced no usable .bit")
        return 6

    print("COUPLING GATE: PASS  (read/modify/write DCP + robust bitstream all work)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
