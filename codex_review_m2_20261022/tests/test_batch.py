"""Unit tests for manifest parsing and dry-run batch behavior (no Vivado)."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from vivado.batch import BatchItem, item_workdir, load_manifest, run_batch, safe_site_dir


class ManifestTests(unittest.TestCase):
    def test_csv_defaults_and_hex_normalization(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "m.csv"
            path.write_text(
                "loc,bel,init_a,init_b,tags\n"
                "SLICE_X1Y2,A6LUT,000000000000000a,,x\n",
                encoding="utf-8",
            )
            items = load_manifest(path)
            self.assertEqual(len(items), 1)
            self.assertEqual(items[0].loc, "SLICE_X1Y2")
            self.assertEqual(items[0].init_a, "000000000000000A")
            self.assertEqual(items[0].init_b, "0000000000000002")
            self.assertEqual(items[0].tags, "x")

    def test_json_dict_items(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "m.json"
            path.write_text(
                json.dumps({"items": [{"site": "SLICE_X9Y9"}, {"loc": "SLICE_X8Y8", "bel": "B6LUT"}]}),
                encoding="utf-8",
            )
            items = load_manifest(path)
            self.assertEqual([i.loc for i in items], ["SLICE_X9Y9", "SLICE_X8Y8"])
            self.assertEqual(items[0].bel, "A6LUT")
            self.assertEqual(items[1].bel, "B6LUT")

    def test_bad_init_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "m.csv"
            path.write_text("loc,init_a\nSLICE_X1Y1,1234\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                load_manifest(path)

    def test_safe_dir_and_workdir(self) -> None:
        self.assertEqual(safe_site_dir("SLICE_X1Y2"), "SLICE_X1Y2")
        self.assertEqual(safe_site_dir("BRAM:X1Y2"), "BRAM_X1Y2")
        root = Path("E:/v7work/probe")
        self.assertEqual(
            item_workdir(BatchItem("SLICE_X1Y2"), root),
            root / "SLICE_X1Y2" / "A6LUT",
        )
        self.assertEqual(
            item_workdir(BatchItem("SLICE_X1Y2", workdir="custom"), root),
            root / "custom",
        )

    def test_dry_run_writes_summary_and_skips_existing(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            tmp_path = Path(tmp)
            manifest = tmp_path / "m.csv"
            manifest.write_text(
                "loc,bel\nSLICE_X1Y1,A6LUT\nSLICE_X2Y2,A6LUT\n", encoding="utf-8"
            )
            done = tmp_path / "probe" / "SLICE_X1Y1" / "A6LUT"
            done.mkdir(parents=True)
            (done / "result.json").write_text('{"diff_frames": [1]}', encoding="utf-8")
            out = tmp_path / "batch.json"
            summary = run_batch(
                manifest,
                out=out,
                workdir_root=tmp_path / "probe",
                dry_run=True,
            )
            self.assertEqual(summary["counts"]["skipped"], 1)
            self.assertEqual(summary["counts"]["planned"], 1)
            self.assertTrue(out.exists())
            self.assertEqual(summary["counts"]["total"], 2)


if __name__ == "__main__":
    unittest.main()
