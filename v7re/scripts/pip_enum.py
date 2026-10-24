"""Dump the physical PIPs of every net in a routed DCP, grouped by tile.

Usage: python scripts/pip_enum.py <routed.dcp> [tile_filter]

Uses the validated coupling pipeline (readable EDIF via robust run_tcl +
RapidWright readCheckpoint with auto-gen disabled). Read-only on the DCP.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from routing import env  # noqa: E402
from config import find_vivado, work_root  # noqa: E402
from vivado.runner import run_tcl  # noqa: E402


def readable_dcp(dcp: Path) -> Path:
    """Ensure a readable .edf sibling exists; return the dcp path."""
    edf = dcp.with_suffix(".edf")
    if not edf.exists():
        os.environ["XILINX_VIVADO"] = str(Path(find_vivado()).parents[2])
        tmp = work_root() / "pip_enum"
        tmp.mkdir(parents=True, exist_ok=True)
        tcl = tmp / "mk_edif.tcl"
        tcl.write_text(
            "open_checkpoint {0}\nwrite_edif -force {1}\n".format(
                str(dcp).replace("\\", "/"), str(edf).replace("\\", "/")),
            encoding="utf-8")
        run_tcl(tcl, tmp, timeout=600)
        if not edf.exists():
            raise RuntimeError("write_edif produced no .edf")
    return dcp


def main() -> int:
    dcp = Path(sys.argv[1])
    filt = sys.argv[2] if len(sys.argv) > 2 else None
    env.bootstrap(work_root() / "pip_enum")
    import rapidwright  # noqa: F401
    from com.xilinx.rapidwright.design import Design
    os.environ["RW_AUTO_GENERATE_READABLE_EDIF"] = "0"
    readable_dcp(dcp)
    design = Design.readCheckpoint(str(dcp).replace("\\", "/"))

    by_tile: dict[str, list[tuple[str, str, str, str]]] = {}
    for net in design.getNets():
        for pip in net.getPIPs():
            tile = str(pip.getTile().getName())
            if filt and filt not in tile:
                continue
            src = str(pip.getStartWireName())
            dst = str(pip.getEndWireName())
            typ = str(pip.getPIPType())
            by_tile.setdefault(tile, []).append((str(net.getName()), src, dst, typ))

    for tile in sorted(by_tile):
        print(f"### {tile}  ({len(by_tile[tile])} pips)")
        for net, src, dst, typ in sorted(by_tile[tile]):
            print(f"  {net:14s} {src:22s} -> {dst:22s} [{typ}]")
    total = sum(len(v) for v in by_tile.values())
    print(f"\ntotal pips: {total}  tiles: {len(by_tile)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
