# V7RE — Virtex-7 bitstream reverse-engineering toolkit

Target device: **XC7VX485T-2FFG1761** (VC707), Vivado 2017.2.

> **Remote Vivado host**: the address / user / key and the exact invocation patterns live in
> [`../REMOTE.md`](../REMOTE.md) (authoritative, updated whenever the DHCP lease changes).
> Read it before running anything on the remote machine. Project status: [`../STATUS.md`](../STATUS.md).

This toolkit is the reusable core of the V7 reverse-engineering workflow:

1. parse `.bit` / `.bin` into 101-word frames
2. compare bitstreams at frame / word / bit level
3. build a probe design with fixed `LOC` / `BEL`
4. freeze the routed design as a DCP
5. generate INIT variants from the same DCP (clean probe)
6. sweep LOCs and record results

## Layout

```text
v7re/
  config.py                  device, paths, Vivado discovery
  bitstream/
    parser.py                .bit -> packets -> frames
    frames.py                frame diff, word/bit diff
  vivado/
    runner.py                cross-platform `vivado -mode batch`
    design.py                Verilog + Tcl for a LUT probe
    variants.py              DCP -> multiple bitstreams
    probe.py                 build / run / measure
    sites.py                 Vivado site enumeration -> site_table_*.json
    batch.py                 manifest runner with resume / dry-run
  scripts/
    parse_bit.py             CLI: parse and dump frames.bin
    diff_frames.py           CLI: diff two bitstreams
    probe_lut.py             CLI: one clean probe
    sweep_lut.py             CLI: many LOCs
    enumerate_sites.py       CLI: enumerate legal sites
    make_manifest.py         CLI: site table -> spread-out probe manifest
    run_batch.py             CLI: execute a probe manifest
    import_db.py             CLI: site table + result.json -> SQLite
    audit_db.py              CLI: check probe words against the site table
    export_site_topology.py  CLI: P0 site/BEL/site-PIP topology -> JSON/CSV
    validate_p0_against_routing.py  CLI: site-pin wires vs routing templates
    import_site_topology.py  CLI: P0 exports -> v7_p0.sqlite
    build_model_db.py        CLI: P0 + probes + routing metadata -> v7_model.sqlite
  tests/
    test_batch.py            manifest / dry-run unit tests (no Vivado)
    test_import_db.py        SQLite import tests
    test_model_db.py         canonical model build/query tests
    test_sites.py            site-coordinate parser tests
    test_audit.py            word-formula / audit tests
  db/
    schema.sql               probe SQLite schema
    schema_model.sql         canonical model schema
    import_results.py        site/probe importer
    import_model.py          canonical model builder
    audit.py                 word-position audit against site rows
  model.py                   read-only query helpers for v7_model.sqlite
  GLOSSARY.md                术语表（架构 / 配置 / 逆向 / 工程四类）
  ARCHITECTURE.md            架构分层：CLB → SLICE → LUT → tile → clock region
  HIERARCHY.md               六级物理层级：BEL → Site → Tile → Region → SLR → Device
```

## Workspace

All generated Vivado projects, bitstreams and probe data live under:

```text
E:\v7work\
  probe\              LUT bit-map probes
  bits\               64-bit INIT sweeps
  region_sweep*\      frame-map sweeps
  legacy\             earlier 330T / 485T experiments
    c_drive\ChatGPT\  migrated C-drive research data
                      (fpga逆向, fpga逆向 2, 门级网表木马检测调研)
```

`C:\v7work` and `C:\Users\i\v7work` have been migrated here; new runs use
`E:\v7work` automatically.

## Requirements

- Python 3.8+ (standard library only)
- Vivado 2017.2, with `VIVADO_BIN` set if not on `PATH`

## Quick start (Windows)

```powershell
set VIVADO_BIN=E:\app\Vivado\2017.2\bin\vivado.bat
set FPGA_WORK=E:\v7work

python scripts\parse_bit.py E:\v7work\legacy\v485\top.bit E:\v7work\legacy\v485\frames.bin
python scripts\diff_frames.py E:\v7work\legacy\v485\a.bin E:\v7work\legacy\v485\b.bin --bits

python scripts\probe_lut.py --loc SLICE_X10Y10 --bel A6LUT
python scripts\sweep_lut.py --locs SLICE_X0Y10,SLICE_X20Y10,SLICE_X40Y10

# P0: enumerate every legal SLICE site, then build/run a 20-site manifest
python scripts\enumerate_sites.py
python scripts\make_manifest.py --count 20
python scripts\run_batch.py --manifest E:\v7work\db\manifests\lut6_20.csv --dry-run
python scripts\run_batch.py --manifest E:\v7work\db\manifests\lut6_20.csv

# batch is resumable: existing result.json files are skipped; --force reruns them
python -m unittest discover -s tests -v

# full 64-bit INIT sweep at one site (~35 min, one DCP, 65 bitstreams)
python scripts\probe_bits.py --loc SLICE_X10Y10 --bel A6LUT

# encode / decode a LUT INIT value against an existing bit_map.json
python scripts\lut_codec.py --bit-map E:\v7work\probe\SLICE_X10Y10\A6LUT\bit_map.json --init 0xDEADBEEF
```

On Linux the same commands work with `export VIVADO_BIN=/tools/Xilinx/Vivado/2017.2/bin/vivado`
and `export FPGA_WORK=$HOME/v7work`.

## Clean probe: why DCP

Do **not** use a post-route XDC as a placement snapshot. XDC holds constraints,
not the complete placed design.

The reliable flow is:

```text
top.v + LOC/BEL  ->  synth/opt/place/route  ->  routed.dcp
                                              ->  a.bit (INIT_A), b.bit (INIT_B)
```

`probe_lut.py` does this in **one Vivado session** per `(LOC, BEL)`: after
routing it writes both bitstreams from the same placed/routed design.  Writing
both in the build session avoids starting the launcher a second time, which on
this machine occasionally hangs before creating `vivado.log`.  For a DCP that
already exists, `variants.py` performs the same two writes via
`open_checkpoint`.

## Site table (P0)

`scripts/enumerate_sites.py` runs `link_design -part xc7vx485tffg1761-2` once and
writes `E:\v7work\db\site_table_xc7vx485tffg1761_2.json`:

- **75,900** legal SLICE sites: **43,200 SLICEL** + **32,700 SLICEM**
- X columns **0..221**, Y rows **0..349**
- **14** clock regions: X0Y0..X0Y6 and X1Y0..X1Y6
- each record has `site`, `type`, `clock_region`, derived `row`/`column`

The site name is authoritative; `SLICE_X<col>Y<row>`.  A `LOC` that does not
appear in this table is invalid, even though Vivado may silently place the cell
elsewhere.  `probe_lut.py` also checks the `PROBE_LOC` line in the log.

## SQLite database (P0)

```bat
python scripts\import_db.py
```

This rebuilds `E:\v7work\db\v7.sqlite` from the site table and every
`result.json` under `E:\v7work` (skipping `legacy` and `codex_runs`):

- `sites`: 75,900 legal SLICE records
- `probes`: one row per measured `(device, loc, bel)`
- `probe_bits`: one row per changed `(frame, word, bit)`, with the INIT A/B
  pair that produced it (784 bits from the current 47 probes; the bogus
  `SLICE_X10Y100` probe was moved to `legacy/invalid` and removed)

`probe_bits` is the replacement for `frame_map` when a LUT6 spans several
frames.  Import a different probe root with
`--probe-root E:\v7work\region_sweep5 --skip-sites`; re-importing the same
`(loc, bel)` replaces its old rows.

`python scripts\audit_db.py` checks every imported non-aux word against the
row formula `2*(row % 50) + (1 if row % 50 >= 25 else 0)` and also flags
probes whose LOC is missing from the site table.

## Canonical model database (M0)

`scripts/build_model_db.py` builds `E:\v7work\model\v7_model.sqlite` from the
P0 boundary, the probe DB, and routing metadata:

```bat
python scripts\build_model_db.py --out E:\v7work\model\v7_model.sqlite
```

- `sites`: **86,022** strict-fabric sites (not the 75,900 SLICE-only view)
- `site_pins`: **5,489,706** per-instance site-pin -> tile-wire rows
- `site_types`/`site_bels`/`site_bel_pins`/`site_type_pips`/`site_wires`: P0
- `tiles` 150,380 + `tile_types` 115: routing metadata
- `probes` 72 + `probe_bits` 1248: measured frames (47 historical + 7 region
  anchors + 20 blind holdouts; some anchor locs were already present)
- `region_bases` 14: 7 measured X0 bases plus X1 aliases (X1 shares the
  vertical frame base; the X120..X220 offsets cross the boundary continuously)
- `column_offsets` 420: 30 X columns x 14 regions (13 measured at Y=160, 17
  recovered from historical probes)
- `site_frames`: 0（BEL 级位测量尚未开始，见下）
- `bit_map` 28 + `pip_bits` 2,652: STEP03 实测的 PIP→bit 表
  （`pip_bits` 口径：`kind='route'` 2,616 行带坐标，`kind='default'` 36 行为
  「默认源，不置任何选择位」，坐标列为 NULL；详见
  `step03_pip/migrate_pip_bits.py` 与 `step03_pip/TILEPIPE_RESULTS.md`）

Large routing edges and full wire/PIP geometry stay in `v7_routing.db`; attach
it with `model.connect(..., routing_db=...)` when needed.  M0 details and the
Linux command are in `steps/M0_MODEL.md`.  The build embeds source SHA256s in
`meta`, and refuses a bad site/site-pin count.

`scripts/make_manifest.py` sorts the table by `(row, column)` and picks an
evenly spread sample, so a 20-site manifest covers low rows, middle rows, and
the top row without hand-editing.

## Current findings (485T)

- Bitstream: **50,176 frames**, 101 words (404 bytes) per frame.
- Clock-region height: **50 SLICE rows**.
- Anchor: `SLICE_X10Y10` / `A6LUT` -> 4-frame group **31748..31751**.
- The 64 LUT6 INIT bits are split across those 4 frames, **16 bits per frame**,
  all in the same word.  The word index is not always 20:

  ```text
  word = 2 * (Y - region_start_Y) + {0 or 1}
  ```

  so `SLICE_X0Y0` uses frame 31540..31541 / word **0**,
  `SLICE_X10Y10` uses word **20**, `SLICE_X10Y20` uses word **40**, and
  `SLICE_X0Y160` (region starts Y=150) uses word **20** again.  The `+1`
  term is real: `SLICE_X219Y35` (lower half of the Y0 region) uses word
  **71** = 2*35 + 1, while `SLICE_X221Y17` (upper half) uses word **34**.
  The word-20 mapping is a clean permutation:

  ```text
  g = i // 4
  frame = base + (2 if g even else 0) + (1 if (g // 4) odd else 0)
  h = (i // 8) % 8
  base_bit = 15 - 8*(h % 2) - 2*((h // 4) % 2)
  bit = base_bit - [0, 1, 4, 5][i % 4]
  ```

  Word 50 holds a linear auxiliary table (36 extra positions); it is not
  needed to decode INIT, but is needed to produce a valid bitstream.
- The mapping is **linear over GF(2)**: `encode(0b11)` equals the measured
  INIT=3 diff exactly.  The 64 columns have rank 64.
- Region 0 base at X10: 31,748; region 1 (Y50+) base around 26,502.
- `lut_codec.py` can encode an arbitrary 64-bit INIT into physical bits and
  decode the word-20 bits back.

### M3 CLB LUT6 decoder (2026-10-22)

At `CLBLM_R_X7Y10` / `SLICE_X10Y10` (`SLICEM_X0`) all four LUT6 BELs are
mapped.  `segbits_clblm_r.db` has 256 unique segbits (4 x 64), and six
arbitrary INIT values per BEL pass `bit2fasm` (**24/24**).  The four LUTs
occupy consecutive 16-bit groups in words 20..23:

```text
A6LUT 2_655 .. 1_640
B6LUT 2_671 .. 1_656
C6LUT 2_687 .. 1_672
D6LUT 2_703 .. 1_688
```

This is a LUT-INIT-only shell: FF, CARRY4, F7/F8, O6 mux, site PIPs and
routing bits are still unknown.  Evidence and reproduction are in
`steps/M3_LUT.md` and `E:\v7work\m2\clb_shell`.

### Y=160 horizontal frame offsets (A6LUT)

Measured with the same clean-probe flow (`INIT=1` vs `INIT=2`).  The anchor
`SLICE_X10Y160` starts at frame **5520** (group 5520..5521):

| LOC | frame group | offset vs X10 |
|---|---:|---:|
| SLICE_X0Y160   | 5310..5311   | -210 |
| SLICE_X10Y160  | 5520..5521   |    0 |
| SLICE_X20Y160  | 5728..5729   | +208 |
| SLICE_X40Y160  | 6200..6201   | +680 |
| SLICE_X60Y160  | 6744..6745   | +1224 |
| SLICE_X80Y160  | 7186..7187   | +1666 |
| SLICE_X100Y160 | 7606..7607   | +2086 |
| SLICE_X120Y160 | 8108..8109   | +2588 |
| SLICE_X140Y160 | 8580..8581   | +3060 |
| SLICE_X160Y160 | 9024..9025   | +3504 |
| SLICE_X180Y160 | 9568..9569   | +4048 |
| SLICE_X200Y160 | 10040..10041 | +4520 |
| SLICE_X220Y160 | 10456..10457 | +4936 |

The X offset is not a constant per column and the increments are uneven
(X40→X60 = 544, X60→X80 = 442, X100→X120 = 502, X160→X180 = 544,
X180→X200 = 472, X200→X220 = 416), so always verify a new column instead of
extrapolating.

### M1 region bases (A6LUT, X10 anchor)

Seven region anchors were measured on the remote Linux host with the clean
`INIT=1` vs `INIT=2` probe.  These are the **first frame of the 4-frame LUT
group**; the first observed diff frame is base + 2:

| Clock region | Rows | X10 base frame | measured diff |
|---|---:|---:|---:|
| X0Y0 | 0..49 | 31748 | 31750..31751 |
| X0Y1 | 50..99 | 26502 | 26504..26505 |
| X0Y2 | 100..149 | 272 | 274..275 |
| X0Y3 | 150..199 | 5518 | 5520..5521 |
| X0Y4 | 200..249 | 10764 | 10766..10767 |
| X0Y5 | 250..299 | 16010 | 16012..16013 |
| X0Y6 | 300..349 | 21256 | 21258..21259 |

`X1Y0..X1Y6` use the same base as `X0Y0..X0Y6`; the column offset remains
continuous across the X0→X1 boundary.  The address model is

```text
base  = region_bases[clock_region]
frame = base + column_offsets[clock_region][X]   (first frame of group)
word  = 2 * (Y % 50) + (1 if (Y % 50) >= 25 else 0)
```

The `+2` between the group base and the first diff is the A6LUT INIT-bit-0
position, not an address offset.

Import/validation:

```bash
/data/lzh/venv/bin/python scripts/import_m1.py \
  --db data/model/v7_model.sqlite \
  --root data/m1/probe \
  --old-db work/refs_20261021/db/v7.sqlite
```

The importer checked all 47 historical probes: 2 had residual frame 0, 45 had
residual frame +2, no word errors, no skipped probes.  This validates the
30-column table, but the 17 non-Y160 columns were recovered from those same
historical probes, so they are calibration evidence, not an independent blind
holdout.

20 blind holdouts (not used for fitting; X0 and X1, all seven Y regions)
were then measured on the remote host.  All 20 have residual frame +2 and
exactly the predicted word.  See `data/m1/holdout_validation.json` and
`data/m1/manifests/m1_holdout_*.csv`.

A full 13x7 per-region sweep (91 probes) is still the strict M1 matrix; the
7 anchors + 20 holdouts are the pilot gate.  The 7 anchors and residuals are
in `data/m1/batches/m1_pilot.json` and `data/m1/m1_pilot.log` on the Linux
host.

### P0 smoke batch (A6LUT)

All 20 manifest items ran through `scripts/run_batch.py`; the first pass
finished with 12 ok + 5 resumed + 3 startup failures, and the three failures
(`SLICE_X42Y259`, `SLICE_X4Y278`, `SLICE_X0Y332`) completed on retry.  Batch
summaries:

- `E:\v7work\db\batches\lut6_20_full.json` (first pass)
- `E:\v7work\db\batches\lut6_20_retry.json` (first two retries)
- `E:\v7work\db\batches\lut6_20_retry2.json` (`SLICE_X0Y332`)

| LOC | diff frames | INIT word | half |
|---|---|---:|---|
| SLICE_X0Y0     | 31540..31541 |  0 | upper |
| SLICE_X221Y17  | 36678..36679 | 34 | upper |
| SLICE_X219Y35  | 36642..36643 | 71 | lower |
| SLICE_X44Y54   | 27282..27283 |  8 | upper |
| SLICE_X49Y73   | 27420..27421 | 46 | upper |
| SLICE_X53Y92   | 27520..27521 | 85 | lower |
| SLICE_X214Y111 | 5100..5101   | 22 | upper |
| SLICE_X165Y131 | 3870..3871   | 63 | lower |
| SLICE_X157Y150 | 8944..8945   |  0 | upper |
| SLICE_X156Y168 | 8952..8953   | 36 | upper |
| SLICE_X155Y186 | 8908..8909   | 73 | lower |
| SLICE_X154Y204 | 14162..14163 |  8 | upper |
| SLICE_X152Y222 | 14098..14099 | 44 | upper |
| SLICE_X151Y240 | 14054..14055 | 81 | lower |
| SLICE_X42Y259  | 16728..16729 | 18 | upper |
| SLICE_X4Y278   | 15874..15875 | 57 | lower |
| SLICE_X3Y296   | 15832..15833 | 93 | lower |
| SLICE_X2Y314   | 21086..21087 | 28 | upper |
| SLICE_X0Y332   | 21048..21049 | 65 | lower |
| SLICE_X221Y349 | 26186..26187 | 99 | lower |

`SLICE_X219Y35` confirms the `+1` half-row term (`2*35 + 1 = 71`), and every
non-aux word in the database now matches
`2*(row % 50) + (1 if row % 50 >= 25 else 0)`.  Startup hangs are launcher/temp
issues, not bad sites: `vivado/runner.py` watches for a missing `vivado.log`
for 180 s, kills the process tree, clears `temp`, and retries up to two times.

## Notes

- Vivado on this PC lives at `E:\app\Vivado\2017.2\bin\vivado.bat`
  (`E:\Xilinx\Vivado\2017.2` is a partial install and is not usable).
- 485T bitstream: **50,176 frames**, 101 words (404 bytes) per frame.
- Frame index is a linear FDRI sequence; the physical mapping is built by
  LOC/BEL probes and stored in `db/`.
- Vivado licenses are node-locked. A license for the PC will not automatically
  work on the workstation; plan a floating license or a separate seat.
- Vivado 2017.2 on Windows is for the demo; production fuzzing should run on
  Linux (Ubuntu 18.04 recommended) with the same Vivado version.

## Routing topology (STEP01, RapidWright)

The fabric-wide wire/PIP model lives outside the repo, at
`E:\v7work\routing\` (override with `FPGA_WORK`). It answers "what wires and
PIPs exist in this tile" without launching Vivado.

```text
v7re/
  routing/
    env.py            JVM bootstrap, part, logical tile coordinates
    topology.py       tile scan + per-type wire/PIP templates
    connections.py    inter-tile links via Tile.getWireConnections
    verify.py         independent acceptance checks vs the live device
    manifest.py       sha256 manifest for a stage
  scripts/
    step1_topology.py CLI: export | conns | verify | manifest | db | all
  db/
    schema_routing.sql
    import_routing.py  export dir -> SQLite (tiles, tile_types, conn_rules)
  steps/
    STEP01.md .. STEP04.md  step contracts and acceptance criteria
  run_step1.bat       reuse (verify+db) | export | conns | all
```

Measured for `xc7vx485tffg1761-2` (RapidWright 2026.1, JDK 17):

| metric | value |
|---|---|
| tile instances | 150,380 |
| tile types | 115 (all uniform) |
| wires | 56,847,864 |
| intra-tile PIPs | 207,253,149 |

`python scripts\step1_topology.py verify` re-derives all totals and 40 random
instances from the live device; `run_step1.bat` runs verify + manifest + db on
the existing export in about a minute.

Inter-tile connectivity is STEP02 (`steps/STEP02.md`). Two sources live in the
routing database `E:\v7work\routing\v7_routing.db`:

- `edges_exact` — 39,923,710 rows, every inter-tile link per tile instance,
  exact by construction and checked tile-by-tile against the live device;
- `step02/rules.db` — 804,680 corridor rules, a compact position-independent
  index (recognition exact, 0.0088% over-generation).

```bat
python -m v7re.scripts.step2_tileconn query --tile INT_L_X10Y20 --wire EE2BEG0 --source exact
python -m v7re.scripts.step2_tileconn stats --source exact
```

```python
from v7re.routing.tileconn import ExactEdges
edges = ExactEdges.load(r"E:\v7work\routing\v7_routing.db")
```

## P0 — site boundary (BEL / site pin / site PIP)

`steps/P0_SITE.md` closes the boundary between the tile routing graph and the
BEL netlist.  It does **not** add frame addresses or bit semantics.

Measured for `xc7vx485tffg1761-2`:

| metric | value |
|---|---:|
| strict-fabric site instances | 86,022 |
| fabric site types | 30 |
| site pin → tile wire rows | 5,489,706 |
| BELs / BEL pins (templates) | 3,439 / 7,107 |
| site PIPs / site wires (templates) | 583 / 3,252 |

Outputs live in `E:\v7work\p0\` (see `E:\v7work\p0\README.md`):
`site_types.json`, `site_instances.csv`, `site_pin_wires.csv.gz`,
`validation.json`, `routing_wire_validation.json`, `v7_p0.sqlite`.

Key rule: site pins are mapped **per instance**, not with a prefix formula.
`SLICEL/CLBLL_L` uses both `CLBLL_LL_*` and `CLBLL_L_*`; `DSP_L` uses
`DSP_0_*` / `DSP_1_*`.

Reproduce:

```bat
set JAVA_HOME=E:\tools\jdk17\jdk-17.0.20.1+1
set PATH=%JAVA_HOME%\bin;%PATH%
python scripts\export_site_topology.py --topology E:\v7work\_curated_20261021\topology --out E:\v7work\p0
python scripts\validate_p0_against_routing.py --p0 E:\v7work\p0 --routing E:\v7work\_curated_20261021\routing
python scripts\import_site_topology.py --p0 E:\v7work\p0 --db E:\v7work\p0\v7_p0.sqlite
```


