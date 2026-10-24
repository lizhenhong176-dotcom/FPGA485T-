"""Inter-tile connectivity (the "tileconn" layer).

``Tile.getWireConnections(i)`` returns ``Wire`` objects on *other* tiles that
belong to the same physical net. That is the inter-tile edge set; it is not
translation-invariant, because a BEG wire's partner type depends on what the
neighbouring column happens to be (INT_L vs INT_R vs BRAM interface).

So the export keeps the raw observation per tile *type*, together with a
uniformity report that tells the next stage which types need per-instance
handling instead of a template.
"""

from __future__ import annotations

import json
import time
from collections import Counter
from pathlib import Path

from . import env


def export_connections(root: Path, part: str | None = None) -> dict:
    env.bootstrap(root.parent)
    dev = env.device(part)
    out = root / "conns"
    out.mkdir(parents=True, exist_ok=True)
    t0 = time.time()

    reps: dict[str, object] = {}
    for tile in dev.getAllTiles():
        reps.setdefault(str(tile.getTileTypeEnum()), tile)

    summary: dict[str, dict] = {}
    for i, (tname, tile) in enumerate(sorted(reps.items())):
        tx, ty = env.logical_xy(tile)
        table: dict[str, list] = {}
        hist: Counter = Counter()
        targets: Counter = Counter()
        for wi in range(int(tile.getWireCount())):
            wname = str(tile.getWireName(wi))
            links = []
            for w in tile.getWireConnections(wi):
                t2 = w.getTile()
                if t2 is None:
                    continue
                dx = env.logical_xy(t2)[0] - tx
                dy = env.logical_xy(t2)[1] - ty
                if dx == 0 and dy == 0:
                    continue
                links.append([dx, dy, str(t2.getTileTypeEnum()), str(w.getWireName())])
                hist[(dx, dy)] += 1
                targets[str(t2.getTileTypeEnum())] += 1
            if links:
                table[wname] = links
        (out / f"{tname}.json").write_text(
            json.dumps({"type": tname, "links": table}, separators=(",", ":")) + "\n",
            encoding="utf-8")
        summary[tname] = {
            "wires": int(tile.getWireCount()),
            "wires_with_external_links": len(table),
            "links": sum(len(v) for v in table.values()),
            "target_types": dict(targets.most_common(12)),
            "delta_histogram": {f"{dx},{dy}": c for (dx, dy), c
                                in sorted(hist.items(), key=lambda kv: -kv[1])[:12]},
        }
        print(f"[{i + 1}/{len(reps)}] {tname}: links={summary[tname]['links']}",
              flush=True)

    (out / "conns_summary.json").write_text(json.dumps(summary, indent=1) + "\n",
                                           encoding="utf-8")
    done = {"status": "done", "tile_types": len(reps),
            "seconds": round(time.time() - t0, 1),
            "total_links": sum(v["links"] for v in summary.values())}
    (out / "DONE_conns.json").write_text(json.dumps(done, indent=1) + "\n",
                                        encoding="utf-8")
    return done


def measure_uniformity(root: Path, part: str | None = None, per_type: int = 2,
                       seed: int = 7) -> dict:
    """Compare live connections with the per-type template for sampled tiles."""
    import random

    env.bootstrap(root.parent)
    dev = env.device(part)
    out = root / "conns"
    templates = {p.stem: json.loads(p.read_text(encoding="utf-8"))
                 for p in out.glob("*.json") if p.name != "conns_summary.json"}
    by_type = {}
    for tile in dev.getAllTiles():
        by_type.setdefault(str(tile.getTileTypeEnum()), []).append(tile)
    rng = random.Random(seed)

    stats = {"tiles": 0, "exact": 0, "mismatch_wires": 0, "total_wires": 0,
             "by_type": {}}
    for tname, insts in sorted(by_type.items()):
        tpl = templates.get(tname)
        if tpl is None:
            continue
        ok = 0
        picks = rng.sample(insts, min(len(insts), per_type))
        for tile in picks:
            stats["tiles"] += 1
            tx, ty = env.logical_xy(tile)
            live = {}
            for wi in range(int(tile.getWireCount())):
                links = set()
                for w in tile.getWireConnections(wi):
                    t2 = w.getTile()
                    if t2 is None:
                        continue
                    dx = env.logical_xy(t2)[0] - tx
                    dy = env.logical_xy(t2)[1] - ty
                    if dx == 0 and dy == 0:
                        continue
                    links.add((dx, dy, str(t2.getTileTypeEnum()), str(w.getWireName())))
                if links:
                    live[str(tile.getWireName(wi))] = links
            exp = {k: {tuple(x) for x in v} for k, v in tpl["links"].items()}
            stats["total_wires"] += len(live)
            bad = [wn for wn in live if live[wn] != exp.get(wn)]
            stats["mismatch_wires"] += len(bad)
            if not bad:
                ok += 1
                stats["exact"] += 1
        stats["by_type"][tname] = {"picked": len(picks), "exact": ok}
    stats["exact_types"] = sum(1 for v in stats["by_type"].values()
                               if v["exact"] == v["picked"])
    stats["types"] = len(stats["by_type"])
    return stats
