# -*- coding: utf-8 -*-
"""调试：为什么 fake-mux 现在被判为「检出」。复现 3 次尝试并打印细节。"""
from __future__ import annotations
import random, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import tamper_localize as tl                                    # noqa: E402

W = tl.World()
M = tl.load_bits(str(ROOT / "tamper/ref/ref.bit"))
rng = random.Random(11)
act = W.active_tiles(M)
rng.shuffle(act)
print("active:", len(act))

shown = 0
for ti in act:
    name, tt, col, y, base = W.tiles[ti]
    words = {0: tl.word_of(y, 0), 1: tl.word_of(y, 1)}
    sel0 = set((f, s) for f, s, _ in W.selected(M, ti))
    for fam, src, cells in W.cands[tt]:
        if len(cells) != 2 or any(c[0] < 16 for c in cells):
            continue
        pars = {c[2] for c in cells}
        bits = {c[1] for c in cells}
        if len(pars) != 1 or len(bits) != 1:
            continue
        par, bit = pars.pop(), bits.pop()
        if W.slot_state(M, ti, bit, par) != ([], 0):
            continue
        if any(M[base + fo, words[par], b] for (fo, b, _) in cells):
            continue
        tl.set_cells(M, base, words, cells, 1)
        un, obs, sel1 = W.explain(M, ti)
        viol = W.slot_violations(M, ti)
        new = [(f, s) for f, s, _ in sel1 if (f, s) not in sel0]
        print(f"\ntile={name} y={y} col={col} base={base} fam={fam} src={src} cells={cells}")
        print(f"  par={par} bit={bit} | un={sorted(un)} | new={new} | viol={viol[:3]}")
        print(f"  slot_state 后= {W.slot_state(M, ti, bit, par)}")
        if viol:
            print("  !! 有违例，detail:", viol[0])
        tl.set_cells(M, base, words, cells, 0)
        shown += 1
        break
    if shown >= 3:
        break
