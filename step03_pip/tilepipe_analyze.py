"""Analyze tilepipe results: per-mux source masks, cell reuse, two-layer structure.

Input: tilepipe.json  { TAG: { SRC: {frames: [...], config: [[f,w,b], ...]} } }
TAG = SLICE_<sl>_<BEL>_<PIN>; sink (IMUX_Lk) is taken from TAG.sink files if present.
"""

from __future__ import annotations

import collections
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "tilepipe.json")
SINK_DIR = os.environ.get("TILEPIPE_DIR", "")


def load() -> dict:
    with open(DATA, encoding="utf-8") as fh:
        return json.load(fh)


def main() -> None:
    data = load()
    tags = sorted(data)
    print("tags:", len(tags), "sources per tag:", collections.Counter(len(data[t]) for t in tags))

    sinks = {}
    for tag in tags:
        p = os.path.join(SINK_DIR, tag + ".sink") if SINK_DIR else ""
        if p and os.path.exists(p):
            m = re.search(r"IMUX_L\d+", open(p).read())
            sinks[tag] = m.group(0) if m else "?"

    # cell = (frame, bit) with word dropped for grouping by column
    per_mux = collections.defaultdict(collections.Counter)
    for tag in tags:
        mux = sinks.get(tag, tag)
        for src, rec in data[tag].items():
            for _f, _w, _b in rec["config"]:
                per_mux[mux][(src, _f, _b)] += 1

    print("\nmuxes:", len(per_mux))
    for mux in sorted(per_mux, key=lambda s: (len(s), s))[:8]:
        cells = collections.Counter()
        for (src, f, b) in per_mux[mux]:
            cells[(f, b)] += 1
        top = cells.most_common(6)
        print("%-10s sources=%d distinct_cells=%d top=%s" %
              (mux, len({s for s, _f, _b in per_mux[mux]}), len(cells), top))

    # how many sources use each cell, aggregated
    reuse = collections.Counter()
    for mux, keyed in per_mux.items():
        for (f, b), n in [(k[1:], 1) for k in keyed]:
            reuse[(mux, f, b)] += n
    print("\nmax reuse per (mux,cell):", reuse.most_common(5))

    # mask sizes
    sizes = collections.Counter()
    for tag in tags:
        for src, rec in data[tag].items():
            sizes[len(rec["config"])] += 1
    print("\nmask size distribution:", dict(sorted(sizes.items())))


if __name__ == "__main__":
    main()
