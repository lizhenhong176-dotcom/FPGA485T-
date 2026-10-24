-- Canonical V7 model database.
--
-- This file intentionally replaces the split probe/P0/routing view with one
-- queryable model.  Large routing edge sets stay in v7_routing.db and are
-- attached by model.connect() when needed; this DB keeps the small routing
-- metadata (tiles, tile_types) plus the P0 site boundary and probe records.

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- One row per strict-fabric site instance (86,022 for 485T).
CREATE TABLE IF NOT EXISTS sites (
    device        TEXT NOT NULL,
    site          TEXT NOT NULL,
    site_type     TEXT NOT NULL,
    tile          TEXT NOT NULL,
    tile_type     TEXT NOT NULL,
    clock_region  TEXT,
    row           INTEGER,
    col           INTEGER,
    instance_x    INTEGER,
    instance_y    INTEGER,
    fabric        INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (device, site)
);
CREATE INDEX IF NOT EXISTS idx_sites_type  ON sites(device, site_type);
CREATE INDEX IF NOT EXISTS idx_sites_tile  ON sites(device, tile);
CREATE INDEX IF NOT EXISTS idx_sites_rc    ON sites(device, row, col);

-- Per-site-type BEL / pin / PIP templates (P0).
CREATE TABLE IF NOT EXISTS site_types (
    site_type     TEXT PRIMARY KEY,
    instances     INTEGER NOT NULL,
    representative TEXT NOT NULL,
    template_json TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS site_bels (
    site_type TEXT NOT NULL,
    bel       TEXT NOT NULL,
    PRIMARY KEY (site_type, bel)
);

CREATE TABLE IF NOT EXISTS site_bel_pins (
    site_type TEXT NOT NULL,
    bel       TEXT NOT NULL,
    pin       TEXT NOT NULL,
    direction TEXT NOT NULL,
    site_wire TEXT NOT NULL,
    site_pin  TEXT NOT NULL,
    PRIMARY KEY (site_type, bel, pin)
);
CREATE INDEX IF NOT EXISTS idx_site_bel_pins_wire ON site_bel_pins(site_type, site_wire);

CREATE TABLE IF NOT EXISTS site_type_pips (
    site_type       TEXT NOT NULL,
    name            TEXT NOT NULL,
    bel             TEXT NOT NULL,
    input_pin       TEXT NOT NULL,
    output_pin      TEXT NOT NULL,
    input_site_wire TEXT NOT NULL,
    output_site_wire TEXT NOT NULL,
    PRIMARY KEY (site_type, bel, name)
);

CREATE TABLE IF NOT EXISTS site_wires (
    site_type   TEXT NOT NULL,
    wire        TEXT NOT NULL,
    direction   TEXT NOT NULL,
    is_site_pin INTEGER NOT NULL,
    PRIMARY KEY (site_type, wire)
);

-- Per-instance site pin -> tile wire (5,489,706 rows for 485T).
CREATE TABLE IF NOT EXISTS site_pins (
    device    TEXT NOT NULL,
    site      TEXT NOT NULL,
    site_pin  TEXT NOT NULL,
    direction TEXT NOT NULL,
    tile_wire TEXT NOT NULL,
    PRIMARY KEY (device, site, site_pin)
) WITHOUT ROWID;
CREATE INDEX IF NOT EXISTS idx_site_pins_wire ON site_pins(device, tile_wire);

-- Routing metadata copied from v7_routing.db; edges/PIP geometry stay there.
CREATE TABLE IF NOT EXISTS tiles (
    tile_name    TEXT PRIMARY KEY,
    type         TEXT NOT NULL,
    grid_x       INTEGER NOT NULL,
    grid_y       INTEGER NOT NULL,
    clock_region TEXT,
    wire_count   INTEGER NOT NULL,
    pip_count    INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_tiles_type ON tiles(type);

CREATE TABLE IF NOT EXISTS tile_types (
    type         TEXT PRIMARY KEY,
    instances    INTEGER NOT NULL,
    wires        INTEGER NOT NULL,
    pips         INTEGER NOT NULL,
    uniform      INTEGER NOT NULL,
    template     TEXT NOT NULL,
    template_sha TEXT NOT NULL
);

-- Raw probe observations from the existing probe DB.
CREATE TABLE IF NOT EXISTS probes (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    device     TEXT NOT NULL,
    loc        TEXT NOT NULL,
    bel        TEXT NOT NULL,
    init_a     TEXT NOT NULL,
    init_b     TEXT NOT NULL,
    frames     TEXT NOT NULL,
    bits       TEXT NOT NULL,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_probes_loc ON probes(device, loc, bel);

CREATE TABLE IF NOT EXISTS probe_bits (
    device  TEXT NOT NULL,
    loc     TEXT NOT NULL,
    bel     TEXT NOT NULL,
    frame   INTEGER NOT NULL,
    word    INTEGER NOT NULL,
    bit     INTEGER NOT NULL,
    init_a  TEXT NOT NULL,
    init_b  TEXT NOT NULL,
    PRIMARY KEY (device, loc, bel, frame, word, bit)
);
CREATE INDEX IF NOT EXISTS idx_probe_bits_frame ON probe_bits(device, frame, word, bit);

-- Address topology.  Populated from measured probes, not from a formula guess.
CREATE TABLE IF NOT EXISTS region_bases (
    device      TEXT NOT NULL,
    region      TEXT NOT NULL,
    base_frame  INTEGER NOT NULL,
    anchor_site TEXT NOT NULL,
    source      TEXT NOT NULL,
    PRIMARY KEY (device, region)
);

CREATE TABLE IF NOT EXISTS column_offsets (
    device TEXT NOT NULL,
    region TEXT NOT NULL,
    x      INTEGER NOT NULL,
    offset INTEGER NOT NULL,
    source TEXT NOT NULL,
    PRIMARY KEY (device, region, x)
);

CREATE TABLE IF NOT EXISTS site_frames (
    device  TEXT NOT NULL,
    site    TEXT NOT NULL,
    bel     TEXT NOT NULL,
    feature TEXT NOT NULL,
    frame   INTEGER NOT NULL,
    word    INTEGER NOT NULL,
    bit     INTEGER NOT NULL,
    source  TEXT NOT NULL,
    PRIMARY KEY (device, site, bel, feature, frame, word, bit)
);
CREATE INDEX IF NOT EXISTS idx_site_frames_site ON site_frames(device, site, bel);

CREATE TABLE IF NOT EXISTS bit_map (
    device  TEXT NOT NULL,
    frame   INTEGER NOT NULL,
    word    INTEGER NOT NULL,
    bit     INTEGER NOT NULL,
    feature TEXT NOT NULL,
    value   INTEGER,
    source  TEXT NOT NULL,
    PRIMARY KEY (device, frame, word, bit)
);
CREATE INDEX IF NOT EXISTS idx_bit_map_feature ON bit_map(device, feature);

CREATE TABLE IF NOT EXISTS pip_bits (
    device   TEXT NOT NULL,
    tile     TEXT NOT NULL,
    wire_a   TEXT NOT NULL,
    wire_b   TEXT NOT NULL,
    frame    INTEGER NOT NULL,
    word     INTEGER NOT NULL,
    bit      INTEGER NOT NULL,
    value    INTEGER,
    source   TEXT NOT NULL,
    PRIMARY KEY (device, tile, wire_a, wire_b, frame, word, bit)
);
CREATE INDEX IF NOT EXISTS idx_pip_bits_tile ON pip_bits(device, tile, wire_a, wire_b);

CREATE TABLE IF NOT EXISTS stages (
    stage       TEXT PRIMARY KEY,
    part        TEXT NOT NULL,
    status      TEXT NOT NULL,
    started_at  TEXT,
    finished_at TEXT,
    result_json TEXT
);

CREATE TABLE IF NOT EXISTS artifacts (
    stage  TEXT NOT NULL,
    path   TEXT NOT NULL,
    bytes  INTEGER NOT NULL,
    sha256 TEXT NOT NULL,
    PRIMARY KEY (stage, path)
);

-- Frame address map: bitstream payload index -> FAR (Phase A).
-- 50,176 rows (50,148 block + 28 overhead).  Block-frame FARs come from
-- RapidWright ConfigArray; overhead FARs are unresolved (NULL).
-- v4: row_number + block_addr columns stored; CHECK constraints must match
-- import_frame_map.py DDL exactly.
-- Migration note: CREATE TABLE IF NOT EXISTS does NOT retrofit constraints
-- or new columns onto a pre-existing table.  The migration path is:
--   sqlite3 v7_model.sqlite < scripts/migrate_frame_map_checks.sql
-- (which DROPs the old table and re-CREATEs it with the constrained v4
-- schema), then re-run scripts/import_frame_map.py to repopulate; the
-- importer itself performs DROP+CREATE+INSERT inside one transaction, so
-- simply running it also migrates the table in place.
CREATE TABLE IF NOT EXISTS frame_map (
    frame_index           INTEGER PRIMARY KEY      -- 0..50175, bitstream payload order
        CHECK (frame_index >= 0 AND frame_index <= 50175),
    far                   INTEGER NULL,            -- NULL for 28 overhead rows
    frame_address_source  TEXT NOT NULL
        CHECK (frame_address_source IN ('rapidwright-configarray', 'unresolved')),
    confidence            TEXT NOT NULL
        CHECK (confidence IN ('confirmed', 'unresolved')),
    tile_name             TEXT NULL,               -- NULL for all rows in this phase
    block_type            TEXT NULL,               -- FAR block type (0..7) for block frames
    is_overhead           INTEGER NOT NULL DEFAULT 0
        CHECK (is_overhead IN (0, 1)),
    row_number            INTEGER NULL             -- config row 1..14 (from CSV)
        CHECK (row_number IS NULL OR (row_number BETWEEN 1 AND 14)),
    block_addr            INTEGER NULL,            -- block base FAR (block frames only)
    CHECK ((is_overhead = 1) = (far IS NULL)),
    CHECK ((is_overhead = 1) = (block_addr IS NULL)),
    CHECK (block_addr IS NULL OR block_addr % 128 = 0),
    CHECK (far IS NULL OR (far >= 0 AND far <= 2147483647))
);
CREATE INDEX IF NOT EXISTS idx_frame_map_far ON frame_map(far);
CREATE INDEX IF NOT EXISTS idx_frame_map_overhead ON frame_map(is_overhead);

-- Compatibility view for the older SLICE-only site set (75,900 rows).
CREATE VIEW IF NOT EXISTS v_slice_sites AS
SELECT device, site, site_type, clock_region, row, col
FROM sites
WHERE site_type IN ('SLICEL', 'SLICEM');
