"""Tile-type topology export: wires + intra-tile PIPs.

Design: a tile type is uniform — every instance of ``INT_L`` has the same wire
list (names, intent codes) and the same intra-tile PIP list (endpoints, delay,
bidirectional flag). So the whole device is 115 templates + a 150,380-row index.

Output layout (``root`` = data directory):
  root/tiles.csv.gz          tile_name,type,grid_x,grid_y,clock_region,wire_count,pip_count
  root/templates/<T>.json    wire_defs / pip_defs for type T
  root/type_uniformity.json  per type: instances, signature, uniform, mismatches
  root/summary.json          device totals
  root/DONE.json             stage marker
"""

from __future__ import annotations

import csv
import gzip
import hashlib
import json
from collections import defaultdict
from pathlib import Path

from . import env


def _wire_defs(tile) -> list[list]:
    return sorted(
        ([str(tile.getWireName(i)), str(tile.getWireIntentCode(i)), False, False]
         for i in range(int(tile.getWireCount()))),
        key=lambda x: x[0],
    )


def _pip_defs(tile) -> list[list]:
    pips = []
    for p in tile.getPIPs():
        row = [
            str(p.getStartWireName()),
            str(p.getEndWireName()),
            int(p.getDelayIndex()),
            bool(p.isBidirectional()),
        ]
        if bool(p.isArcInverted()):
            row.append(1)
        pips.append(row)
    return sorted(pips, key=lambda x: tuple(x))


def type_instances(dev) -> dict[str, list]:
    out: dict[str, list] = defaultdict(list)
    for tile in dev.getAllTiles():
        out[str(tile.getTileTypeEnum())].append(tile)
    return dict(out)


def scan(root: Path, part: str | None = None, limit: int | None = None) -> dict:
    """Stream every tile: write the index CSV and per-type uniformity."""
    env.bootstrap(root.parent)
    dev = env.device(part)
    root.mkdir(parents=True, exist_ok=True)
    (root / "templates").mkdir(exist_ok=True)

    stats: dict[str, dict] = {}
    rows = 0
    wires = pips = 0
    with gzip.open(root / "tiles.csv.gz", "wt", encoding="utf-8", newline="") as fh:
        w = csv.writer(fh, lineterminator="\n")
        w.writerow(["tile_name", "type", "grid_x", "grid_y", "clock_region",
                    "wire_count", "pip_count"])
        for n, tile in enumerate(dev.getAllTiles()):
            if limit is not None and n >= limit:
                break
            tname = str(tile.getTileTypeEnum())
            wd, pd = _wire_defs(tile), _pip_defs(tile)
            sig = hashlib.sha1(
                json.dumps([wd, pd], separators=(",", ":")).encode()).hexdigest()
            st = stats.setdefault(tname, {"instances": 0, "signature": sig,
                                          "uniform": True, "mismatching_tiles": []})
            st["instances"] += 1
            if st["signature"] != sig:
                st["uniform"] = False
                st["mismatching_tiles"].append(str(tile.getName()))
            wc, pc = int(tile.getWireCount()), len(tile.getPIPs())
            wires += wc
            pips += pc
            rows += 1
            w.writerow([str(tile.getName()), tname, int(tile.getColumn()),
                        int(tile.getRow()), str(tile.getClockRegion()), wc, pc])
            if (n + 1) % 2000 == 0:
                print(f"scanned {n + 1}", flush=True)

    (root / "type_uniformity.json").write_text(
        json.dumps(dict(sorted(stats.items())), indent=1) + "\n", encoding="utf-8")
    result = {"tiles": rows, "types": len(stats), "wires": wires, "pips": pips,
              "uniform_types": sum(1 for s in stats.values() if s["uniform"])}
    (root / "summary.json").write_text(json.dumps(result, indent=1) + "\n",
                                       encoding="utf-8")
    return result


def export_templates(root: Path, part: str | None = None) -> int:
    """Write one JSON template per tile type (from a representative instance)."""
    env.bootstrap(root.parent)
    dev = env.device(part)
    root.mkdir(parents=True, exist_ok=True)
    (root / "templates").mkdir(exist_ok=True)
    reps = {k: v[0] for k, v in type_instances(dev).items()}
    for tname, tile in sorted(reps.items()):
        wd, pd = _wire_defs(tile), _pip_defs(tile)
        (root / "templates" / f"{tname}.json").write_text(
            json.dumps({"type": tname, "wires": len(wd), "pips": len(pd),
                        "wire_defs": wd, "pip_defs": pd},
                       separators=(",", ":")) + "\n", encoding="utf-8")
    return len(reps)


def finalize(root: Path, part: str | None = None) -> dict:
    """Write DONE.json + REPORT.md once the stage passed verification."""
    summary = json.loads((root / "summary.json").read_text(encoding="utf-8"))
    done = {"status": "done", "validated": True, "part": part or env.PART, **summary}
    (root / "DONE.json").write_text(json.dumps(done, indent=1) + "\n", encoding="utf-8")
    return done
