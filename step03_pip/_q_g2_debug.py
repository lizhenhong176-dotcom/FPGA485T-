#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""G2 调试：看真值不在解空间的那 158 个 tile 长什么样。"""
from __future__ import annotations

import collections
import io
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))
sys.path.insert(0, str(ROOT / "step03_pip"))

import tamper_localize as tl                       # noqa: E402
import g2_exact_cover as g                         # noqa: E402

W = tl.World()
raw = [(fam, src, frozenset(cells)) for fam, src, cells in W.cands["INT_L"]]
truth_raw = g.load_truth(str(ROOT / "tamper" / "ref" / "pips_all.txt"))
names = {n for fam, src, _ in raw for n in (fam, src)}
for ts in truth_raw.values():
    for d, s in ts:
        names.add(d); names.add(s)
cm = g.canon_map(names)
pool, cells = [], {}
for fam, src, c in raw:
    k = (cm[fam], cm[src])
    if k in cells:
        continue
    cells[k] = c
    pool.append(k)
cells_of = [cells[k] for k in pool]
idx_of = {k: i for i, k in enumerate(pool)}
truth = {t: {(cm[d], cm[s]) for d, s in v} for t, v in truth_raw.items()}

rep = json.loads(io.open(str(ROOT / "step03_pip" / "out" / "g2_exact_cover.json"),
                         encoding="utf-8").read())
bad = [r for r in rep["tiles"] if r["nsol"] == 1 and not r["truth_in_sols"]]
print("唯一解但真值不符：", len(bad), "／ 唯一解总数", sum(1 for r in rep["tiles"] if r["nsol"] == 1))

M = tl.load_bits(str(ROOT / "tamper" / "ref" / "ref.bit"))
shown = 0
missing_in_pool = collections.Counter()
for r in bad:
    ti = W.by_tile.get(r["tile"])
    if ti is None:
        continue
    obs = set(W.observed(M, ti))
    target = obs - g.WHITELIST
    cand = [i for i, c in enumerate(cells_of) if c <= obs]
    sols, trunc, orphan, nodes = g.enumerate_exact(cand, cells_of, target, 200, 400000)
    sol = {pool[i] for i in sols.pop()}
    T = truth.get(r["tile"], set())
    miss = [p for p in T if p not in idx_of]
    extra = sorted(sol - T)
    lack = sorted(T - sol)
    for p in miss:
        missing_in_pool[p[0]] += 1
    if shown < 4:
        print(f"\n== {r['tile']}  nsol=1  target={len(target)}  truth={len(T)}  sol={len(sol)}")
        print("   真值不在池里：", miss[:3])
        print("   解里多出：", extra[:6])
        print("   真值未被选：", lack[:6])
        for fam, src in lack[:2]:
            i = idx_of.get((fam, src))
            print(f"     {fam} <- {src}: cells={sorted(cells_of[i]) if i is not None else 'NOT-IN-POOL'}")
        shown += 1
print("\n真值里不在候选池的目标线计数：", missing_in_pool.most_common(6))
