"""Unit tests for site table helpers (no Vivado)."""

from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from vivado.sites import _slice_coords


class SiteCoordTests(unittest.TestCase):
    def test_slice_coords(self) -> None:
        self.assertEqual(_slice_coords("SLICE_X10Y20"), (20, 10))
        self.assertEqual(_slice_coords("SLICE_X0Y0"), (0, 0))
        self.assertEqual(_slice_coords("SLICE_X221Y349"), (349, 221))
        self.assertEqual(_slice_coords("BRAM_X1Y2"), (None, None))


if __name__ == "__main__":
    unittest.main()
