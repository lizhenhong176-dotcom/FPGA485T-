"""Task 2 PIP fuzzer: attribute INT/site PIPs of ONE sink tile to bits.

Clean primitive (v2): fix BOTH source and sink placement, and sweep only the
sink LUT's *input pin* (A1..A6) via LOCK_PINS. Because the top-level IO
(a -> lut_src, lut_dst -> b) is byte-identical across variants, it cancels in
every bitstream diff. The only changes are:
  * the net n1 route into the sink (a different IMUX -> a different
    ``<track>END -> IMUXx`` PIP in the feeding INT tile), and
  * the site PIP ``IMUXx -> A_pin`` in the CLB tile.
Each pin therefore isolates one (INT mux PIP, site PIP) pair, in two different
tiles (different frame pairs), so they are separable by frame.

Uses the validated RapidWright coupling pipeline (robust run_tcl + RW read, no
raw vivado subprocess). Read-only on the Vivado install; writes only under
E:\\v7work\\pip_fuzz.
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from config import PART, find_vivado, work_root  # noqa: E402
from vivado.runner import run_tcl  # noqa: E402
from bitstream.frames import load_frames, diff_frame_indices, diff_bits_in_frame  # noqa: E402
from routing import env  # noqa: E402

VIVADO_BIN = Path(find_vivado()).parent
ROOT = work_root() / "pip_fuzz"

# A1..A6 -> the IMUX that drives it in a SLICEM (from M2 notes / pip_enum).
PIN_IMUX = {"A1": 7, "A2": 2, "A3": 1, "A4": 11, "A5": 8, "A6": 4}

VERILOG = """\
module top(
  input a,
  output b
);
  (* DONT_TOUCH = "true" *) wire n1;
  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_src (
    .O(n1), .I0(a), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
  (* DONT_TOUCH = "true" *)
  LUT6 #(.INIT(64'hFFFFFFFFFFFFFFFE)) lut_dst (
    .O(b), .I0(n1), .I1(1'b0), .I2(1'b0), .I3(1'b0), .I4(1'b0), .I5(1'b0));
endmodule
"""


def lock_for_pin(pin: str) -> str:
    """LOCK_PINS that routes the LUT's I0 (net n1) to the chosen A-pin.

    The remaining I1..I5 are tied to 1'b0 in the netlist, so their pin mapping
    is irrelevant; we just must not reuse *pin* for them.
    """
    order = ["A1", "A2", "A3", "A4", "A5", "A6"]
    others = [p for p in order if p != pin]
    mapping = [f"I0:{pin}"] + [f"I{i}:{others[i-1]}" for i in range(1, 6)]
    return " ".join(mapping)


def xdc_for(dst_loc: str, src_loc: str, dst_pin: str) -> str:
    return (
        f"set_property LOC {dst_loc} [get_cells lut_dst]\n"
        f"set_property BEL SLICEM.A6LUT [get_cells lut_dst]\n"
        f"set_property LOCK_PINS {{{lock_for_pin(dst_pin)}}} [get_cells lut_dst]\n"
        f"set_property LOC {src_loc} [get_cells lut_src]\n"
        f"set_property BEL SLICEM.A6LUT [get_cells lut_src]\n"
        f"set_property LOCK_PINS {{I0:A1 I1:A2 I2:A3 I3:A4 I4:A5 I5:A6}} [get_cells lut_src]\n"
    )


def build_tcl_for(workdir: Path, name: str) -> str:
    p = workdir.as_posix()
    return f"""\
create_project -force {name} {p} -part {PART}
add_files {p}/top.v
add_files {p}/top.xdc
synth_design -top top -part {PART}
opt_design
place_design
route_design
write_checkpoint -force {p}/routed.dcp
puts "DST_LOC=[get_property LOC [get_cells lut_dst]]"
puts "SRC_LOC=[get_property LOC [get_cells lut_src]]"
set_property SEVERITY {{Warning}} [get_drc_checks NSTD-1]
set_property SEVERITY {{Warning}} [get_drc_checks UCIO-1]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
write_bitstream -force -bin_file {p}/design.bit
puts "DONE"
"""


def net_pips(dcp: Path) -> dict[str, list[str]]:
    """Return {tile_name: ['src->dst', ...]} for every PIP on net n1 (RW, no Vivado)."""
    os.environ["XILINX_VIVADO"] = str(VIVADO_BIN.parents[2])
    os.environ["RW_AUTO_GENERATE_READABLE_EDIF"] = "0"
    edf = dcp.with_suffix(".edf")
    if not edf.exists():
        tcl = ROOT / "mk_edif.tcl"
        tcl.write_text(
            "open_checkpoint {0}\nwrite_edif -force {1}\n".format(
                dcp.as_posix(), edf.as_posix()), encoding="utf-8")
        run_tcl(tcl, ROOT, timeout=600)
    from com.xilinx.rapidwright.design import Design
    design = Design.readCheckpoint(dcp.as_posix())
    out: dict[str, list[str]] = {}
    for net in design.getNets():
        if str(net.getName()) != "n1":
            continue
        for pip in net.getPIPs():
            t = str(pip.getTile().getName())
            out.setdefault(t, []).append(f"{pip.getStartWireName()}->{pip.getEndWireName()}")
    return out


def build_variant(tag: str, dst_loc: str, src_loc: str, dst_pin: str) -> Path:
    wd = ROOT / tag
    wd.mkdir(parents=True, exist_ok=True)
    (wd / "top.v").write_text(VERILOG, encoding="utf-8")
    (wd / "top.xdc").write_text(xdc_for(dst_loc, src_loc, dst_pin), encoding="utf-8")
    (wd / "build.tcl").write_text(build_tcl_for(wd, tag), encoding="utf-8")
    run_tcl(wd / "build.tcl", wd, timeout=900)
    return wd


def diff_bits(base, frames):
    bits = {}
    for fr in diff_frame_indices(base, frames):
        pos = [(w, b) for (w, b) in diff_bits_in_frame(base, frames, fr) if w != 50]
        if pos:
            bits[fr] = pos
    return bits


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--dst", default="SLICE_X10Y24")
    ap.add_argument("--src", default="SLICE_X10Y23")
    ap.add_argument("--pins", nargs="+", default=list(PIN_IMUX.keys()),
                    help="sink A-pins to sweep; first is the base")
    args = ap.parse_args()

    ROOT.mkdir(parents=True, exist_ok=True)
    env.bootstrap(ROOT)
    import rapidwright  # noqa: F401

    results = {}
    base_frames = None
    base_pips = None
    for i, pin in enumerate(args.pins):
        tag = f"p{i}_{pin}"
        wd = build_variant(tag, args.dst, args.src, pin)
        bit = wd / "design.bit"
        if not bit.exists():
            print(f"[{tag}] NO BITSTREAM"); continue
        pips = net_pips(wd / "routed.dcp")
        frames = load_frames(bit)
        if base_frames is None:
            base_frames, base_pips = frames, pips
            results[tag] = {"pin": pin, "imux": PIN_IMUX.get(pin), "pips": pips, "diff": "BASE"}
            print(f"[{tag}] BASE pin={pin} pips={pips}")
            continue
        bits = diff_bits(base_frames, frames)
        # per-PIP delta: which PIPs appeared/disappeared vs base, per tile
        pip_delta = {}
        for t in set(list(pips) + list(base_pips)):
            cur = set(pips.get(t, [])); ref = set(base_pips.get(t, []))
            if cur != ref:
                pip_delta[t] = {"added": sorted(cur - ref), "removed": sorted(ref - cur)}
        results[tag] = {"pin": pin, "imux": PIN_IMUX.get(pin), "pips": pips,
                        "pip_delta": pip_delta, "bits": bits}
        print(f"[{tag}] pin={pin} imux={PIN_IMUX.get(pin)}")
        print(f"       pip_delta={json.dumps(pip_delta)}")
        print(f"       bits={json.dumps(bits)}")

    out = ROOT / f"fuzz_pins_{args.dst}.json"
    out.write_text(json.dumps(results, indent=2), encoding="utf-8")
    print(f"\nwrote {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
