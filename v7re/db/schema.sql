PRAGMA journal_mode = WAL;

-- Legal sites for a device, from vivado/sites.py.
CREATE TABLE IF NOT EXISTS sites (
    device       TEXT NOT NULL,
    site         TEXT NOT NULL,
    site_type    TEXT NOT NULL,
    clock_region TEXT,
    row          INTEGER,
    col          INTEGER,
    PRIMARY KEY (device, site)
);

-- Physical frame map: which frame a (LOC, BEL) anchor lands in.
-- Deprecated for LUT6: one LUT6 spans several frames, so use probe_bits.
CREATE TABLE IF NOT EXISTS frame_map (
    device TEXT NOT NULL,
    loc    TEXT NOT NULL,
    bel    TEXT NOT NULL DEFAULT '',
    frame  INTEGER NOT NULL,
    word   INTEGER,
    bit    INTEGER,
    PRIMARY KEY (device, loc, bel)
);

-- Bit database: what a configuration bit controls.
CREATE TABLE IF NOT EXISTS bit_map (
    device  TEXT NOT NULL,
    frame   INTEGER NOT NULL,
    word    INTEGER NOT NULL,
    bit     INTEGER NOT NULL,
    feature TEXT NOT NULL,
    PRIMARY KEY (device, frame, word, bit)
);

-- One row per changed bit observed by a clean probe (INIT A vs INIT B).
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

CREATE INDEX IF NOT EXISTS idx_probe_bits_frame
    ON probe_bits (device, frame, word, bit);

-- Raw probe records, useful for rebuilding the maps.
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
