#!/usr/bin/env python3
"""Compare two bitstreams or two frames.bin files."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.frames import diff_bits_in_frame, diff_frame_indices, load_frames


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("a", help="baseline .bit/.bin or frames.bin")
    ap.add_argument("b", help="variant .bit/.bin or frames.bin")
    ap.add_argument("--bits", action="store_true", help="print word/bit positions")
    ap.add_argument("--max", type=int, default=32, help="max frames to detail")
    args = ap.parse_args()

    fa = load_frames(args.a)
    fb = load_frames(args.b)
    diff = diff_frame_indices(fa, fb)

    print(f"A: {len(fa)} frames")
    print(f"B: {len(fb)} frames")
    print(f"diff frames: {len(diff)}")
    print(diff[:64])

    if args.bits:
        for frame in diff[: args.max]:
            positions = diff_bits_in_frame(fa, fb, frame)
            print(f"frame {frame}: {len(positions)} bits")
            for word, bit in positions:
                print(f"  word {word:3d} bit {bit:2d}")


if __name__ == "__main__":
    main()
