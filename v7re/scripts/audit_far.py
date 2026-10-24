#!/usr/bin/env python3
"""Audit FAR usage in a 7-series bitstream and decode candidate addresses."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.far import FarAddress  # noqa: E402
from bitstream.parser import parse_bit  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("bitstream", type=Path)
    ap.add_argument("--far", action="append", default=[], help="0x... to decode")
    args = ap.parse_args()

    bs = parse_bit(args.bitstream)
    print(f"bitstream={bs.path}")
    print(f"sync_offset={bs.sync_offset} file_size={bs.file_size}")
    print(f"frames={bs.frame_count} leftover={bs.leftover}")
    print(f"far_starts={bs.far_starts}")
    for payload_offset, far in bs.far_starts:
        print(f"  payload_word={payload_offset} far=0x{far:08X} {FarAddress.decode(far)}")

    if len(bs.far_starts) <= 1:
        print(
            "NOTE: this bitstream has <=1 FAR start; per-frame FAR values are not "
            "present in the packet stream. Frame indices are payload order only."
        )

    for raw in args.far:
        value = int(raw, 0)
        print(f"decode 0x{value:08X}: {FarAddress.decode(value).to_dict()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
