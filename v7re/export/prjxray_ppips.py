"""Emit prjxray-style ppips_<tile_type>.db from the V7 model database.

ppips format (see prjxray/tile_segbits.py::read_ppips):
    <feature> <always|default|hint>

For 7-series site-internal pseudo pips prjxray uses "default"; we emit the
same conservative value and record the choice in the manifest.
"""

from __future__ import annotations

import collections
import json
import os
import sqlite3

DB = r"E:\v7work\model\v7_model.sqlite"
OUT = r"E:\v7work\db\prjxray\xc7vx485t"


def main() -> None:
    con = sqlite3.connect(DB)

    # site_type -> tile types that instantiate it
    site_to_tiles = collections.defaultdict(set)
    for site_type, tile_type in con.execute(
        "SELECT DISTINCT site_type, tile_type FROM sites"
    ):
        site_to_tiles[site_type].add(tile_type)

    # site_type -> [(name, bel, in_wire, out_wire)]
    pips = collections.defaultdict(list)
    for site_type, name, bel, _ip, _op, iw, ow in con.execute(
        "SELECT site_type, name, bel, input_pin, output_pin, "
        "input_site_wire, output_site_wire FROM site_type_pips"
    ):
        pips[site_type].append((name, bel, iw, ow))

    tile_types = [r[0] for r in con.execute("SELECT type FROM tile_types ORDER BY type")]
    written = 0
    total_lines = 0
    per_type = {}
    for tt in tile_types:
        lines = []
        for site_type, members in site_to_tiles.items():
            if tt not in members:
                continue
            for _name, _bel, iw, ow in pips.get(site_type, []):
                if iw and ow:
                    lines.append("%s.%s.%s hint" % (tt, iw, ow))
        if not lines:
            continue
        # dedupe, keep order
        lines = list(dict.fromkeys(lines))
        path = os.path.join(OUT, "ppips_%s.db" % tt.lower())
        with open(path, "w", encoding="utf-8") as fh:
            fh.write("\n".join(lines) + "\n")
        written += 1
        total_lines += len(lines)
        per_type[tt] = len(lines)

    manifest_path = os.path.join(OUT, "manifest.json")
    man = json.load(open(manifest_path, encoding="utf-8")) if os.path.exists(manifest_path) else {}
    man["ppips"] = {
        "files": written,
        "lines": total_lines,
        "ppip_type": "hint",
        "semantics": "site pin -> BEL input mux (rapidwright site_type_pips); NOT prjxray site-wire pseudo pips",
        "per_type_sample": dict(sorted(per_type.items())[:10]),
    }
    with open(manifest_path, "w", encoding="utf-8") as fh:
        json.dump(man, fh, ensure_ascii=False, indent=1)
    print(json.dumps(man["ppips"], indent=1))


if __name__ == "__main__":
    main()

