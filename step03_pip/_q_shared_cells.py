# -*- coding: utf-8 -*-
"""ref.bit 下：有多少已选 PIP 至少与另一条已选 PIP 共享一个格子（154 列口径）。"""
from __future__ import annotations
import collections, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))
import tamper_localize as tl                                    # noqa: E402

W = tl.World()
M = tl.load_bits(str(ROOT / "tamper/ref/ref.bit"))
tot = shared = 0
cells_total = 0
for ti in [int(t) for t in W.active_tiles(M)]:
    sel = W.selected(M, ti)
    cellmap = collections.defaultdict(int)
    for f, s, cells in sel:
        for c in cells:
            cellmap[c] += 1
    for f, s, cells in sel:
        tot += 1
        cells_total += len(cells)
        if any(cellmap[c] > 1 for c in cells):
            shared += 1
print(f"已选 PIP {tot} 条，格 {cells_total} 个，平均 {cells_total/tot:.2f} 格/条")
print(f"至少与另一条共享一个格子的 PIP: {shared}/{tot} = {100.0*shared/tot:.1f}%")
