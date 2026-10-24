import sqlite3
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

from db.audit import audit_word_positions, expected_word  # noqa: E402


class AuditTests(unittest.TestCase):
    def test_expected_word(self) -> None:
        self.assertEqual(expected_word(0), 0)
        self.assertEqual(expected_word(10), 20)
        self.assertEqual(expected_word(24), 48)
        self.assertEqual(expected_word(25), 51)
        self.assertEqual(expected_word(35), 71)
        self.assertEqual(expected_word(54), 8)
        self.assertEqual(expected_word(160), 20)

    def test_audit_detects_bad_word(self) -> None:
        conn = sqlite3.connect(":memory:")
        conn.execute("CREATE TABLE sites (device TEXT, site TEXT, row INTEGER)")
        conn.execute("CREATE TABLE probes (device TEXT, loc TEXT, bel TEXT)")
        conn.execute(
            "CREATE TABLE probe_bits (device TEXT, loc TEXT, bel TEXT, word INTEGER)"
        )
        conn.execute("INSERT INTO sites VALUES ('dev','SLICE_X0Y10',10)")
        conn.execute("INSERT INTO probes VALUES ('dev','SLICE_X0Y10','A6LUT')")
        conn.executemany(
            "INSERT INTO probe_bits VALUES ('dev','SLICE_X0Y10','A6LUT',?)",
            [(20,), (50,)],
        )
        errors, checked = audit_word_positions(conn)
        self.assertEqual(errors, [])
        self.assertEqual(checked, 1)

        conn.execute("UPDATE probe_bits SET word = 21 WHERE word = 20")
        errors, checked = audit_word_positions(conn)
        self.assertEqual(checked, 1)
        self.assertEqual(len(errors), 1)
        self.assertIn("word 21, expected 20", errors[0])
        conn.close()


if __name__ == "__main__":
    unittest.main()
