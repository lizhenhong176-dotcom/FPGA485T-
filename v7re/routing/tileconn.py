"""Queryable canonical inter-tile connectivity (step 2).

The rule table was learned by observing every tile instance and encoding each
link as (source type, source wire, direction signs) plus a corridor: the
row-major tuple of tile types inside the rectangle spanned by both endpoints
grown by one cell (see step02/corridor.py).

At query time the tile map alone is enough to rebuild the corridor for any
candidate delta, so a link is resolved without RapidWright or Vivado:

    table = TileConn.load(rules_db, tiles_gz)
    for dst in table.edges("INT_L_X10Y20", "EE2BEG0"):
        print(dst.grid, dst.type, dst.wires)

`edges()` tries every (dx, dy) that the family ever used; a family has a small
delta set even when it has tens of thousands of corridor entries, so this stays
cheap.
"""

from __future__ import annotations

import csv
import gzip
import json
import sqlite3
from dataclasses import dataclass, field
from pathlib import Path

UNKNOWN = -1


@dataclass(frozen=True)
class Target:
    grid_x: int
    grid_y: int
    type: str
    wires: tuple[str, ...]


@dataclass
class _Family:
    deltas: list[tuple[int, int]] = field(default_factory=list)
    by_corridor: dict[str, tuple[int, int, str, tuple[str, ...]]] = field(default_factory=dict)


class TileMap:
    """Static tile grid: (grid_x, grid_y) -> type id, plus name lookup."""

    def __init__(self, tiles_gz: Path, types: list[str] | None = None):
        self.types: list[str] = list(types or [])
        self.tid: dict[str, int] = {t: i for i, t in enumerate(self.types)}
        self.cell: dict[tuple[int, int], int] = {}
        self.name: dict[tuple[int, int], str] = {}
        self.grid: dict[str, tuple[int, int]] = {}
        with gzip.open(tiles_gz, "rt", encoding="utf-8", newline="") as fh:
            for r in csv.DictReader(fh):
                t = r["type"]
                if t not in self.tid:
                    self.tid[t] = len(self.types)
                    self.types.append(t)
                key = (int(r["grid_x"]), int(r["grid_y"]))
                self.cell[key] = self.tid[t]
                self.name[key] = r["tile_name"]
                self.grid[r["tile_name"]] = key

    def corridor(self, gx: int, gy: int, dx: int, dy: int) -> str:
        x0, x1 = (gx, gx + dx) if dx >= 0 else (gx + dx, gx)
        y0, y1 = (gy, gy + dy) if dy >= 0 else (gy + dy, gy)
        cell = self.cell
        out = []
        for y in range(y0 - 1, y1 + 2):
            for x in range(x0 - 1, x1 + 2):
                out.append(cell.get((x, y), UNKNOWN))
        return ",".join(map(str, out))


class TileConn:
    def __init__(self, db_path: Path, tile_map: TileMap):
        self.map = tile_map
        self.con = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
        self._cache: dict[str, _Family] = {}

    @classmethod
    def load(cls, db_path: Path, tiles_gz: Path) -> "TileConn":
        import sqlite3 as _sql

        con = _sql.connect(f"file:{db_path}?mode=ro", uri=True)
        row = con.execute("SELECT v FROM meta WHERE k = 'types'").fetchone()
        con.close()
        types = json.loads(row[0]) if row else None
        return cls(Path(db_path), TileMap(Path(tiles_gz), types))

    def family(self, tile_type: str, wire: str, sx: int, sy: int) -> _Family:
        key = f"{tile_type}|{wire}|{sx}|{sy}"
        fam = self._cache.get(key)
        if fam is not None:
            return fam
        fam = _Family()
        for corridor, dx, dy, dst, wires in self.con.execute(
                "SELECT corridor, dx, dy, dst, wires FROM rules WHERE family = ?", (key,)):
            fam.by_corridor[corridor] = (dx, dy, dst, tuple(json.loads(wires)))
            fam.deltas.append((dx, dy))
        fam.deltas = sorted(set(fam.deltas))
        self._cache[key] = fam
        return fam

    def edges(self, tile_name: str, wire: str, deltas=None) -> list[Target]:
        pos = self.map.grid.get(tile_name)
        if pos is None or not self.map.name.get(pos):
            return []
        gx, gy = pos
        tile_type = self.map.types[self.map.cell[pos]]
        out: list[Target] = []
        for sx in (-1, 0, 1):
            for sy in (-1, 0, 1):
                if sx == 0 and sy == 0:
                    continue
                fam = self.family(tile_type, wire, sx, sy)
                if not fam.by_corridor:
                    continue
                for dx, dy in (deltas if deltas is not None else fam.deltas):
                    if (dx > 0) - (dx < 0) != sx or (dy > 0) - (dy < 0) != sy:
                        continue
                    entry = fam.by_corridor.get(self.map.corridor(gx, gy, dx, dy))
                    if entry is None:
                        continue
                    dx, dy, dst_type, wires = entry
                    tx, ty = gx + dx, gy + dy
                    if (tx, ty) not in self.map.cell:
                        continue
                    out.append(Target(tx, ty, dst_type, wires))
        return out

    def close(self) -> None:
        self.con.close()


class ExactEdges:
    """Ground-truth connectivity materialised from the device (no compression).

    Built by step02/dump_edges.py + step02/merge_edges.py into tables
    `edge_tiles`, `edge_wires` and `edges_exact` of the routing database.
    Every returned link is exactly what RapidWright reports, so this is the
    reference implementation; the corridor rules remain a compact index.
    """

    def __init__(self, con: sqlite3.Connection):
        self.con = con
        self.tiles: list[tuple[int, int, str, str]] = []
        self.tile_id: dict[str, int] = {}
        for i, gx, gy, name, tname in con.execute(
                "SELECT id, gx, gy, name, type FROM edge_tiles ORDER BY id"):
            self.tiles.append((int(gx), int(gy), name, tname))
            self.tile_id[name] = int(i)
        self.wires: dict[int, str] = {}
        self.wire_id: dict[str, int] = {}
        for i, name in con.execute("SELECT id, name FROM edge_wires ORDER BY id"):
            self.wires[int(i)] = name
            self.wire_id[name] = int(i)

    @classmethod
    def load(cls, db_path: Path) -> "ExactEdges":
        return cls(sqlite3.connect(f"file:{db_path}?mode=ro", uri=True))

    def edges(self, tile_name: str, wire: str) -> list[Target]:
        sid = self.tile_id.get(tile_name)
        wid = self.wire_id.get(wire)
        if sid is None or wid is None:
            return []
        out: list[Target] = []
        for dst_tile, dst_wire in self.con.execute(
                "SELECT dst_tile, dst_wire FROM edges_exact "
                "WHERE src_tile = ? AND src_wire = ?", (sid, wid)):
            gx, gy, _name, tname = self.tiles[int(dst_tile)]
            out.append(Target(gx, gy, tname, (self.wires[int(dst_wire)],)))
        return out

    def stats(self) -> dict:
        rows = self.con.execute("SELECT COUNT(*) FROM edges_exact").fetchone()[0]
        return {"tiles": len(self.tiles), "wires": len(self.wires), "edges": int(rows)}

    def close(self) -> None:
        self.con.close()
