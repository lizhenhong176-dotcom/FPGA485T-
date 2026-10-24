"""Parse a Xilinx 7-series .bit / .bin file into configuration frames."""

from __future__ import annotations

import struct
from dataclasses import dataclass, field
from pathlib import Path

from config import FRAME_WORDS

SYNC = b"\xAA\x99\x55\x66"

FAR = 0x01
FDRI = 0x02
CMD = 0x04


@dataclass
class Bitstream:
    path: Path
    sync_offset: int
    payload_words: list[int]
    far_starts: list[tuple[int, int]] = field(default_factory=list)
    commands: list[tuple[int, int]] = field(default_factory=list)
    frame_count: int = 0
    leftover: int = 0
    file_size: int = 0


def _unpack_words(data: bytes) -> list[int]:
    n = len(data) // 4
    if n == 0:
        return []
    return list(struct.unpack(f">{n}I", data[: n * 4]))


def parse_bit(path: str | Path) -> Bitstream:
    """Parse a 7-series bitstream.

    The parser walks Type 1 / Type 2 packets, tracks FAR, and concatenates
    every FDRI payload into a single word stream.  Frames are split later
    at FRAME_WORDS boundaries.
    """
    p = Path(path)
    data = p.read_bytes()
    pos = data.find(SYNC)
    if pos < 0:
        raise ValueError(f"sync word not found in {p}")

    words = _unpack_words(data[pos + 4:])

    payload: list[int] = []
    far_starts: list[tuple[int, int]] = []
    commands: list[tuple[int, int]] = []
    far = 0
    i = 0

    while i < len(words):
        header = words[i]
        i += 1

        typ = (header >> 29) & 0x7
        op = (header >> 27) & 0x3
        addr = (header >> 13) & 0x3FFF
        cnt = header & 0x7FF

        if typ == 2:
            n = header & 0x7FFFFFF
            payload.extend(words[i:i + n])
            i += n
            continue

        if typ != 1:
            break

        if op == 0:  # NOP
            continue

        if op == 1:  # READ: one word follows
            i += 1
            continue

        # op == 2: WRITE
        if addr == FAR:
            if cnt:
                far = words[i]
            i += cnt
        elif addr == FDRI:
            far_starts.append((len(payload), far))
            if cnt == 0:
                type2 = words[i]
                i += 1
                if ((type2 >> 29) & 0x7) != 2:
                    raise ValueError(
                        f"expected Type 2 packet at word {i - 1}: 0x{type2:08X}"
                    )
                n = type2 & 0x7FFFFFF
                payload.extend(words[i:i + n])
                i += n
            else:
                payload.extend(words[i:i + cnt])
                i += cnt
        elif addr == CMD:
            if cnt:
                commands.append((words[i], len(payload)))
            i += cnt
        else:
            i += cnt

    frame_count = len(payload) // FRAME_WORDS
    leftover = len(payload) % FRAME_WORDS

    return Bitstream(
        path=p,
        sync_offset=pos,
        payload_words=payload,
        far_starts=far_starts,
        commands=commands,
        frame_count=frame_count,
        leftover=leftover,
        file_size=len(data),
    )


def frames_from_words(payload: list[int]) -> list[list[int]]:
    """Split a contiguous FDRI payload into 101-word frames."""
    return [
        payload[k * FRAME_WORDS:(k + 1) * FRAME_WORDS]
        for k in range(len(payload) // FRAME_WORDS)
    ]


def frames_from_bit(path: str | Path) -> list[list[int]]:
    """Parse a bitstream and return its frames."""
    return frames_from_words(parse_bit(path).payload_words)
