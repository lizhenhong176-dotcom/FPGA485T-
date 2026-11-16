import collections, sys
sys.path.insert(0, ".")
from tamper_localize import World, load_bits
w = World(); M = load_bits(r"..\..\tamper\ref\ref.bit")
hist = collections.Counter(); n = 0
for ti in w.active_tiles(M):
    name, tt, col, y, base = w.tiles[ti]
    setcells = set()
    for fam, src, cells in w.selected(M, ti):
        setcells |= set(cells)
    for c in setcells:
        k = sum(1 for fam, src, cells in w.cands[tt] if c in cells)
        hist[k] += 1; n += 1
print("set bits:", n, "candidate-PIPs-per-cell hist:", dict(sorted(hist.items())[:8]))
import statistics
vals = [k for k, v in hist.items() for _ in range(v)]
print("mean=%.2f median=%d max=%d" % (sum(vals)/len(vals), statistics.median(vals), max(vals)))
