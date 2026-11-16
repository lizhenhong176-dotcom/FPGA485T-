import re, io
p = "tamper_localize.py"
s = open(p, encoding="utf-8").read()
# capture baseline signature before each mutation
s = s.replace("""        fam, src, cells = sel[rng.randrange(len(sel))]
        set_cells(M, base, words, list(cells), 0)
        hit, du, dv = _detect(world, M, ti)""",
"""        fam, src, cells = sel[rng.randrange(len(sel))]
        sig0 = _tile_signature(world, M, ti)
        set_cells(M, base, words, list(cells), 0)
        hit, du, dv = _detect(world, M, ti, sig0)""")
s = s.replace("""        fam, src, cells = cands[rng.randrange(len(cands))]
        set_cells(M, base, words, list(cells), 1)
        hit, du, dv = _detect(world, M, ti)""",
"""        fam, src, cells = cands[rng.randrange(len(cands))]
        sig0 = _tile_signature(world, M, ti)
        set_cells(M, base, words, list(cells), 1)
        hit, du, dv = _detect(world, M, ti, sig0)""")
s = s.replace("""        old = int(M[base + fo, 50, bit])
        M[base + fo, 50, bit] = 1 - old
        hit, du, dv = _detect(world, M, ti)""",
"""        old = int(M[base + fo, 50, bit])
        sig0 = _tile_signature(world, M, ti)
        M[base + fo, 50, bit] = 1 - old
        hit, du, dv = _detect(world, M, ti, sig0)""")
open(p, "w", encoding="utf-8").write(s)
print("patched", s.count("sig0 = _tile_signature"))
