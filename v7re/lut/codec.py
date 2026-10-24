"""Encode / decode LUT6 INIT bits from a `bit_map.json` produced by probe_bits.

The mapping is linear over GF(2): the physical bits for an arbitrary INIT value
are the XOR of the one-hot columns for every set INIT bit.  This was verified
against an actual INIT=0b11 bitstream.
"""

from __future__ import annotations

import json
from pathlib import Path

Position = tuple[int, int, int]  # (frame, word, bit)


class LutCodec:
    def __init__(self, bit_map_path: str | Path):
        data = json.loads(Path(bit_map_path).read_text(encoding="utf-8"))
        self.data = data
        self.loc = data.get("loc")
        self.bel = data.get("bel")
        self.total_frames = data.get("total_frames")

        self.columns: list[set[Position]] = []
        for i in range(64):
            entry = data["bits"].get(str(i))
            if entry is None:
                raise ValueError(f"bit_map is missing INIT bit {i}")
            positions: set[Position] = set()
            for frame, items in entry.items():
                for word, bit in items:
                    positions.add((int(frame), int(word), int(bit)))
            self.columns.append(positions)

        # Direct (non-XOR) word-20 position for each INIT bit.
        self.direct: dict[int, Position] = {}
        for i, positions in enumerate(self.columns):
            word20 = [(f, 20, b) for f, w, b in positions if w == 20]
            if len(word20) != 1:
                raise ValueError(
                    f"INIT bit {i}: expected exactly one word-20 position, got {word20}"
                )
            self.direct[i] = word20[0]

    def encode(self, init: int) -> set[Position]:
        """Return the physical bits to toggle for *init* (baseline INIT=0)."""
        if not 0 <= init < (1 << 64):
            raise ValueError("init must fit in 64 bits")

        out: set[Position] = set()
        for i, column in enumerate(self.columns):
            if (init >> i) & 1:
                out ^= column
        return out

    def decode(self, positions: set[Position] | list[Position]) -> int:
        """Recover the INIT value from the word-20 bits."""
        present = set(positions)
        value = 0
        for i, pos in self.direct.items():
            if pos in present:
                value |= 1 << i
        return value
