import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from db.import_results import connect, import_probes, import_sites  # noqa: E402


def _result(loc: str, bel: str = "A6LUT") -> dict:
    return {
        "loc": loc,
        "bel": bel,
        "init_a": "01",
        "init_b": "02",
        "diff_frames": [100, 101],
        "bits": {"100": [[20, 15], [50, 0]], "101": [[20, 15], [50, 0]]},
    }


class ImportTests(unittest.TestCase):
    def test_import_probes_and_bits(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp_path = Path(td)
            probe_root = tmp_path / "probe"
            work = probe_root / "SLICE_X10Y10" / "A6LUT"
            work.mkdir(parents=True)
            (work / "result.json").write_text(
                json.dumps(_result("SLICE_X10Y10")), encoding="utf-8"
            )

            conn = connect(tmp_path / "v7.sqlite")
            try:
                counts = import_probes(conn, probe_root, "dev")
                self.assertEqual(counts, {"probes": 1, "bits": 4})
                self.assertEqual(
                    conn.execute("select count(*) from probes").fetchone()[0], 1
                )
                self.assertEqual(
                    conn.execute("select count(*) from probe_bits").fetchone()[0], 4
                )

                # Re-import must replace, not duplicate.
                import_probes(conn, probe_root, "dev")
                self.assertEqual(
                    conn.execute("select count(*) from probes").fetchone()[0], 1
                )
                self.assertEqual(
                    conn.execute("select count(*) from probe_bits").fetchone()[0], 4
                )
            finally:
                conn.close()

    def test_import_sites(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            tmp_path = Path(td)
            site_table = tmp_path / "sites.json"
            site_table.write_text(
                json.dumps(
                    {
                        "device": "dev",
                        "sites": [
                            {
                                "site": "SLICE_X0Y0",
                                "type": "SLICEL",
                                "clock_region": "X0Y0",
                                "row": 0,
                                "column": 0,
                            }
                        ],
                    }
                ),
                encoding="utf-8",
            )
            conn = connect(tmp_path / "v7.sqlite")
            try:
                self.assertEqual(import_sites(conn, site_table), 1)
                row = conn.execute(
                    "select site_type, row, col from sites"
                ).fetchone()
                self.assertEqual(row, ("SLICEL", 0, 0))
            finally:
                conn.close()


if __name__ == "__main__":
    unittest.main()
