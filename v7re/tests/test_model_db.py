import sqlite3
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

import model  # noqa: E402
from db.import_model import build  # noqa: E402


def _make_p0(path: Path) -> None:
    c = sqlite3.connect(path)
    c.executescript(
        """
        CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT);
        CREATE TABLE site_types(type TEXT PRIMARY KEY, instances INTEGER,
            representative TEXT, template_json TEXT);
        CREATE TABLE site_bels(site_type TEXT, bel TEXT);
        CREATE TABLE site_bel_pins(site_type TEXT, bel TEXT, pin TEXT,
            direction TEXT, site_wire TEXT, site_pin TEXT);
        CREATE TABLE site_type_pips(site_type TEXT, name TEXT, bel TEXT,
            input_pin TEXT, output_pin TEXT, input_site_wire TEXT,
            output_site_wire TEXT);
        CREATE TABLE site_wires(site_type TEXT, wire TEXT, direction TEXT,
            is_site_pin INTEGER);
        CREATE TABLE site_instances(id INTEGER PRIMARY KEY, site TEXT,
            site_type TEXT, tile_name TEXT, tile_type TEXT, grid_x INTEGER,
            grid_y INTEGER, clock_region TEXT, instance_x INTEGER,
            instance_y INTEGER);
        CREATE TABLE site_pin_wires(site_id INTEGER, site_pin TEXT,
            direction TEXT, tile_wire TEXT);
        """
    )
    c.executemany(
        "INSERT INTO meta VALUES (?,?)",
        [("part", "xc7vx485tffg1761-2"), ("device", "dev")],
    )
    c.execute(
        "INSERT INTO site_types VALUES (?,?,?,?)",
        ("SLICEL", 1, "SLICE_X0Y0", '{"bels":[]}'),
    )
    c.execute("INSERT INTO site_bels VALUES ('SLICEL','A6LUT')")
    c.execute(
        "INSERT INTO site_bel_pins VALUES ('SLICEL','A6LUT','A1','input','A1','A1')"
    )
    c.execute(
        "INSERT INTO site_instances VALUES (1,'SLICE_X0Y0','SLICEL','CLBLL_L_X0Y0',"
        "'CLBLL_L',0,0,'X0Y0',0,0)"
    )
    c.execute(
        "INSERT INTO site_pin_wires VALUES (1,'A1','input','CLBLL_L_A1')"
    )
    c.commit()
    c.close()


def _make_probe_db(path: Path) -> None:
    c = sqlite3.connect(path)
    c.executescript(
        """
        CREATE TABLE probes(id INTEGER PRIMARY KEY, device TEXT, loc TEXT,
            bel TEXT, init_a TEXT, init_b TEXT, frames TEXT, bits TEXT,
            created_at TEXT);
        CREATE TABLE probe_bits(device TEXT, loc TEXT, bel TEXT, frame INTEGER,
            word INTEGER, bit INTEGER, init_a TEXT, init_b TEXT);
        """
    )
    c.execute(
        "INSERT INTO probes VALUES (1,'dev','SLICE_X0Y0','A6LUT','01','02',"
        "'[100,101]','{}','2026-01-01')"
    )
    c.execute(
        "INSERT INTO probe_bits VALUES ('dev','SLICE_X0Y0','A6LUT',100,20,15,'01','02')"
    )
    c.commit()
    c.close()


def _make_routing(path: Path) -> None:
    c = sqlite3.connect(path)
    c.executescript(
        """
        CREATE TABLE tiles(tile_name TEXT PRIMARY KEY, type TEXT, grid_x INTEGER,
            grid_y INTEGER, clock_region TEXT, wire_count INTEGER, pip_count INTEGER);
        CREATE TABLE tile_types(type TEXT PRIMARY KEY, instances INTEGER,
            wires INTEGER, pips INTEGER, uniform INTEGER, template TEXT,
            template_sha TEXT);
        """
    )
    c.execute("INSERT INTO tiles VALUES ('CLBLL_L_X0Y0','CLBLL_L',0,0,'X0Y0',10,5)")
    c.execute(
        "INSERT INTO tile_types VALUES ('CLBLL_L',1,10,5,1,'{}','sha')"
    )
    c.commit()
    c.close()


class ModelTests(unittest.TestCase):
    def test_build_and_query(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            root = Path(td)
            p0 = root / "p0.sqlite"
            probe = root / "probe.sqlite"
            routing = root / "routing.sqlite"
            out = root / "model.sqlite"
            _make_p0(p0)
            _make_probe_db(probe)
            _make_routing(routing)
            result = build(
                out=out,
                p0_db=p0,
                probe_db=probe,
                routing_db=routing,
                hash_sources=False,
                strict_counts=False,
            )
            self.assertEqual(result["counts"]["sites"], 1)
            self.assertEqual(result["counts"]["site_pins"], 1)
            self.assertEqual(result["counts"]["probes"], 1)
            conn = model.connect(out)
            try:
                self.assertEqual(model.site(conn, "SLICE_X0Y0")["tile"], "CLBLL_L_X0Y0")
                self.assertEqual(
                    model.site_pins(conn, "SLICE_X0Y0"),
                    [{"site_pin": "A1", "direction": "input", "tile_wire": "CLBLL_L_A1"}],
                )
                self.assertEqual(model.bel_pins(conn, "SLICE_X0Y0", "A6LUT")[0]["pin"], "A1")
                self.assertEqual(model.stats(conn)["bit_map"], 0)
            finally:
                conn.close()


if __name__ == "__main__":
    unittest.main()
