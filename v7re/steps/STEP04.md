# STEP04 — frame/word/bit database

Status: **not started**. Extends `v7re/db/schema.sql` (site/frame tables already
exist) with routing and bit mappings; `db/import_results.py` is the current
ingest path.

## Tables to add on top of `schema_routing.sql`

```sql
CREATE TABLE frame_words (frame INTEGER, word INTEGER, label TEXT);      -- what a word means
CREATE TABLE site_bits  (site TEXT, bel TEXT, frame INTEGER, word INTEGER, bit INTEGER);
CREATE TABLE pip_bits   (tile TEXT, wire_start TEXT, wire_end TEXT,
                         frame INTEGER, word INTEGER, bit INTEGER, value INTEGER);
```

## Acceptance

* round-trip: take a routed design, apply our own `fasm -> frames -> diff`
  against Vivado's bitstream and get zero unexplained bits;
* the LUT INIT permutation from earlier probes (X10Y10/A6LUT, frames
  31748..31751, word 20) is reproduced from the database alone;
* clock-region base addresses are stored per region, not inferred per run.
