import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.far import FarAddress  # noqa: E402


class FarTests(unittest.TestCase):
    def test_decode_literature_base(self) -> None:
        far = FarAddress.decode(0x00420400)
        self.assertEqual(
            (far.block_type, far.top_bottom, far.row, far.column, far.minor),
            (0, 1, 1, 8, 0),
        )

    def test_decode_minor_32(self) -> None:
        far = FarAddress.decode(0x004203A0)
        self.assertEqual(
            (far.block_type, far.top_bottom, far.row, far.column, far.minor),
            (0, 1, 1, 7, 32),
        )

    def test_roundtrip(self) -> None:
        for value in (0x00420400, 0x004203A0, 0x00000000, 0xFFFFFFFF):
            far = FarAddress.decode(value)
            self.assertEqual(far.encode(), value)

    def test_field_range(self) -> None:
        with self.assertRaises(ValueError):
            FarAddress(block_type=8, top_bottom=0, row=0, column=0, minor=0).encode()
        with self.assertRaises(ValueError):
            FarAddress(block_type=0, top_bottom=0, row=0, column=1024, minor=0).encode()


if __name__ == "__main__":
    unittest.main()
