import sys, collections
sys.path.insert(0, ".")
from tamper_localize import World, load_bits
w = World(); M = load_bits(r"..\..\tamper\ref\ref.bit")
n = pred = 0; both = 0
for ti in w.active_tiles(M):
    sel = w.selected(M, ti)
    sets = [set(c) for _, _, c in sel]
    for i, A in enumerate(sets):
        n += 1
        p = False
        for j, B in enumerate(sets):
            if i == j: continue
            if A & B and not (B <= A):
                p = True; break
        if p: pred += 1
print("pips=%d predicted_orphan_detection=%d (%.2f%%)" % (n, pred, 100.0*pred/n))
