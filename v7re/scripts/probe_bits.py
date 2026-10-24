#!/usr/bin/env python3
"""Sweep every LUT6 INIT bit at one (LOC, BEL) and record physical bit positions.

This is the bit-database builder.  It implements the design once, then writes
65 bitstreams from the same DCP (base + one per INIT bit), so placement and
routing never change.

Runtime: roughly 30-40 minutes on a typical PC (65 x write_bitstream).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.frames import diff_bits_in_frame, diff_frame_indices
from bitstream.parser import frames_from_words, parse_bit
from config import PART, work_root
from vivado.bits import bits_tcl
from vivado.probe import build_lut_probe
from vivado.runner import run_tcl


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--loc", required=True)
    ap.add_argument("--bel", default="A6LUT")
    ap.add_argument("--part", default=PART)
    ap.add_argument("--workdir", default=None)
    ap.add_argument("--count", type=int, default=64)
    ap.add_argument("--skip-build", action="store_true")
    ap.add_argument("--skip-vivado", action="store_true", help="only re-parse existing bitstreams")
    args = ap.parse_args()

    if args.workdir:
        workdir = Path(args.workdir)
    else:
        workdir = work_root() / "bits" / args.loc.replace(":", "_") / args.bel

    workdir.mkdir(parents=True, exist_ok=True)
    dcp = workdir / "routed.dcp"

    if not args.skip_build and not dcp.exists():
        print(f"[build] {args.loc} / {args.bel}")
        dcp = build_lut_probe(workdir, args.loc, args.bel, "0" * 16, args.part)
        print(f"[build] DCP: {dcp}")

    if not args.skip_vivado:
        print("[vivado] writing base + one-hot bitstreams (long)")
        tcl = workdir / "bits.tcl"
        tcl.write_text(
            bits_tcl(dcp.as_posix(), workdir.as_posix(), "0" * 16, args.count),
            encoding="utf-8",
        )
        run_tcl(tcl, workdir, timeout=3600)

    base = parse_bit(workdir / "bit_base.bit")
    if base.leftover:
        raise ValueError(f"base bitstream leftover={base.leftover}")
    base_frames = frames_from_words(base.payload_words)

    result: dict = {
        "loc": args.loc,
        "bel": args.bel,
        "part": args.part,
        "count": args.count,
        "total_frames": len(base_frames),
        "bits": {},
    }

    for i in range(args.count):
        path = workdir / f"bit_{i:02d}.bit"
        if not path.exists():
            print(f"[skip] missing {path.name}")
            continue

        bs = parse_bit(path)
        if bs.leftover:
            print(f"[warn] {path.name} leftover={bs.leftover}")

        frames = frames_from_words(bs.payload_words)
        diff = diff_frame_indices(base_frames, frames)
        positions = {
            str(f): diff_bits_in_frame(base_frames, frames, f) for f in diff
        }
        result["bits"][str(i)] = positions
        total = sum(len(v) for v in positions.values())
        print(f"[{i:02d}] frames={diff} bits={total}")

        (workdir / "bit_map.json").write_text(
            json.dumps(result, indent=2), encoding="utf-8"
        )

    print(f"wrote {workdir / 'bit_map.json'}")


if __name__ == "__main__":
    main()
