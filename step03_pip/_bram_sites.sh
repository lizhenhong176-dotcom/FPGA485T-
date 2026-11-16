#!/bin/bash
set -e

echo "=== BRAM/DSP site info ==="
python3 - <<'PY'
import json, re
d = json.load(open("/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled"))

for ty in ("BRAM_L", "BRAM_R", "DSP_L", "DSP_R"):
    count = 0
    for t in sorted(d):
        e = d[t]
        if e.get("type") != ty:
            continue
        sites = e.get("sites", {})
        m = re.match(r'.*_X(\d+)Y(\d+)$', t)
        tile_x = int(m.group(1)) if m else -1
        tile_y = int(m.group(2)) if m else -1
        print("%-20s type=%-8s tileXY=(%d,%d) gridXY=(%s,%s) cr=%s sites=%s" % (
            t, ty, tile_x, tile_y, e.get("grid_x"), e.get("grid_y"),
            e.get("clock_region"),
            json.dumps(sites, separators=(",",":"))))
        count += 1
        if count >= 4:
            break
    print()
PY

echo ""
echo "=== BRAM columns in frame_index_far.csv ==="
python3 - <<'PY'
import csv, collections
cols_by_row = collections.defaultdict(set)
with open("/tmp/tgbits/frame_index_far.csv", newline="") as fh:
    for r in csv.DictReader(fh):
        row = int(r["row"])
        ba = int(r["block_addr"], 16)
        col = (((ba >> 14) & 1) << 7) | ((ba >> 7) & 0x7F)
        cols_by_row[row].add(col)
for row in sorted(cols_by_row):
    cols = sorted(cols_by_row[row])
    print("row %d: %d cols, range %d..%d" % (row, len(cols), min(cols), max(cols)))
    if 130 in cols_by_row[row]:
        print("  col 130 EXISTS in row %d" % row)
    near = [c for c in cols if 125 <= c <= 140]
    if near:
        print("  cols near 130: %s" % near)
PY
