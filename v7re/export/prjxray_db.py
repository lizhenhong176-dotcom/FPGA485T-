"""Export the V7 topology model to prjxray-style database layout.

Inputs (local):
  E:\\v7work\\_curated_20261021\\routing\\v7_routing.db   (tiles / tileconn / edges)
  E:\\v7work\\_curated_20261021\\routing\\out_routing\\templates\\<TYPE>.json

Outputs:
  E:\\v7work\\db\\prjxray\\xc7vx485t\\
      tilegrid.json          {tile: {type, grid_x, grid_y}}
      tileconn.json          [{grid_deltas, tile_types, wire_pairs}]
      tile_type_<T>.json     {tile_type, wires, pips}
      manifest.json
"""

from __future__ import annotations

import collections
import json
import os
import sqlite3

DB = r"E:\v7work\_curated_20261021\routing\v7_routing.db"
TPL = r"E:\v7work\_curated_20261021\routing\out_routing\templates"
OUT = r"E:\v7work\db\prjxray\xc7vx485t"


def dump(obj, path: str) -> int:
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, ensure_ascii=False, separators=(",", ":"))
    return os.path.getsize(path)


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    con = sqlite3.connect(DB)
    stats = {}

    # --- tilegrid -------------------------------------------------------
    grid = {}
    for name, typ, gx, gy in con.execute(
        "SELECT tile_name, type, grid_x, grid_y FROM tiles"
    ):
        grid[name] = {"type": typ, "grid_x": gx, "grid_y": gy}
    stats["tilegrid"] = {"tiles": len(grid), "bytes": dump(grid, os.path.join(OUT, "tilegrid.json"))}

    # --- tileconn -------------------------------------------------------
    # tileconn(family = "SRC_TYPE|SRC_WIRE", dx, dy, dst_type, wires JSON)
    groups: dict[tuple, list] = collections.defaultdict(list)
    rows = 0
    for family, _corridor, dx, dy, dst_type, wires in con.execute(
        "SELECT family, corridor, dx, dy, dst_type, wires FROM tileconn"
    ):
        rows += 1
        try:
            src_type, src_wire = family.split("|")[0], family.split("|")[1]
            dst_wires = json.loads(wires)
        except Exception:  # noqa: BLE001
            continue
        key = (int(dx), int(dy), src_type, dst_type)
        for dw in dst_wires:
            groups[key].append([src_wire, dw])

    entries = [
        {
            "grid_deltas": [k[0], k[1]],
            "tile_types": [k[2], k[3]],
            "wire_pairs": sorted({tuple(p) for p in v}),
        }
        for k, v in sorted(groups.items())
    ]
    for e in entries:
        e["wire_pairs"] = [list(p) for p in e["wire_pairs"]]
    stats["tileconn"] = {
        "source_rows": rows,
        "entries": len(entries),
        "wire_pairs": sum(len(e["wire_pairs"]) for e in entries),
        "bytes": dump(entries, os.path.join(OUT, "tileconn.json")),
    }

    # --- tile types -----------------------------------------------------
    n_types = 0
    total_pips = 0
    for fn in os.listdir(TPL):
        if not fn.endswith(".json"):
            continue
        with open(os.path.join(TPL, fn), encoding="utf-8") as fh:
            tpl = json.load(fh)
        typ = tpl.get("type") or fn[:-5]
        wires = [w[0] for w in tpl.get("wire_defs", []) if w]
        pips = {}
        for p in tpl.get("pip_defs", []):
            src, dst = p[0], p[1]
            is_pseudo = bool(p[3]) if len(p) > 3 else False
            pips["%s.%s->%s" % (typ, src, dst)] = {
                "src_wire": src,
                "dst_wire": dst,
                "is_pseudo": "1" if is_pseudo else "0",
                "is_directional": "1",
                "can_invert": "0",
            }
        doc = {
            "tile_type": typ,
            "wires": {w: None for w in wires},
            "pips": pips,
            "sites": [],
        }
        dump(doc, os.path.join(OUT, "tile_type_%s.json" % typ.upper()))
        n_types += 1
        total_pips += len(pips)

    stats["tile_types"] = {"count": n_types, "pips": total_pips}

    stats["part"] = "xc7vx485tffg1761-2"
    stats["device"] = "xc7vx485t"
    stats["generator"] = "v7re/export/prjxray_db.py"
    stats["missing"] = [
        "segbits_<T>.db (needs fuzz results)",
        "ppips_<T>.db (site pips, partially in v7_model.sqlite)",
        "mask_<T>.db",
        "site_type_<S>.json",
    ]
    dump(stats, os.path.join(OUT, "manifest.json"))
    print(json.dumps(stats, indent=1))


if __name__ == "__main__":
    main()
