# Build steps

Each step is a directory-free contract:

| step | produces | acceptance |
|---|---|---|
| [STEP01](STEP01.md) | device wire/PIP topology (`out_routing/`) | `verify.json` all PASS + `manifest.json` |
| [STEP02](STEP02.md) | canonical inter-tile connectivity (tileconn) | full-device recognition: 0 missing links over 150,380 tiles; 0 ambiguous rules |
| [P0](P0_SITE.md) | site boundary: BEL pin / site pin / site PIP → tile wire | 86,022 fabric sites; 5,489,706 site pins; 0 missing tile wires |
| [STEP03](STEP03.md) | PIP → frame/word/bit map for chosen PIP families | each PIP backed by a measured diff + replay check |
| [STEP04](STEP04.md) | frame/word/bit database (SQLite + JSON) | round-trip: fabric -> bitstream -> fabric |

Common rules:

1. **Data outside the source tree.** Generated artifacts go to
   `E:\v7work\routing\...` (override with `--root` / `FPGA_WORK`).
2. **Exporter and verifier never share code.** `routing/verify.py` re-derives
   everything from the live RapidWright device.
3. **Every stage ends with `manifest.json`** (sha256 per file) and a row in the
   `stages` table, so a later stage can tell whether its inputs changed.
4. **No silent skips.** A stage either passes its checks or exits non-zero.
