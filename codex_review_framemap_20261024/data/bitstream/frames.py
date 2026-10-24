"""Frame-level comparison helpers."""

from __future__ import annotations

import struct
from pathlib import Path

from bitstream.parser import SYNC, frames_from_bit, frames_from_words
from config import FRAME_BYTES


def load_frames(path: str | Path) -> list[list[int]]:
    """Load frames from either a .bit/.bin bitstream or a raw frames file.

    `parse_bit.py` writes raw frames (no sync word), so this function must
    accept both formats.
    """
    p = Path(path)
    data = p.read_bytes()

    # A real bitstream has the sync word near the beginning (offset 0 for
    # .bin, ~150 for .bit).  Raw frames could contain the pattern by chance,
    # so only look at the first 512 bytes.
    if data[:512].find(SYNC) >= 0:
        return frames_from_bit(p)

    if len(data) % FRAME_BYTES:
        raise ValueError(
            f"{p} is neither a bitstream (no sync word) nor a raw frame file "
            f"(size {len(data)} is not a multiple of {FRAME_BYTES})"
        )

    n = len(data) // 4
    words = list(struct.unpack(f">{n}I", data[: n * 4]))
    return frames_from_words(words)


def diff_frame_indices(a: list[list[int]], b: list[list[int]]) -> list[int]:
    """Return frame indices whose 101-word contents differ."""
    n = min(len(a), len(b))
    return [i for i in range(n) if a[i] != b[i]]


def diff_bits_in_frame(
    a: list[list[int]],
    b: list[list[int]],
    frame: int,
) -> list[tuple[int, int]]:
    """Return (word, bit) positions that differ inside one frame.

    Bit numbering is LSB-first within each 32-bit word.
    """
    if frame >= min(len(a), len(b)):
        raise IndexError(f"frame {frame} out of range")

    positions: list[tuple[int, int]] = []
    for word in range(len(a[frame])):
        x = a[frame][word] ^ b[frame][word]
        while x:
            bit = (x & -x).bit_length() - 1
            positions.append((word, bit))
            x &= x - 1
    return positions
