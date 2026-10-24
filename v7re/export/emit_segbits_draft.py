"""Emit a DRAFT segbits file from pip_bits.

IMPORTANT: this is NOT prjxray-native yet.

prjxray segbits line format is:

    <feature> <word_column>_<word_bit> [more...]

and tile_segbits.match_bitdata does:

    frame   = bits.base_address + query_bit.word_column
    bitidx  = bits.offset * bitstream.WORD_SIZE_BITS + query_bit.word_bit

so the word index of a bit lives inside the per-tile ``bits.offset`` metadata
(tilegrid.json in prjxray-db carries a ``bits`` dict per tile), not inside the
segbits line.  Our observations carry an explicit word, and we have not yet
confirmed how prjxray maps varying words onto ``offset``/aliases.

Therefore we emit ``<frame_offset>_<word>_<bit>`` with an explicit word, so the
file is honest and self-describing.  Renaming it to segbits_<t>.db is only
correct once the offset convention is confirmed (see STATUS.md).
"""

from __future__ import annotations

import collections
import sqlite3

DB = r"E:\v7work\model\v7_model.sqlite"
OUT = r"E:\v7work\db\prjxray\xc7vx485t\segbits_int_l.draft"

# config block base frame per (column, clock region); INT_L_X6 uses col 6
BLOCK_BASE = {
    (6, 0): 31680,  # FAR 0x420300
    (6, 1): 26434,  # FAR 0x400300
}


def region_of(tile: str) -> int:
    y = int(tile.rsplit("Y", 1)[1])
    return 0 if y < 50 else 1


def main() -> None:
    con = sqlite3.connect(DB)
    rows = con.execute(
        "select tile, wire_a, wire_b, frame, word, bit from pip_bits order by tile, frame, word, bit"
    ).fetchall()

    feats = collections.OrderedDict()
    for tile, wa, wb, frame, word, bit in rows:
        col = int(tile.split("_X")[1].split("Y")[0])
        base = BLOCK_BASE[(col, region_of(tile))]
        tok = "%d_%d_%02d" % (frame - base, word, bit)
        key = "%s.%s->>%s" % (tile, wa, wb)
        feats.setdefault(key, []).append(tok)

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("# DRAFT: frame_offset_word_bit (not prjxray-native)\n")
        for key, toks in feats.items():
            fh.write("%s %s\n" % (key, " ".join(toks)))

    print("features:", len(feats), "bits:", len(rows))
    for line in open(OUT, encoding="utf-8").read().splitlines()[1:6]:
        print("  ", line)


if __name__ == "__main__":
    main()
