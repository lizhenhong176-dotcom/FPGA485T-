"""Cross-check P0 site-pin tile wires against the routing tile templates.

This is the boundary check that matters before netlist tracing: every site pin
must name a tile wire that actually exists in the same tile type's routing
template.  A prefix-based export can look plausible yet invent wire names; this
validator catches that.

Inputs:
  p0/site_instances.csv
  p0/site_pin_wires.csv.gz
  routing/out_routing/templates/*.json   (wire_defs[0] is the wire name)
"""

from __future__ import annotations

import argparse
import collections
import csv
import gzip
import json
from pathlib import Path

DEFAULT_P0 = Path(r"E:\v7work\p0")
DEFAULT_ROUTING = Path(r"E:\v7work\_curated_20261021\routing")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--p0", default=str(DEFAULT_P0))
    ap.add_argument("--routing", default=str(DEFAULT_ROUTING))
    ap.add_argument("--out", default="")
    args = ap.parse_args()

    p0 = Path(args.p0)
    routing = Path(args.routing)
    templates_dir = routing / "out_routing" / "templates"
    if not templates_dir.is_dir():
        raise SystemExit(f"missing templates dir: {templates_dir}")

    site_tile_type = {}
    with (p0 / "site_instances.csv").open(encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            site_tile_type[row["site"]] = row["tile_type"]

    wire_sets = {}
    for path in sorted(templates_dir.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        wire_sets[data["type"]] = {str(w[0]) for w in data["wire_defs"]}
    print(f"routing templates: {len(wire_sets)}; sites: {len(site_tile_type)}", flush=True)

    missing_template = collections.Counter()
    missing_wire = collections.Counter()
    samples = []
    n = 0
    per_type = collections.Counter()
    with gzip.open(p0 / "site_pin_wires.csv.gz", "rt", encoding="utf-8", newline="") as f:
        for row in csv.DictReader(f):
            n += 1
            tile_type = site_tile_type.get(row["site"])
            if tile_type is None:
                missing_template["<no_site>"] += 1
                continue
            wires = wire_sets.get(tile_type)
            if wires is None:
                missing_template[tile_type] += 1
                continue
            per_type[tile_type] += 1
            if row["tile_wire"] not in wires:
                missing_wire[tile_type] += 1
                if len(samples) < 50:
                    samples.append(
                        {
                            "site": row["site"],
                            "site_pin": row["site_pin"],
                            "tile_wire": row["tile_wire"],
                            "tile_type": tile_type,
                        }
                    )
            if n % 1000000 == 0:
                print(f"checked {n}", flush=True)

    result = {
        "passed": not missing_template and not missing_wire,
        "site_pin_wires": n,
        "templates": len(wire_sets),
        "missing_template": dict(missing_template),
        "missing_wire": dict(missing_wire),
        "missing_wire_total": sum(missing_wire.values()),
        "samples": samples,
        "checked_per_tile_type": dict(sorted(per_type.items())),
    }
    out = Path(args.out) if args.out else p0 / "routing_wire_validation.json"
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(
        f"checked={n} missing_template={sum(missing_template.values())} "
        f"missing_wire={sum(missing_wire.values())} PASS={result['passed']}",
        flush=True,
    )
    print(f"out: {out}", flush=True)
    return 0 if result["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
