# STEP02 — inter-tile connectivity (tileconn)

Status: **done**. Date: 2026-10-21. Device: XC7VX485T-2FFG1761, RapidWright 2026.1.1.

Two artefacts, deliberately different in character:

| source | what it is | exactness | size |
|---|---|---|---|
| `edges_exact` (in `v7_routing.db`) | every inter-tile link materialised per tile instance | **exact by construction** — validated over all 150,380 tiles | 39,923,710 rows |
| `step02/rules.db` (corridor rules) | learned encoding keyed on a 1-cell-grown bounding corridor | recognition exact; prediction over-generates 0.0088% | 804,680 rules / 562 MB |

The exact table is the reference for netlist/reverse-engineering queries. The
rule table stays as the compact, position-independent index and as the input to
STEP03 (PIP naming and fuzzing), where a small over-generation is harmless
because each candidate is checked against a real bitstream.

## Why a plain delta does not work

`Tile.getWireConnections(i)` answers "which wires on other tiles are the same
net". For a fixed wire the answer depends on position:

* `BRKH_INT_X32Y199/NR1BEG0` → `INT_L/NR1END0`, while other columns give `INT_R`;
* CMT tiles connect to `CMT_TOP_*_LOWER_*` or `*_UPPER_*` depending on half;
* clock-feed wires enter `CLK_FEED` at different rows.

A per-type template reproduces 63/115 types only; the occurrence-index idea
(direction + ordinal of the target type) is ambiguous because `CLBLM_R` and
`INT_R` share the same tile-name X. Only **grid** coordinates are unique:
150,380 cells, zero duplicates (tile-name X/Y are clock-region style labels).

## Encoding used for the rule table: corridor

A rule is `(src_type, src_wire, (sx, sy)) -> (dx, dy, dst_type, dst_wire)`,
disambiguated by a **corridor**: the tile types of every grid cell inside the
rectangle spanned by both endpoints, grown by one cell, in row-major order.
Query needs only the static tile map — no RapidWright, no Vivado.

* 13,136 families, 804,680 rules, 0 conflicts, `step02/rules.db` (562 MB).
* Learned by walking all 150,380 tiles in 3 shards (~21 min each).
* 39,923,710 inter-tile edges retained; 207,773,646 same-tile edges dropped.

## Exact table

`step02/dump_edges.py` walks every tile and dumps `gx,gy,wire;c,r,dst_wire|...`
(one line per source wire). `step02/merge_edges.py` merges the three shards into
the routing database:

```sql
edge_tiles(id, gx, gy, name, type)
edge_wires(id, name)
edges_exact(src_tile, src_wire, dst_tile, dst_wire,
            PRIMARY KEY (src_tile, src_wire, dst_tile, dst_wire)) WITHOUT ROWID
```

39,923,710 rows, 37,286 distinct wire names, 150,380 tiles. The row count
matches the link count measured independently during rule validation.

Full pass (`step02/validate_full.py`, 3 shards, ~39 min each):

| metric | value |
|---|---|
| tiles | 150,380 |
| wires with external links | 11,857,917 |
| links | 39,923,710 |
| mismatched wires | **0** |
| missing / extra | **0 / 0** |

`validate_exact.py` additionally re-derives a random sample from the live device
(410 tiles / 30,290 wires / 128,953 links, 0 mismatches). Summary stored in
`validation_full.json` and in the routing database
(`stages.s02_tileconn_exact`, `meta.edges_exact_validation`).

## Validation of the rule table (independent second pass over all tiles)

| metric | value |
|---|---|
| tiles | 150,380 |
| wire instances | 29,621,616 |
| reference links | 39,923,710 |
| exact (tile + wire) | 39,510,493 (98.96%) |
| right tile / alias wire name | 2,765 (0.0069%) |
| over-generated | 3,497 (0.0088%) |
| missing | **0** |

Over-generation is limited to long-line chain families (`SS6BEG0` on one
instance: 6 live vs 14 predicted) where several candidate deltas produce
identical corridor strings on periodic layout. Alias differences sit on edge
columns where the same physical segment has a second legal name.

## Usage

```bat
python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0 --source exact
python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0
python -m v7re.scripts.step2_tileconn stats --source exact
```

```python
from v7re.routing.tileconn import ExactEdges
edges = ExactEdges.load(r"E:\v7work\routing\v7_routing.db")
for t in edges.edges("INT_L_X10Y20", "EE2BEG0"):
    print(t.grid_x, t.grid_y, t.type, t.wires)
```

Rule table (compact, needs `rules.db` + `tiles.csv.gz`):

```python
from v7re.routing.tileconn import TileConn
tc = TileConn.load(r"E:\v7work\routing\step02\rules.db",
                   r"E:\v7work\routing\out_routing\tiles.csv.gz")
```

Tile-type ids inside corridors come from `rules.db` `meta.types`; `TileConn.load`
reads them, so do not construct a `TileMap` by hand for this rule set.

## Open items

1. Normalise edge-column wire aliases before net comparison (2,765 links).
2. Cross-check against real bitstreams — belongs to STEP03 (PIP -> bit fuzzing).
