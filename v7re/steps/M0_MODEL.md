# M0 — canonical model database

Status: **PASS** (2026-10-21).  One queryable database for sites, P0 boundary,
routing metadata, and current probe observations.  No frame/bit semantics are
added by this step.

## Purpose

Before fuzzing more bits, the project needs one canonical answer to:

```text
site -> tile/BEL/site pin -> tile wire -> routing geometry -> probe bits
```

The old split (`v7.sqlite`, `v7_p0.sqlite`, `v7_routing.db`) remains valid, but
M0 makes the stable fabric model reproducible and gives later steps a place to
store `site_frames`, `bit_map`, and `pip_bits`.

## Inputs

| input | rows used |
|---|---|
| `work/refs_20261021/p0/v7_p0.sqlite` | 86,022 fabric sites, BEL/site-pin templates |
| `work/refs_20261021/db/v7.sqlite` | 47 probes, 784 probe bits |
| `work/refs_20261021/routing/v7_routing.db` | 150,380 tiles, 115 tile types (metadata only) |

The 55,612 physical/config-only sites are deliberately excluded; the strict
fabric set is the P0 `sites` set, not the 141,634-row `sites.csv`.

## Output

`E:\v7work\model\v7_model.sqlite` (634,908,672 bytes):

```text
sites             86,022
site_types            30
site_bels          3,439
site_bel_pins      7,107
site_type_pips       583
site_wires         3,252
site_pins      5,489,706
tiles            150,380
tile_types           115
probes                47
probe_bits           784
region_bases            0
column_offsets          0
site_frames             0
bit_map                 0
pip_bits                0
```

The empty tables are intentional: M1/M2 populate them from measured probes and
DCP PIP probes.  Large routing edges stay in `v7_routing.db`; attach it when
querying `edges_exact`, `tileconn`, or full wire/PIP geometry.

## Reproduce (Linux)

```bash
cd /data/lzh/v7re
/data/lzh/venv/bin/python -u scripts/build_model_db.py \
  --out data/model/v7_model.sqlite \
  --p0-db work/refs_20261021/p0/v7_p0.sqlite \
  --probe-db work/refs_20261021/db/v7.sqlite \
  --routing-db work/refs_20261021/routing/v7_routing.db
```

Windows uses the same script with `E:\v7work\...` paths.  Source SHA256 values
are written to `meta`; the build refuses to produce a DB unless the fabric site
count is 86,022 and the site-pin count is 5,489,706.

## Query example

```python
import model
c = model.connect(
    "/data/lzh/v7re/data/model/v7_model.sqlite",
    routing_db="/data/lzh/v7re/work/refs_20261021/routing/v7_routing.db",
)
s = model.site(c, "SLICE_X10Y10")
print(s["site_type"], s["tile"], s["row"], s["col"])  # SLICEM CLBLM_R_X7Y10 10 10
print(model.site_pins(c, "SLICE_X10Y10")[:2])
print(model.bel_pins(c, "SLICE_X10Y10", "A6LUT")[:2])
```

## Acceptance

- [x] 86,022 fabric sites imported exactly once.
- [x] 5,489,706 site-pin/tile-wire rows imported.
- [x] BEL/site-pin/PIP templates and routing tile metadata present.
- [x] 47 probes / 784 bits imported; no probe points at a non-fabric site.
- [x] Build reproducible on Windows and remote Linux; SHA256 source hashes match.
- [x] 11 unit tests pass on remote Python 3.8.8.

## Next

M1: complete the frame-address table.  Start from the seven measured region
anchors plus whole-region A6LUT sweeps (91 probes), fit X/region bases, then
validate the model at held-out sites and a few full rows.  Only after that
should bit semantics (M2) begin.
