"""Xilinx 7-series Frame Address Register (FAR) codec.

The 32-bit FAR is not a linear frame number.  It encodes the configuration
block type, top/bottom half, row, column and minor frame index.  The bit
positions below match the Xilinx 7-series bitstream format and the worked
example in Ge Hongyi's thesis (CLBLM_L_X8Y0 -> 0x00420400):

    bits 31..26  reserved (6)
    bits 25..23  block type (3)
    bit  22      top/bottom (1)
    bits 21..17  row (5)
    bits 16..7   column (10)
    bits 6..0    minor frame (7)

`decode`/`encode` are intentionally field-level only: mapping a FAR to a
physical tile still requires a device-specific frame map.
"""

from __future__ import annotations

from dataclasses import dataclass

FAR_MASK = 0xFFFFFFFF
MINOR_BITS = 7
COLUMN_BITS = 10
ROW_BITS = 5
TOP_BOTTOM_BITS = 1
BLOCK_TYPE_BITS = 3
RESERVED_BITS = 6

MINOR_SHIFT = 0
COLUMN_SHIFT = 7
ROW_SHIFT = 17
TOP_BOTTOM_SHIFT = 22
BLOCK_TYPE_SHIFT = 23
RESERVED_SHIFT = 26


@dataclass(frozen=True)
class FarAddress:
    block_type: int
    top_bottom: int
    row: int
    column: int
    minor: int
    reserved: int = 0

    @classmethod
    def decode(cls, value: int) -> "FarAddress":
        value = int(value) & FAR_MASK
        return cls(
            block_type=(value >> BLOCK_TYPE_SHIFT) & ((1 << BLOCK_TYPE_BITS) - 1),
            top_bottom=(value >> TOP_BOTTOM_SHIFT) & 0x1,
            row=(value >> ROW_SHIFT) & ((1 << ROW_BITS) - 1),
            column=(value >> COLUMN_SHIFT) & ((1 << COLUMN_BITS) - 1),
            minor=(value >> MINOR_SHIFT) & ((1 << MINOR_BITS) - 1),
            reserved=(value >> RESERVED_SHIFT) & ((1 << RESERVED_BITS) - 1),
        )

    def encode(self) -> int:
        for name, value, bits in (
            ("block_type", self.block_type, BLOCK_TYPE_BITS),
            ("top_bottom", self.top_bottom, TOP_BOTTOM_BITS),
            ("row", self.row, ROW_BITS),
            ("column", self.column, COLUMN_BITS),
            ("minor", self.minor, MINOR_BITS),
            ("reserved", self.reserved, RESERVED_BITS),
        ):
            if not 0 <= value < (1 << bits):
                raise ValueError(f"{name} out of range for {bits} bits: {value}")
        return (
            (self.reserved << RESERVED_SHIFT)
            | (self.block_type << BLOCK_TYPE_SHIFT)
            | (self.top_bottom << TOP_BOTTOM_SHIFT)
            | (self.row << ROW_SHIFT)
            | (self.column << COLUMN_SHIFT)
            | (self.minor << MINOR_SHIFT)
        ) & FAR_MASK

    def to_dict(self) -> dict[str, int]:
        return {
            "far": self.encode(),
            "block_type": self.block_type,
            "top_bottom": self.top_bottom,
            "row": self.row,
            "column": self.column,
            "minor": self.minor,
            "reserved": self.reserved,
        }

    def __str__(self) -> str:
        return (
            f"block={self.block_type} top={self.top_bottom} row={self.row} "
            f"col={self.column} minor={self.minor}"
        )
