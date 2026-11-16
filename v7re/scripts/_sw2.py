import collections, random, sys
sys.path.insert(0, ".")
from tamper_localize import World, load_bits, word_of, set_cells
w = World(); M = load_bits(r"..\..\tamper\ref\ref.bit")
rng = random.Random(11)
act = w.active_tiles(M); rng.shuffle(act)
tot = det = 0
hist = collections.Counter()
shown = 0
for ti in act:
    name, tt, col, y, base = w.tiles[ti]
    words = {0: word_of(y,0), 1: word_of(y,1)}
    by_fam = collections.defaultdict(list)
    for fam, src, cells in w.cands[tt]: by_fam[fam].append((src, cells))
    sel = w.selected(M, ti)
    for fam, src, cells in sel:
        alts = [(s,c) for s,c in by_fam.get(fam, ()) if s != src]
        if not alts: continue
        s2, c2 = rng.choice(alts)
        off = [c for c in cells if c not in c2]; on = [c for c in c2 if c not in cells]
        k = len(off) + len(on); hist[k] += 1
        set_cells(M, base, words, off, 0); set_cells(M, base, words, on, 1)
        un, _, _ = w.explain(M, ti); viol = w.slot_violations(M, ti)
        set_cells(M, base, words, off, 1); set_cells(M, base, words, on, 0)
        tot += 1
        if un or viol:
            det += 1
            if shown < 3:
                print("DET", name, fam, src, "->", s2, "k", k, "un", len(un), "viol", len(viol)); shown += 1
        if tot >= 60: break
    if tot >= 60: break
print("n=%d det=%d rate=%.1f%% hist=%s" % (tot, det, 100.0*det/tot, dict(hist)))
