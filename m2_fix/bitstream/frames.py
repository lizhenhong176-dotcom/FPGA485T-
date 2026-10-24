"""Frame-level comparison helpers."""

from __future__ import annotations

import hashlib
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
    """Return frame indices whose 101-word contents differ.

    Frame counts must match: silently comparing a truncated prefix would make
    a corrupted or partially-read bitstream look like a valid diff.
    """
    if len(a) != len(b):
        raise ValueError(
            f"frame count mismatch: {len(a)} vs {len(b)}"
        )
    return [i for i in range(len(a)) if a[i] != b[i]]


def frame_hash(frames: list[list[int]]) -> str:
    """Stable hash of the configuration frames, excluding the .bit header.

    The whole-file SHA-256 changes when Vivado writes a new build timestamp
    into the .bit header.  This hash covers only the 101-word frame payload,
    with explicit frame/word counts so two different shapes cannot collide.
    """
    h = hashlib.sha256()
    h.update(struct.pack(">I", len(frames)))
    for frame in frames:
        h.update(struct.pack(">I", len(frame)))
        h.update(struct.pack(">%dI" % len(frame), *frame))
    return h.hexdigest()


def diff_bits_in_frame(
    a: list[list[int]],
    b: list[list[int]],
    frame: int,
) -> list[tuple[int, int]]:
    """Return (word, bit) positions that differ inside one frame.

    Bit numbering is LSB-first within each 32-bit word.
    """
    if len(a) != len(b):
        raise ValueError(f"frame count mismatch: {len(a)} vs {len(b)}")
    if frame >= len(a):
        raise IndexError(f"frame {frame} out of range")

    positions: list[tuple[int, int]] = []
    for word in range(len(a[frame])):
        x = a[frame][word] ^ b[frame][word]
        while x:
            bit = (x & -x).bit_length() - 1
            positions.append((word, bit))
            x &= x - 1
    return positions
