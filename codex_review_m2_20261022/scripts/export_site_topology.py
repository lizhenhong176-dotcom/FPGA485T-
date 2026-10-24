"""Export P0 site-level static topology for V485T from RapidWright.

The P0 contract is deliberately narrower than the tilegrid:

  site instance -> tile
  site pin      -> tile wire
  BEL pin       -> site wire
  site PIP      -> site wire edge

Routing wires/PIPs between tiles are *not* re-exported here; they are already
covered by the routing database.  This script closes the site boundary so a
netlist tracer can enter/leave a site without guessing a wire prefix.

Inputs (curated static topology):
  topology/tilegrid.json   prjxray-shaped tilegrid; its `sites` map is the
                           authoritative fabric/visible site set (86,022).
  topology/sites.csv       site -> tile/grid/clock-region metadata.

Outputs (default E:\\v7work\\p0):
  site_types.json          per-site-type BEL/PIP/site-wire templates
  site_instances.csv       every fabric site instance
  site_pin_wires.csv.gz    every site pin -> tile wire mapping
  validation.json          counts, hashes, template/sample checks

The site-pin mapping is exported per instance, not as a prefix formula.  A
prefix formula is not reliable: e.g. SLICEL/CLBLL_L uses both CLBLL_LL_* and
CLBLL_L_* prefixes, and DSP_L uses DSP_0_* / DSP_1_*.
"""

from __future__ import annotations

import argparse
import collections
import csv
import gzip
import hashlib
import json
import os
import sys
import time
from pathlib import Path

DEFAULT_TOPO = Path(r"E:\v7work\_curated_20261021\topology")
DEFAULT_OUT = Path(r"E:\v7work\p0")
DEFAULT_PART = "xc7vx485tffg1761-2"
DEFAULT_DEVICE = "xc7vx485t"
JDK = Path(r"E:\tools\jdk17\jdk-17.0.20.1+1")


def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def ensure_java() -> None:
    """RapidWright needs a 64-bit JDK; the project JDK is bundled on E:."""
    if os.environ.get("JAVA_HOME"):
        return
    if JDK.is_dir():
        os.environ["JAVA_HOME"] = str(JDK)
        os.environ["PATH"] = str(JDK / "bin") + os.pathsep + os.environ.get("PATH", "")


def load_fabric(topo: Path):
    tilegrid = json.loads((topo / "tilegrid.json").read_text(encoding="utf-8"))
    rows = {
        r["site_name"]: r
        for r in csv.DictReader((topo / "sites.csv").open(encoding="utf-8", newline=""))
    }
    fabric: dict[str, str] = {}
    for tile_name, tile in tilegrid.items():
        for site_name, site_type in (tile.get("sites") or {}).items():
            if site_name in fabric:
                raise SystemExit(f"duplicate site in tilegrid: {site_name}")
            if site_name not in rows:
                raise SystemExit(f"site missing from sites.csv: {site_name}")
            fabric[site_name] = str(site_type)
    return tilegrid, rows, fabric


def jstr(value) -> str:
    return "" if value is None else str(value)


def wire_direction(site, wire: str, is_pin: bool) -> str:
    if not is_pin:
        return "internal"
    try:
        if site.isInputPin(wire):
            return "input"
        if site.isOutputPin(wire):
            return "output"
    except Exception:
        return "unknown"
    return "unknown"


def bel_direction(pin) -> str:
    is_in = bool(pin.isInput())
    is_out = bool(pin.isOutput())
    if is_in and is_out:
        return "inout"
    if is_in:
        return "input"
    if is_out:
        return "output"
    return "unknown"


def build_template(site, site_type: str, representative: str) -> dict:
    site_name = jstr(site.getName())
    bels = []
    for bel in site.getBELs():
        pins = []
        for pin in bel.getPins():
            pins.append(
                {
                    "name": jstr(pin.getName()),
                    "direction": bel_direction(pin),
                    "site_wire": jstr(pin.getSiteWireName()),
                    "site_pin": jstr(pin.getConnectedSitePinName()),
                }
            )
        pins.sort(key=lambda p: p["name"])
        bels.append({"name": jstr(bel.getName()), "pins": pins})
    bels.sort(key=lambda b: b["name"])

    pips = []
    for pip in site.getSitePIPs():
        in_pin = pip.getInputPin()
        out_pin = pip.getOutputPin()
        name = jstr(pip.getName(site))
        prefix = site_name + "/"
        if name.startswith(prefix):
            name = name[len(prefix):]
        pips.append(
            {
                "name": name,
                "bel": jstr(pip.getBELName()),
                "input_pin": jstr(pip.getInputPinName()),
                "output_pin": jstr(pip.getOutputPinName()),
                "input_site_wire": jstr(in_pin.getSiteWireName()) if in_pin is not None else "",
                "output_site_wire": jstr(out_pin.getSiteWireName()) if out_pin is not None else "",
            }
        )
    pips.sort(key=lambda p: (p["bel"], p["name"]))

    wires = []
    pins = []
    for wire in site.getSiteWireNames():
        wire = jstr(wire)
        tile_wire = site.getTileWireNameFromPinName(wire)
        is_pin = tile_wire is not None
        direction = wire_direction(site, wire, is_pin)
        wires.append({"name": wire, "direction": direction, "is_site_pin": bool(is_pin)})
        if is_pin:
            pins.append({"name": wire, "direction": direction})
    wires.sort(key=lambda w: w["name"])
    pins.sort(key=lambda p: p["name"])

    return {
        "type": site_type,
        "representative": representative,
        "bels": bels,
        "site_pips": pips,
        "site_wires": wires,
        "site_pins": pins,
    }


def template_digest(template: dict) -> str:
    payload = {
        "bels": template["bels"],
        "site_pips": template["site_pips"],
        "site_wires": template["site_wires"],
    }
    return hashlib.sha256(
        json.dumps(payload, sort_keys=True, separators=(",", ":")).encode("utf-8")
    ).hexdigest()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--topology", default=str(DEFAULT_TOPO))
    ap.add_argument("--out", default=str(DEFAULT_OUT))
    ap.add_argument("--part", default=DEFAULT_PART)
    ap.add_argument("--device", default=DEFAULT_DEVICE)
    ap.add_argument("--samples-per-type", type=int, default=5)
    args = ap.parse_args()

    topo = Path(args.topology)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    ensure_java()
    import rapidwright  # noqa: F401  (must precede com.xilinx imports)
    from com.xilinx.rapidwright.device import Device

    started = time.time()
    tilegrid, rows, fabric = load_fabric(topo)
    by_type: dict[str, list[str]] = collections.defaultdict(list)
    for site_name, site_type in fabric.items():
        by_type[site_type].append(site_name)
    for names in by_type.values():
        names.sort()

    print(f"fabric sites: {len(fabric)}; types: {len(by_type)}", flush=True)
    device = Device.getDevice(args.part)
    if device is None:
        raise SystemExit(f"RapidWright cannot load part {args.part}")

    templates: dict[str, dict] = {}
    for site_type in sorted(by_type):
        names = by_type[site_type]
        rep = names[0]
        site = device.getSite(rep)
        if site is None:
            raise SystemExit(f"RapidWright cannot load site {rep}")
        tpl = build_template(site, site_type, rep)
        tpl["instances"] = len(names)
        tpl["tile_types"] = sorted({rows[n]["tile_name"].split("_X")[0] for n in names[:50]})
        templates[site_type] = tpl
        print(
            f"template {site_type:22s} n={len(names):6d} rep={rep} "
            f"bels={len(tpl['bels'])} pips={len(tpl['site_pips'])} pins={len(tpl['site_pins'])}",
            flush=True,
        )

    # Sample check: a site type should describe every instance of that type.
    sample_checks = []
    sample_mismatches = []
    for site_type in sorted(by_type):
        if args.samples_per_type <= 0:
            break
        tpl_digest = template_digest(templates[site_type])
        names = by_type[site_type]
        step = max(1, len(names) // args.samples_per_type)
        for idx in range(0, len(names), step):
            if len(sample_checks) >= args.samples_per_type * len(by_type):
                break
            site_name = names[idx]
            site = device.getSite(site_name)
            got = template_digest(build_template(site, site_type, site_name))
            sample_checks.append(site_name)
            if got != tpl_digest:
                sample_mismatches.append(site_name)
    print(f"template samples: {len(sample_checks)}; mismatches: {len(sample_mismatches)}", flush=True)

    instances_path = out / "site_instances.csv"
    pins_path = out / "site_pin_wires.csv.gz"
    pin_count = 0
    count_mismatches = []
    pin_set_mismatches = []
    seen = set()
    t0 = time.time()

    with instances_path.open("w", encoding="utf-8", newline="") as fi, gzip.open(
        pins_path, "wt", encoding="utf-8", newline=""
    ) as fp:
        wi = csv.writer(fi)
        wp = csv.writer(fp)
        wi.writerow(
            ["site", "site_type", "tile_name", "tile_type", "grid_x", "grid_y", "clock_region", "instance_x", "instance_y"]
        )
        wp.writerow(["site", "site_pin", "direction", "tile_wire"])

        for n, site_name in enumerate(sorted(fabric)):
            if site_name in seen:
                raise SystemExit(f"duplicate site instance: {site_name}")
            seen.add(site_name)
            site_type = fabric[site_name]
            row = rows[site_name]
            site = device.getSite(site_name)
            if site is None:
                raise SystemExit(f"RapidWright cannot load site {site_name}")
            tile = site.getTile()
            tile_type = jstr(tile.getTileTypeEnum())
            wi.writerow(
                [
                    site_name,
                    site_type,
                    jstr(row["tile_name"]),
                    tile_type,
                    row["grid_x"],
                    row["grid_y"],
                    row["clock_region"],
                    row["instance_x"],
                    row["instance_y"],
                ]
            )

            tpl = templates[site_type]
            n_bels = len(site.getBELs())
            n_pips = len(site.getSitePIPs())
            if n_bels != len(tpl["bels"]) or n_pips != len(tpl["site_pips"]):
                count_mismatches.append(
                    {"site": site_name, "type": site_type, "bels": n_bels, "pips": n_pips}
                )

            actual_pins = []
            for wire in site.getSiteWireNames():
                wire = jstr(wire)
                tw = site.getTileWireNameFromPinName(wire)
                if tw is None:
                    continue
                is_pin = True
                direction = wire_direction(site, wire, is_pin)
                actual_pins.append(wire)
                wp.writerow([site_name, wire, direction, jstr(tw)])
                pin_count += 1
            expected = {p["name"] for p in tpl["site_pins"]}
            if set(actual_pins) != expected:
                pin_set_mismatches.append(
                    {
                        "site": site_name,
                        "type": site_type,
                        "missing": sorted(expected - set(actual_pins))[:10],
                        "extra": sorted(set(actual_pins) - expected)[:10],
                    }
                )

            if n and n % 10000 == 0:
                print(
                    f"instances {n}/{len(fabric)} pins {pin_count} "
                    f"({time.time() - t0:.1f}s)",
                    flush=True,
                )

    for tpl in templates.values():
        tpl["tile_types"] = sorted(
            {
                rows[n]["tile_name"].split("_X")[0]
                for n in by_type[tpl["type"]][:50]
            }
        )

    types_path = out / "site_types.json"
    types_path.write_text(
        json.dumps(
            {
                "part": args.part,
                "device": args.device,
                "source_tilegrid_sha256": sha256_file(topo / "tilegrid.json"),
                "source_sites_sha256": sha256_file(topo / "sites.csv"),
                "fabric_sites": len(fabric),
                "site_types": templates,
            },
            indent=2,
            sort_keys=False,
        )
        + "\n",
        encoding="utf-8",
    )

    validation = {
        "passed": not sample_mismatches and not count_mismatches and not pin_set_mismatches,
        "fabric_sites": len(fabric),
        "site_types": len(templates),
        "site_pin_wires": pin_count,
        "site_instances_unique": len(seen),
        "sample_checks": len(sample_checks),
        "sample_mismatches": sample_mismatches[:50],
        "instance_count_mismatches": count_mismatches[:50],
        "instance_pin_set_mismatches": pin_set_mismatches[:50],
        "template_digests": {
            site_type: template_digest(tpl) for site_type, tpl in sorted(templates.items())
        },
        "sources": {
            "tilegrid.json": sha256_file(topo / "tilegrid.json"),
            "sites.csv": sha256_file(topo / "sites.csv"),
        },
        "elapsed_seconds": round(time.time() - started, 3),
    }
    (out / "validation.json").write_text(
        json.dumps(validation, indent=2) + "\n", encoding="utf-8"
    )

    print(
        f"PASS={validation['passed']} sites={len(fabric)} pins={pin_count} "
        f"types={len(templates)} elapsed={validation['elapsed_seconds']}s",
        flush=True,
    )
    print(f"out: {out}", flush=True)
    return 0 if validation["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
