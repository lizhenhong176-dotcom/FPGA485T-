# STEP02 — canonical inter-tile connectivity (tileconn)

Status: **done** (recognition exact; prediction over-generates 0.009%).
Date: 2026-10-21. Device: XC7VX485T-2FFG1761, RapidWright 2026.1.1.

Full write-up: `E:\v7work\routing\step02\REPORT.md` (中文) and `REPORT_EN.md`.

## Why a plain delta does not work

`Tile.getWireConnections(i)` answers "which wires on other tiles are the same
net". For a fixed wire the answer depends on position:

* `BRKH_INT_X32Y199/NR1BEG0` → `INT_L/NR1END0`, while other columns give `INT_R`;
* CMT tiles connect to `CMT_TOP_*_LOWER_*` or `*_UPPER_*` depending on half;
* clock-feed wires enter `CLK_FEED` at different rows.

Measured on 217 sampled instances: 63/115 types reproduce exactly from a
per-type template, 52 do not. The occurrence-index idea (direction + ordinal of
the target type) was tested and rejected: `CLBLM_R` and `INT_R` share the same
tile-name X, so the ordinal is ambiguous; only grid coordinates are unique.

## Encoding actually used: corridor

A rule is `(src_type, src_wire, (sx, sy)) -> (dx, dy, dst_type, dst_wire)`,
disambiguated by a **corridor**: the tile types of every grid cell inside the
rectangle spanned by both endpoints, grown by one cell, in row-major order.
Query needs only the static tile map — no RapidWright, no Vivado.

* 13,136 families, 804,680 rules, 0 conflicts, `step02/rules.db` (562 MB).
* Learned by walking all 150,380 tiles in 3 shards (~21 min each).
* 39,923,710 inter-tile edges retained; 207,773,646 same-tile edges dropped.

## Validation (independent second pass over all tiles)

| metric | value |
|---|---|
| tiles | 150,380 |
| wire instances | 29,621,616 |
| reference links | 39,923,710 |
| exact (tile + wire) | 39,510,493 (98.96%) |
| right tile / alias wire name | 2,765 (0.0069%) |
| over-generated | 3,497 (0.0088%) |
| missing | **0** |

Recognition is exact (no unexplained real edge). Over-generation is limited to
long-line chain families (`SS6BEG0` on one instance: 6 live vs 14 predicted)
where several candidate deltas produce identical corridor strings on periodic
layout. Alias differences sit on edge columns where the same physical segment
has a second legal name.

## Usage

```bat
python -m v7re.scripts.step2_tileconn import
python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0
python -m v7re.scripts.step2_tileconn stats
```

```python
from v7re.routing.tileconn import TileConn
tc = TileConn.load(r"E:\v7work\routing\step02\rules.db",
                   r"E:\v7work\routing\out_routing\tiles.csv.gz")
for t in tc.edges("INT_L_X10Y20", "EE2BEG0"):
    print(t.grid_x, t.grid_y, t.type, t.wires)
```

Tile-type ids inside corridors come from `rules.db` `meta.types`; `TileConn.load`
reads them, so do not construct a `TileMap` by hand for this rule set.

## Open items

1. Converge over-generation: shortest-match preference or per-segment tap rules.
2. Normalise edge-column wire aliases before net comparison.
3. Cross-check against real bitstreams — belongs to STEP03 (PIP -> bit fuzzing).
