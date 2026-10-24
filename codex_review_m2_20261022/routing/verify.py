"""Independent acceptance checks for step 1.

Ground truth is always the live RapidWright device, never the exporter's own
bookkeeping. The hard-coded totals are canaries: they break loudly if the
RapidWright version or the part is wrong.
"""

from __future__ import annotations

import gzip
import csv
import hashlib
import json
import random
from pathlib import Path

from . import env

EXPECTED = {
    "xc7vx485tffg1761-2": {"tiles": 150380, "types": 115,
                           "wires": 56847864, "pips": 207253149},
}


def _fail(checks: list, ok: bool, msg: str) -> None:
    checks.append({"ok": bool(ok), "msg": msg})


def verify_topology(root: Path, part: str | None = None, samples: int = 40) -> dict:
    env.bootstrap(root.parent)
    dev = env.device(part)
    part = part or env.PART
    checks: list[dict] = []

    tiles = list(dev.getAllTiles())
    by_type: dict[str, list] = {}
    wires = pips = 0
    for t in tiles:
        by_type.setdefault(str(t.getTileTypeEnum()), []).append(t)
        wires += int(t.getWireCount())
        pips += len(t.getPIPs())

    exp = EXPECTED.get(part)
    if exp:
        _fail(checks, len(tiles) == exp["tiles"], f"tile count {len(tiles)} == {exp['tiles']}")
        _fail(checks, len(by_type) == exp["types"], f"type count {len(by_type)} == {exp['types']}")
        _fail(checks, wires == exp["wires"], f"wire count {wires} == {exp['wires']}")
        _fail(checks, pips == exp["pips"], f"pip count {pips} == {exp['pips']}")

    rows = list(csv.DictReader(gzip.open(root / "tiles.csv.gz", "rt",
                                         encoding="utf-8", newline="")))
    _fail(checks, len(rows) == len(tiles), f"tiles.csv rows {len(rows)} == {len(tiles)}")
    _fail(checks, len({r["tile_name"] for r in rows}) == len(rows), "tiles.csv names unique")
    _fail(checks, sum(int(r["wire_count"]) for r in rows) == wires,
          "tiles.csv wire sum matches device")
    _fail(checks, sum(int(r["pip_count"]) for r in rows) == pips,
          "tiles.csv pip sum matches device")

    tdir = root / "templates"
    tpl_files = sorted(tdir.glob("*.json"))
    _fail(checks, len(tpl_files) == len(by_type),
          f"template count {len(tpl_files)} == {len(by_type)}")

    broken = []
    for f in tpl_files:
        d = json.loads(f.read_text(encoding="utf-8"))
        names = {w[0] for w in d["wire_defs"]}
        if any(p[0] not in names or p[1] not in names for p in d["pip_defs"]):
            broken.append(f.name)
    _fail(checks, not broken, f"all pip endpoints defined in wire_defs ({broken[:3]})")

    bad_types = []
    for tname, insts in by_type.items():
        f = tdir / f"{tname}.json"
        if not f.exists():
            bad_types.append(tname)
            continue
        d = json.loads(f.read_text(encoding="utf-8"))
        if any(int(t.getWireCount()) != len(d["wire_defs"])
               or len(t.getPIPs()) != len(d["pip_defs"]) for t in insts):
            bad_types.append(tname)
    _fail(checks, not bad_types, f"all {len(by_type)} types uniform ({bad_types[:3]})")

    rng = random.Random(485)
    deep = []
    for _ in range(samples):
        tname = rng.choice(list(by_type))
        tile = rng.choice(by_type[tname])
        d = json.loads((tdir / f"{tname}.json").read_text(encoding="utf-8"))
        live = [[str(p.getStartWireName()), str(p.getEndWireName()),
                 int(p.getDelayIndex()), bool(p.isBidirectional())]
                for p in tile.getPIPs()]
        if sorted(live) != sorted(p[0:4] for p in d["pip_defs"]):
            deep.append(str(tile.getName()) + " pips")
        lw = [str(tile.getWireName(i)) for i in range(int(tile.getWireCount()))]
        if lw != [w[0] for w in d["wire_defs"]]:
            deep.append(str(tile.getName()) + " wires")
    _fail(checks, not deep, f"{samples} random instance(s) match templates ({deep[:3]})")

    uniform = json.loads((root / "type_uniformity.json").read_text(encoding="utf-8"))
    _fail(checks, len(uniform) == len(by_type), "type_uniformity.json covers all types")
    _fail(checks, all(v["uniform"] for v in uniform.values()), "every type marked uniform")

    done = root / "DONE.json"
    if done.exists():
        _fail(checks, json.loads(done.read_text(encoding="utf-8")).get("validated") is True,
              "DONE.json validated == true")

    failed = [c for c in checks if not c["ok"]]
    return {"ok": not failed, "checks": checks, "failed": len(failed),
            "samples": samples, "part": part}


def verify_connections(root: Path, part: str | None = None) -> dict:
    """Structural checks on the connections export (not uniformity)."""
    env.bootstrap(root.parent)
    dev = env.device(part)
    out = root / "conns"
    checks: list[dict] = []
    files = [p for p in out.glob("*.json") if p.stem in
             {str(t.getTileTypeEnum()) for t in dev.getAllTiles()}]
    types = {str(t.getTileTypeEnum()) for t in dev.getAllTiles()}
    _fail(checks, {p.stem for p in files} == types,
          f"connection template per tile type ({len(files)}/{len(types)})")

    broken = []
    total = 0
    for p in files:
        d = json.loads(p.read_text(encoding="utf-8"))
        for wire, links in d["links"].items():
            total += len(links)
            if any(len(x) != 4 for x in links):
                broken.append(f"{p.stem}/{wire}")
    _fail(checks, not broken, f"all link rows have 4 fields ({broken[:3]})")
    _fail(checks, total > 0, f"export contains {total} links")
    _fail(checks, (out / "DONE_conns.json").exists(), "DONE_conns.json exists")

    failed = [c for c in checks if not c["ok"]]
    return {"ok": not failed, "checks": checks, "failed": len(failed), "links": total}
