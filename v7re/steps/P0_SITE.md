# P0 — site boundary (BEL / site pin / site PIP)

Status: **PASS** (2026-10-21).  Site-level static topology for
`xc7vx485tffg1761-2`; no frame/bit semantics.

## Why this step exists

STEP01/STEP02 stop at tile wires and inter-tile connectivity.  A netlist tracer
still cannot enter a site: it knows `CLBLM_M_A1` exists, but not that
`SLICE_X10Y10` pin `A1` is that wire, or that `A6LUT` pin `A1` is site wire
`A1`.  P0 supplies exactly that boundary:

```text
BEL pin -> site wire -> site PIP* -> site pin -> tile wire
```

## Inputs

| input | role |
|---|---|
| `topology/tilegrid.json` | authoritative strict-fabric `sites` map (86,022) |
| `topology/sites.csv` | site → tile / grid / clock region / instance x,y |
| RapidWright 2026.1.1 + JDK 17 | live `Device` queries |

`topology/sites.csv` has 141,634 rows; the extra 55,612 are physical/config-only
sites and are intentionally outside P0.

## Outputs

`E:\v7work\p0\`:

* `site_types.json` — 30 site-type templates;
* `site_instances.csv` — 86,022 instances;
* `site_pin_wires.csv.gz` — 5,489,706 site-pin → tile-wire rows;
* `validation.json` — template/count/pin-set checks + source hashes;
* `routing_wire_validation.json` — tile-wire existence against routing templates;
* `v7_p0.sqlite` — normalized query DB;
* `README.md` — schema and query examples.

## Acceptance (all met)

1. Every strict-fabric site instance appears exactly once (86,022).
2. Every site type has one uniform BEL/PIP/wire template (150 samples, 0
   mismatches; full-instance BEL/PIP counts and site-pin sets, 0 mismatches).
3. Every site pin maps to a tile wire that exists in the same tile type's
   routing template (5,489,706 rows, 0 missing).
4. No prefix formula is assumed; mappings are per instance.
5. No frame addresses or bit offsets are invented.

## Reproduce

See `E:\v7work\p0\README.md`.  Scripts live in
`E:\DEEPSEEK\FPGA比特流逆向\v7re\scripts\`:

* `export_site_topology.py`
* `validate_p0_against_routing.py`
* `import_site_topology.py`

## Next

STEP03: choose one `INT_L/R` PIP and map it to `(frame, word, bit)` with two
clean DCP probes; then walk a complete two-site net using the P0 tables plus
`routing/v7_routing.db`.
