import collections
import sqlite3

con = sqlite3.connect("file:E:/v7work/model/v7_law.sqlite?mode=ro", uri=True)
for fam in ("IMUX_L40", "IMUX_L0", "BYP_ALT0"):
    for s in (1, None):
        q = ("select src_wire, frame_off, bit, parity, sense from law_cells "
             "where tile_type='INT_L' and family=?")
        args = [fam]
        if s is not None:
            q += " and sense=?"
            args.append(s)
        rows = collections.defaultdict(set)
        for src, fo, bit, par, sense in con.execute(q, args):
            rows[src].add((fo, par, bit))
        cells = collections.defaultdict(set)
        for src, cs in rows.items():
            for c in cs:
                cells[c].add(src)
        tag = "sense=1" if s == 1 else "all rows"
        print(fam, tag, "srcs", len(rows), "cells", len(cells),
              "cells/src", sorted({len(v) for v in rows.values()}),
              "share", sorted(len(v) for v in cells.values()))
        print("   cells:", sorted(cells.items())[:12])
