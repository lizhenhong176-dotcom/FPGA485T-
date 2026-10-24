"""Audit probe word positions against the site table."""

from __future__ import annotations

import sqlite3

AUX_WORD = 50


def expected_word(row: int) -> int:
    """LUT6 INIT word for a SLICE row (50 rows per clock region).

    Word = 2*y within a region, with a +1 flip after the region midpoint.
    The flip boundary is pinned at y>=25 by three dedicated probes
    (E:\\v7work\\probe_boundary, batch_boundary.json, 2026-10-24):
      y=23 -> 46 (no flip), y=24 -> 48 (no flip),
      y=25 -> 51 (flip),   y=26 -> 53 (flip).
    y=24 landing on 48 (=2*24, not 49) rules out a flip at 24; y=25
    landing on 51 (=2*25+1) forces the flip to be exactly at 25.
    """
    y = row % 50
    return 2 * y + (1 if y >= 25 else 0)


def audit_word_positions(conn: sqlite3.Connection) -> tuple[list[str], int]:
    """Return ``(errors, checked_words)`` for every imported probe."""
    errors: list[str] = []
    checked = 0
    rows = conn.execute(
        """
        SELECT p.loc, p.bel, s.row, GROUP_CONCAT(DISTINCT pb.word)
        FROM probes p
        LEFT JOIN sites s
          ON s.device = p.device AND s.site = p.loc
        JOIN probe_bits pb
          ON pb.device = p.device AND pb.loc = p.loc AND pb.bel = p.bel
        GROUP BY p.loc, p.bel
        ORDER BY p.loc, p.bel
        """
    ).fetchall()
    for loc, bel, row, words in rows:
        if row is None:
            errors.append(f"{loc}/{bel}: no site-table row")
            continue
        for word_s in str(words).split(","):
            word = int(word_s)
            if word == AUX_WORD:
                continue
            checked += 1
            want = expected_word(int(row))
            if word != want:
                errors.append(
                    f"{loc}/{bel}: word {word}, expected {want} (row {row})"
                )
    return errors, checked
