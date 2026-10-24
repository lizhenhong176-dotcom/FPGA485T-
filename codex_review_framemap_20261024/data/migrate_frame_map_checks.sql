-- migrate_frame_map_checks.sql (v6)
--
-- Migration for the frame_map table in the V7 model DB
-- (e.g. E:/v7work/model/v7_model.sqlite or /data/lzh/v7re model DB).
--
-- Purpose: upgrade a pre-existing frame_map table (any older shape, e.g.
-- v1 without CHECK constraints, or v3 without row_number/block_addr) to
-- the v5 constrained schema with the row/block metadata columns.
--
-- IMPORTANT: the v5 columns row_number and block_addr carry data that
-- exists only in phaseA/frame_index_far.csv, so this script rebuilds the
-- table EMPTY (SQLite cannot ALTER TABLE ... ADD COLUMN retro-populate,
-- and CHECK constraints cannot be added by ALTER at all).  After running
-- this script, repopulate with:
--
--     # in the project tree:
--     python scripts/import_frame_map.py [csv] [bit] [db]
--     # in the review bundle (codex_review_framemap_20261024):
--     python data/import_frame_map_v6.py data/frame_index_far.csv data/a_bitstream.bit <db>
--
-- The importer performs the equivalent DROP + CREATE + INSERT + audits
-- inside a single transaction and validates the data before/after the
-- write, so running the importer alone on an old DB is also a valid
-- migration path (it drops and rebuilds the table itself).  The
-- end-to-end old-schema -> migrate SQL -> re-import path is exercised
-- automatically by the importer's `--selftest` (test T6).
--
-- Usage:
--     sqlite3 v7_model.sqlite < scripts/migrate_frame_map_checks.sql

BEGIN TRANSACTION;

DROP INDEX IF EXISTS idx_frame_map_far;
DROP INDEX IF EXISTS idx_frame_map_overhead;
DROP TABLE IF EXISTS frame_map;

CREATE TABLE frame_map (
    frame_index           INTEGER PRIMARY KEY
        CHECK (frame_index >= 0 AND frame_index <= 50175),
    far                   INTEGER NULL,
    frame_address_source  TEXT NOT NULL
        CHECK (frame_address_source IN ('rapidwright-configarray', 'unresolved')),
    confidence            TEXT NOT NULL
        CHECK (confidence IN ('confirmed', 'unresolved')),
    tile_name             TEXT NULL,
    block_type            TEXT NULL,
    is_overhead           INTEGER NOT NULL DEFAULT 0
        CHECK (is_overhead IN (0, 1)),
    row_number            INTEGER NULL
        CHECK (row_number IS NULL OR (row_number BETWEEN 1 AND 14)),
    block_addr            INTEGER NULL,
    CHECK ((is_overhead = 1) = (far IS NULL)),
    CHECK ((is_overhead = 1) = (block_addr IS NULL)),
    CHECK (block_addr IS NULL OR block_addr % 128 = 0),
    CHECK (far IS NULL OR (far >= 0 AND far <= 2147483647))
);

CREATE INDEX idx_frame_map_far ON frame_map(far);
CREATE INDEX idx_frame_map_overhead ON frame_map(is_overhead);

COMMIT;

-- Table is now empty with the v5 constrained schema.
-- Re-run scripts/import_frame_map.py to populate and audit.
