# STEP01 — device routing topology (DONE)

Goal: turn "what the chip is made of" into a queryable artifact set, so later
steps can name any wire/PIP without asking Vivado again.

## Command

```bat
cd /d E:\DEEPSEEK\FPGA比特流逆向\v7re
set JAVA_HOME=E:\tools\jdk17\jdk-17.0.20.1+1
python scripts\step1_topology.py export --root E:\v7work\routing\out_routing
python scripts\step1_topology.py conns  --root E:\v7work\routing\out_routing --measure
python scripts\step1_topology.py verify --root E:\v7work\routing\out_routing --with-conns
python scripts\step1_topology.py manifest --root E:\v7work\routing\out_routing
python scripts\step1_topology.py db     --root E:\v7work\routing\out_routing --db E:\v7work\routing\v7_routing.db
```

`all` runs the sequence. `--limit N` builds a small export for smoke tests.

## Artifacts

| file | content |
|---|---|
| `tiles.csv.gz` | 150,380 rows: name, type, grid x/y, clock region, wire/pip counts |
| `templates/<TYPE>.json` | 115 templates: `wire_defs`, `pip_defs` (endpoints, delay, bidir, inverted) |
| `type_uniformity.json` | per type: instance count, signature, uniform flag |
| `summary.json` / `DONE.json` | totals and stage marker |
| `conns/<TYPE>.json` | raw inter-tile links `[dx, dy, target_type, target_wire]` |
| `conns/conns_summary.json` | per type link counts, target types, delta histogram |
| `conns/uniformity.json` | how many sampled instances match the per-type template |
| `manifest.json` | sha256 + size for every file |
| `verify.json` | every check with PASS/FAIL |

## Measured baseline (xc7vx485tffg1761-2, RapidWright 2026.1, JDK 17)

| metric | value |
|---|---|
| tile instances | 150,380 |
| tile types | 115 (all uniform) |
| wires | 56,847,864 |
| intra-tile PIPs | 207,253,149 |
| template bytes | 6.5 MB |

These numbers are also canaries in `routing/verify.py`: a RapidWright upgrade
that changes the device model fails the stage instead of silently shifting it.

## Known limitation carried into STEP02

`Tile.getWireConnections` gives the true inter-tile net membership, but the
answer is **not translation-invariant**: for 52 of 115 types the partner tile
type depends on the neighbouring column (INT_L vs INT_R vs BRAM interface) or
on the half of the clock region. Raw links are exported as evidence; the
canonical encoding is STEP02's job.
