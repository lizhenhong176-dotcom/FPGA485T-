import random, sys
sys.path.insert(0, ".")
import numpy as np
from tamper_localize import World, load_bits, word_of, set_cells

w = World(); M = load_bits(r"..\..\tamper\ref\ref.bit")
rng = random.Random(7)
act = w.active_tiles(M); rng.shuffle(act)
done = 0
for ti in act:
    name, tt, col, y, base = w.tiles[ti]
    words = {0: word_of(y,0), 1: word_of(y,1)}
    sel = w.selected(M, ti)
    if not sel: continue
    fam, src, cells = sel[rng.randrange(len(sel))]
    sig0 = (len(w.explain(M, ti)[0]), len(w.slot_violations(M, ti)))
    set_cells(M, base, words, list(cells), 0)
    un, _, _ = w.explain(M, ti)
    viol = w.slot_violations(M, ti)
    set_cells(M, base, words, list(cells), 1)
    if len(un) > sig0[0] or len(viol) > sig0[1]:
        print("DETECTED", name, fam, "->", src, "cells", sorted(cells))
        print("   reported viol:", [(v[0],v[1],v[2]) for v in viol[:3]], "L1", len(un))
    done += 1
    if done >= 300: break
