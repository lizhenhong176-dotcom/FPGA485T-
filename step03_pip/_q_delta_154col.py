# -*- coding: utf-8 -*-
"""修正后（154 列）重新核对：ref vs tamper_init 的 bit 差异落在建模区的比例，以及解码 PIP 集合是否相同。"""
from __future__ import annotations
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import numpy as np                                              # noqa: E402
import tamper_localize as tl                                    # noqa: E402

A = tl.load_bits(str(ROOT / "tamper/ref/ref.bit"))
B = tl.load_bits(str(ROOT / "tamper/ref/tamper_init.bit"))
W = tl.World()

diff = np.argwhere(A != B)
print("bit 差异:", len(diff))

modeled = 0
for fr, w, b in diff:
    ok = False
    for (name, tt, col, y, base) in W.tiles:
        if base <= fr < base + 26 and w in (tl.word_of(y, 0), tl.word_of(y, 1)):
            ok = True
            break
    modeled += int(ok)
print("落在建模区:", modeled)

pa = {(W.tiles[ti][0], f, s) for ti in [int(t) for t in W.active_tiles(A)]
      for f, s, _ in W.selected(A, int(ti))}
pb = {(W.tiles[ti][0], f, s) for ti in [int(t) for t in W.active_tiles(B)]
      for f, s, _ in W.selected(B, int(ti))}
print("解码 PIP: ref", len(pa), "| tamper", len(pb), "| 相同:", pa == pb)

ta = {W.tiles[ti][0] for ti in [int(t) for t in W.active_tiles(A)]}
tb = {W.tiles[ti][0] for ti in [int(t) for t in W.active_tiles(B)]}
print("active tile: ref", len(ta), "| tamper", len(tb), "| 相同:", ta == tb)
