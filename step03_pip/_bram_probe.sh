#!/bin/bash
#!/bin/bash
set -e

echo "=== 1. V7 tilegrid type counts ==="
python3 - <<'PY'
import json, collections
d = json.load(open("/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled"))
types = collections.Counter()
filled = collections.Counter()
for t, e in d.items():
    ty = e.get("type","?")
    types[ty] += 1
    if e.get("bits"):
        filled[ty] += 1
print("Total tiles: %d" % len(d))
print("Total types: %d" % len(types))
for ty, n in types.most_common():
    f = filled.get(ty, 0)
    tag = "FILLED" if f == n else ("PARTIAL %d/%d" % (f, n) if f else "EMPTY")
    print("  %-25s %6d  %s" % (ty, n, tag))
PY

echo ""
echo "=== 2. BRAM tile examples (with sites) ==="
python3 - <<'PY'
import json
d = json.load(open("/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled"))
import re
for t in sorted(d):
    e = d[t]
    ty = e.get("type","?")
    if ty in ("BRAM_L","BRAM_R","DSP_L","DSP_R","BRAM_INT_INTERFACE_L","BRAM_INT_INTERFACE_R"):
        bits = e.get("bits", {})
        sites = e.get("sites", {})
        print("%-20s type=%-20s grid=(%s,%s) cr=%s" % (t, ty, e.get("grid_x"), e.get("grid_y"), e.get("clock_region")))
        if bits:
            print("   bits=%s" % json.dumps(bits, separators=(",",":")))
        else:
            print("   bits=(empty)")
        if sites:
            print("   sites=%s" % json.dumps(sites, separators=(",",":")))
        # Only show first 3 of each type
PY

echo ""
echo "=== 3. frame_index_far.csv BRAM rows (8-14) ==="
python3 - <<'PY'
import csv, collections
rows_by_band = collections.defaultdict(list)
with open("/tmp/tgbits/frame_index_far.csv", newline="") as fh:
    for r in csv.DictReader(fh):
        row = int(r["row"])
        if row >= 8 and row <= 14:
            rows_by_band[row].append(r)
print("BRAM bands (rows 8-14):")
for row in sorted(rows_by_band):
    recs = rows_by_band[row]
    bas = set(r["block_addr"] for r in recs)
    kinds = collections.Counter(r["kind"] for r in recs)
    far_min = min(int(r["far"],16) for r in recs)
    far_max = max(int(r["far"],16) for r in recs)
    fi_min = min(int(r["frame_index"]) for r in recs)
    fi_max = max(int(r["frame_index"]) for r in recs)
    print("  row %d: %d entries, far=0x%08X..0x%08X, fi=%d..%d, kinds=%s" % (
        row, len(recs), far_min, far_max, fi_min, fi_max, dict(kinds)))
    # Show first few block_addrs
    sample_bas = sorted(bas)[:5]
    print("    sample block_addrs: %s" % [hex(int(x,16)) for x in sample_bas])
    # Show block_type (high bits)
    bts = set()
    for r in recs[:20]:
        ba = int(r["block_addr"], 16)
        bts.add((ba >> 14) & 0x3FFF)
    print("    block_type (ba>>14): %s" % sorted(bts))
PY

echo ""
echo "=== 4. Local artix7 segbits inventory ==="
ls -la /tmp/bit2fasm/segbits/ 2>/dev/null || echo "(not found)"

echo ""
echo "=== 5. V7 tilegrid BRAM/DSP grid layout ==="
python3 - <<'PY'
import json, collections
d = json.load(open("/opt/lzh/v7re/data/fasm_shell/db/xc7vx485t/tilegrid.json.filled"))
for ty in ("BRAM_L","BRAM_R","DSP_L","DSP_R","BRAM_INT_INTERFACE_L","BRAM_INT_INTERFACE_R",
           "INT_INTERFACE_L","INT_INTERFACE_R","HCLK_CLB","HCLK_R","CMT_TOP_L_UPPER_T","CMT_TOP_R_LOWER_T",
           "IO_INT_INTERFACE_L","IO_INT_INTERFACE_R","CLK_HROW_TOP_R","CLK_HROW_BOT_L"):
    instances = [(t, d[t]) for t in sorted(d) if d[t].get("type") == ty]
    if instances:
        xs = sorted(set(e.get("grid_x",0) for _,e in instances))
        ys = sorted(set(e.get("grid_y",0) for _,e in instances))
        crs = sorted(set(e.get("clock_region","") for _,e in instances))
        print("  %-25s count=%4d  grid_x=%s  grid_y_range=%d..%d  crs=%s" % (
            ty, len(instances), xs[:10], min(ys), max(ys), crs[:5]))
PY
