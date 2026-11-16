# -*- coding: utf-8 -*-
"""扩展后：ref.bit 未解释位分布（直接调用 World）。"""
from __future__ import annotations
import collections, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import tamper_localize as tl                                    # noqa: E402

BIT = ROOT / "tamper/ref/ref.bit"
W = tl.World()
M = tl.load_bits(str(BIT))
print("World tiles:", len(W.tiles), "| M:", M.shape)

act = [int(t) for t in W.active_tiles(M)]
print("active tiles:", len(act))

pat = collections.Counter()
tile_hits = collections.Counter()
npips = 0
for ti in act:
    unexp, obs, sel = W.explain(M, ti)
    npips += len(sel)
    for (fo, bit, par) in unexp:
        pat[(fo, bit, par)] += 1
        tile_hits[W.tiles[ti][0]] += 1

print("解码 PIP 数:", npips)
print("未解释位:", sum(pat.values()), "| 涉及 tile:", len(tile_hits))
print("模式分布:", pat.most_common(8))
high = {k: v for k, v in tile_hits.items() if int(k.split("_X")[1].split("Y")[0]) >= 128}
print("列 >=128 的未解释 tile:", len(high), high)
