"""Import site enumeration and clean-probe results into SQLite."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

HERE = Path(__file__).resolve().parent
SCHEMA = HERE / "schema.sql"


def connect(db_path: str | Path) -> sqlite3.Connection:
    """Open a database, creating its parent directory if needed."""
    path = Path(db_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(path)
    conn.executescript(SCHEMA.read_text(encoding="utf-8"))
    return conn


def import_sites(
    conn: sqlite3.Connection,
    site_table: str | Path,
    device: str | None = None,
) -> int:
    """Load a JSON site table produced by ``vivado/sites.py``."""
    data = json.loads(Path(site_table).read_text(encoding="utf-8"))
    dev = device or data.get("device") or data.get("part")
    if not dev:
        raise ValueError(f"{site_table}: table has no device/part field")
    rows = []
    for s in data.get("sites", []):
        rows.append(
            (
                dev,
                s["site"],
                s.get("type") or "",
                s.get("clock_region"),
                s.get("row"),
                s.get("column"),
            )
        )
    conn.executemany(
        "INSERT OR REPLACE INTO sites"
        " (device, site, site_type, clock_region, row, col)"
        " VALUES (?, ?, ?, ?, ?, ?)",
        rows,
    )
    conn.commit()
    return len(rows)


def _probe_rows(result: dict, device: str) -> tuple[tuple, list[tuple]]:
    loc = str(result["loc"])
    bel = str(result.get("bel") or "A6LUT")
    init_a = str(result.get("init_a") or "")
    init_b = str(result.get("init_b") or "")
    frames = [int(f) for f in result.get("diff_frames", [])]
    if not frames:
        raise ValueError(f"{loc}/{bel}: result has no diff_frames")
    bits = result.get("bits") or {}
    probe = (
        device,
        loc,
        bel,
        init_a,
        init_b,
        json.dumps(frames),
        json.dumps(bits),
    )
    bit_rows = []
    for frame_s, positions in bits.items():
        frame = int(frame_s)
        for word, bit in positions:
            bit_rows.append((device, loc, bel, frame, int(word), int(bit), init_a, init_b))
    return probe, bit_rows


def import_probes(
    conn: sqlite3.Connection,
    probe_root: str | Path,
    device: str,
    glob: str = "**/result.json",
    exclude: tuple[str, ...] = (),
) -> dict[str, int]:
    """Import every ``result.json`` under ``probe_root``.

    Re-importing the same ``(device, loc, bel)`` replaces its previous rows.
    ``exclude`` matches directory names anywhere under ``probe_root``.
    Returns counts of imported probes and bits.
    """
    root = Path(probe_root)
    if not root.exists():
        raise FileNotFoundError(root)
    valid_sites = {
        row[0]
        for row in conn.execute(
            "SELECT site FROM sites WHERE device=?", (device,)
        )
    }
    n_probes = n_bits = 0
    for path in sorted(root.glob(glob)):
        if any(part in exclude for part in path.parts):
            continue
        try:
            result = json.loads(path.read_text(encoding="utf-8"))
            probe, bit_rows = _probe_rows(result, device)
        except (OSError, ValueError, KeyError, TypeError) as exc:
            print(f"skip {path}: {exc}")
            continue
        loc, bel = probe[1], probe[2]
        if valid_sites and loc not in valid_sites:
            print(f"skip {path}: {loc} is not a legal site")
            continue
        conn.execute(
            "DELETE FROM probes WHERE device=? AND loc=? AND bel=?",
            (device, loc, bel),
        )
        conn.execute(
            "INSERT INTO probes"
            " (device, loc, bel, init_a, init_b, frames, bits)"
            " VALUES (?, ?, ?, ?, ?, ?, ?)",
            probe,
        )
        conn.execute(
            "DELETE FROM probe_bits WHERE device=? AND loc=? AND bel=?",
            (device, loc, bel),
        )
        conn.executemany(
            "INSERT OR REPLACE INTO probe_bits"
            " (device, loc, bel, frame, word, bit, init_a, init_b)"
            " VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            bit_rows,
        )
        n_probes += 1
        n_bits += len(bit_rows)

    if valid_sites:
        conn.execute(
            "DELETE FROM probes WHERE device=? AND loc NOT IN"
            " (SELECT site FROM sites WHERE device=?)",
            (device, device),
        )
        conn.execute(
            "DELETE FROM probe_bits WHERE device=? AND loc NOT IN"
            " (SELECT site FROM sites WHERE device=?)",
            (device, device),
        )
    conn.commit()
    return {"probes": n_probes, "bits": n_bits}
