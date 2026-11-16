import sys, collections
sys.path.insert(0, ".")
from tamper_localize import World, load_bits
for path in (r"..\..\tamper\ref\ref.bit", r"..\..\_full8.bit"):
    w = World(); M = load_bits(path)
    n = shared = 0
    for ti in w.active_tiles(M):
        sel = w.selected(M, ti)
        cnt = collections.Counter()
        for fam, src, cells in sel:
            for c in cells: cnt[c] += 1
        for fam, src, cells in sel:
            n += 1
            if any(cnt[c] > 1 for c in cells): shared += 1
    print(path, "pips=%d shared_cells_pips=%d (%.2f%%)" % (n, shared, 100.0*shared/n))
