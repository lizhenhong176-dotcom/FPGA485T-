#!/usr/bin/env python3
"""Encode a LUT6 INIT value into physical (frame, word, bit) positions."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from lut.codec import LutCodec


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--bit-map", required=True, help="path to bit_map.json")
    ap.add_argument("--init", default="0x0", help="64-bit INIT value, e.g. 0xDEADBEEF")
    args = ap.parse_args()

    codec = LutCodec(args.bit_map)
    init = int(args.init, 0)

    positions = codec.encode(init)
    print(f"{codec.loc} / {codec.bel}")
    print(f"INIT = 0x{init:016X}")
    print(f"physical bits = {len(positions)}")

    for frame, word, bit in sorted(positions):
        print(f"  frame {frame:5d}  word {word:3d}  bit {bit:2d}")

    print(f"decode(word20) = 0x{codec.decode(positions):016X}")


if __name__ == "__main__":
    main()
