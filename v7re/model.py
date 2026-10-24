"""Query helpers for the canonical V7 model database.

Only stdlib is required.  The model DB keeps the P0 site boundary, probe
observations, and routing metadata; large routing edges stay in
``v7_routing.db`` and can be attached when needed.
"""

from __future__ import annotations

import sqlite3
from pathlib import Path

from config import PART

DEFAULT_DB = Path(r"E:\v7work\model\v7_model.sqlite")
DEFAULT_ROUTING_DB = Path(r"E:\v7work\_curated_20261021\routing\v7_routing.db")


def default_device(conn: sqlite3.Connection) -> str:
    row = conn.execute("SELECT value FROM meta WHERE key='device'").fetchone()
    return row[0] if row else PART


def connect(
    db_path: str | Path = DEFAULT_DB,
    routing_db: str | Path | None = None,
    *,
    read_only: bool = True,
) -> sqlite3.Connection:
    path = Path(db_path)
    if not path.exists():
        raise FileNotFoundError(path)
    if read_only:
        conn = sqlite3.connect(f"file:{path.as_posix()}?mode=ro", uri=True)
    else:
        conn = sqlite3.connect(str(path))
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys=ON")
    if routing_db is not None:
        rpath = Path(routing_db)
        if not rpath.exists():
            raise FileNotFoundError(rpath)
        conn.execute("ATTACH DATABASE ? AS routing", (str(rpath),))
    return conn


def site(conn: sqlite3.Connection, site_name: str, device: str | None = None) -> dict | None:
    if device is None:
        device = default_device(conn)
    row = conn.execute(
        "SELECT * FROM sites WHERE device=? AND site=?", (device, site_name)
    ).fetchone()
    return dict(row) if row else None


def site_pins(
    conn: sqlite3.Connection, site_name: str, device: str | None = None
) -> list[dict]:
    if device is None:
        device = default_device(conn)
    rows = conn.execute(
        "SELECT site_pin,direction,tile_wire FROM site_pins"
        " WHERE device=? AND site=? ORDER BY site_pin",
        (device, site_name),
    ).fetchall()
    return [dict(r) for r in rows]


def bel_pins(
    conn: sqlite3.Connection, site_name: str, bel: str, device: str | None = None
) -> list[dict]:
    s = site(conn, site_name, device)
    if not s:
        return []
    rows = conn.execute(
        "SELECT p.pin,p.direction,p.site_wire,p.site_pin"
        " FROM site_bel_pins p WHERE p.site_type=? AND p.bel=?"
        " ORDER BY p.pin",
        (s["site_type"], bel),
    ).fetchall()
    return [dict(r) for r in rows]


def tile(conn: sqlite3.Connection, tile_name: str) -> dict | None:
    row = conn.execute("SELECT * FROM tiles WHERE tile_name=?", (tile_name,)).fetchone()
    return dict(row) if row else None


def stats(conn: sqlite3.Connection) -> dict[str, int]:
    tables = (
        "sites",
        "site_types",
        "site_bels",
        "site_bel_pins",
        "site_type_pips",
        "site_wires",
        "site_pins",
        "tiles",
        "tile_types",
        "probes",
        "probe_bits",
        "region_bases",
        "column_offsets",
        "site_frames",
        "bit_map",
        "pip_bits",
        "stages",
        "artifacts",
    )
    out = {}
    for table in tables:
        out[table] = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    return out
