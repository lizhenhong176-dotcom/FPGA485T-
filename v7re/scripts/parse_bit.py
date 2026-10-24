#!/usr/bin/env python3
"""Parse a 7-series .bit/.bin and optionally dump raw frames."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.parser import frames_from_words, parse_bit


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("bit", help="input .bit or .bin")
    ap.add_argument("out", nargs="?", help="optional frames.bin output")
    args = ap.parse_args()

    bs = parse_bit(args.bit)
    print(
        f"{bs.path.name}: sync={bs.sync_offset} size={bs.file_size} "
        f"frames={bs.frame_count} leftover={bs.leftover}"
    )

    if bs.commands:
        print("commands:", ", ".join(f"0x{c:02X}" for c, _ in bs.commands))

    if args.out:
        frames = frames_from_words(bs.payload_words)
        out = Path(args.out)
        with out.open("wb") as f:
            for frame in frames:
                f.write(struct.pack(f">{len(frame)}I", *frame))
        print(f"wrote {out} ({len(frames)} frames)")


if __name__ == "__main__":
    main()
