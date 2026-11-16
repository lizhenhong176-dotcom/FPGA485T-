# -*- coding: utf-8 -*-
"""解码 vs 真值（按 src/dst 名字直接对），并单独看新增高列。"""
from __future__ import annotations
import re, sys, collections
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import tamper_localize as tl                                    # noqa: E402

truth = set()
for line in (ROOT / "tamper/ref/pips_all.txt").read_text(encoding="utf-8", errors="replace").splitlines():
    m = re.match(r"\s*(INT_[LR]_X\d+Y\d+)/\w+\.(\w+)->>?(\w+)\s*$", line.strip())
    if m:
        truth.add((m.group(1), m.group(2), m.group(3)))

W = tl.World()
M = tl.load_bits(str(ROOT / "tamper/ref/ref.bit"))
decoded = set()
for ti in [int(t) for t in W.active_tiles(M)]:
    name = W.tiles[ti][0]
    for _fam, src, _cells in W.selected(M, ti):
        for (_t, s, d) in truth:
            pass
    for fam, src, _cells in W.selected(M, ti):
        decoded.add((name, src, fam))

hit = decoded & truth
print("真值:", len(truth), "| 解码:", len(decoded), "| 交集:", len(hit))
print("召回:", f"{100.0*len(hit)/len(truth):.2f}%", "| 解码侧命中率:", f"{100.0*len(hit)/len(decoded):.2f}%")
print("真值未解出:", len(truth - decoded), "| 多解出:", len(decoded - truth))

bycol = collections.Counter()
for (t, s, d) in truth - decoded:
    bycol[int(t.split("_X")[1].split("Y")[0])] += 1
print("真值漏解的 tile 列分布(前 8):", bycol.most_common(8))

hi = [x for x in truth if int(x[0].split("_X")[1].split("Y")[0]) >= 128]
hihit = [x for x in hi if x in decoded]
print(f"高列(>=128) 真值 {len(hi)} 条，解出 {len(hihit)} 条")
