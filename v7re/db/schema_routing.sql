-- Routing-topology database (step 1).
-- Big geometry stays in JSON/CSV on disk; SQLite holds the queryable index,
-- the stage ledger and the per-type connection rules.

PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS meta (
    key   TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

-- one row per tile instance (150,380 rows for 485T)
CREATE TABLE IF NOT EXISTS tiles (
    tile_name     TEXT PRIMARY KEY,
    type          TEXT NOT NULL,
    grid_x        INTEGER NOT NULL,
    grid_y        INTEGER NOT NULL,
    clock_region  TEXT,
    wire_count    INTEGER NOT NULL,
    pip_count     INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_tiles_type ON tiles(type);
CREATE INDEX IF NOT EXISTS idx_tiles_grid ON tiles(grid_x, grid_y);

-- one row per tile type: the JSON template is the authoritative geometry
CREATE TABLE IF NOT EXISTS tile_types (
    type         TEXT PRIMARY KEY,
    instances    INTEGER NOT NULL,
    wires        INTEGER NOT NULL,
    pips         INTEGER NOT NULL,
    uniform      INTEGER NOT NULL,
    template     TEXT NOT NULL,
    template_sha TEXT NOT NULL
);

-- raw inter-tile observation per type (dx,dy,target_type,target_wire)
CREATE TABLE IF NOT EXISTS conn_rules (
    type          TEXT NOT NULL,
    wire          TEXT NOT NULL,
    dx            INTEGER NOT NULL,
    dy            INTEGER NOT NULL,
    target_type   TEXT NOT NULL,
    target_wire   TEXT NOT NULL,
    PRIMARY KEY (type, wire, dx, dy, target_type, target_wire)
);
CREATE INDEX IF NOT EXISTS idx_conn_rules_wire ON conn_rules(type, wire);

-- canonical inter-tile connectivity (step 2): corridor-encoded rules that
-- rebuild every cross-tile link from the tile map alone. family =
-- "<tile_type>|<wire>|<sx>|<sy>"; corridor = row-major type-id tuple of the
-- endpoint rectangle grown by one cell; wires = JSON list of alias names.
CREATE TABLE IF NOT EXISTS tileconn (
    family    TEXT NOT NULL,
    corridor  TEXT NOT NULL,
    dx        INTEGER NOT NULL,
    dy        INTEGER NOT NULL,
    dst_type  TEXT NOT NULL,
    wires     TEXT NOT NULL,
    PRIMARY KEY (family, corridor)
);
CREATE INDEX IF NOT EXISTS idx_tileconn_family ON tileconn(family);

-- stage ledger: what ran, on which part, with what result
CREATE TABLE IF NOT EXISTS stages (
    stage        TEXT PRIMARY KEY,
    part         TEXT NOT NULL,
    status       TEXT NOT NULL,
    started_at   TEXT,
    finished_at  TEXT,
    result_json  TEXT
);

CREATE TABLE IF NOT EXISTS artifacts (
    stage  TEXT NOT NULL,
    path   TEXT NOT NULL,
    bytes  INTEGER NOT NULL,
    sha256 TEXT NOT NULL,
    PRIMARY KEY (stage, path)
);
