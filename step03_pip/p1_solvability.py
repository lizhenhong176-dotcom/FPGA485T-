#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""P1：源级可解性的精确判定（穷尽枚举 + 去重）。

对单个 tile：设观察到的置位集合为 obs，去掉已知未建模标记位后得到 target。
候选 feature 集合 C = 所有格都落在 obs 内的 (family, src) 码字。
枚举 S ⊆ C 使 union(S) == target，收集**去重后的集合解**。

- 每个 tile 恰 1 解 → 源级可解（在模型口径下）
- 某 tile ≥2 解 → 同位流、不同源 = 源级不可解的确证（论文要的「下界」）
- 0 解 → 说明 target 里有任何候选都覆盖不到的格子（模型缺口，单独统计）
"""
from __future__ import annotations

import argparse
import collections
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import tamper_localize as tl                                    # noqa: E402
from verify_all_pip import name_variants                      # noqa: E402


def canon_map(names):
    """把同一条物理线的不同写法（INT_L 的 LV_L0 / INT_R 的 LV0）收成一个代表。

    用 name_variants 建立并查集，代表取字典序最小者，保证确定性。
    """
    parent = {}

    def find(x):
        while parent.get(x, x) != x:
            parent[x] = parent.get(parent[x], parent[x])
            x = parent[x]
        return x

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[max(ra, rb)] = min(ra, rb)

    for n in names:
        vs = list(name_variants(n))
        for v in vs[1:]:
            union(vs[0], v)
    return {n: find(n) for n in names}


def build_pool(world):
    """候选 feature 池：按归一化名 + 格子集去重。"""
    raw = [(fam, src, frozenset(cells)) for fam, src, cells in world.cands["INT_L"]]
    cm = canon_map({n for fam, src, _ in raw for n in (fam, src)})
    seen = {}
    for fam, src, cells in raw:
        key = (cm[fam], cm[src])
        if key in seen:
            assert seen[key] == cells, (key, seen[key], cells)
            continue
        seen[key] = cells
    return [(k[0], k[1], v) for k, v in seen.items()]


def enumerate_solutions(pool, target, cap=500, node_cap=200_000):
    """返回 (去重解列表, 是否截断, 未覆盖格)。"""
    cov_by_cell = collections.defaultdict(list)
    for idx, (fam, src, cells) in enumerate(pool):
        for c in cells & target:
            cov_by_cell[c].append(idx)
    orphan = [c for c in target if c not in cov_by_cell]

    sols = set()
    nodes = 0

    def rec(covered, chosen):
        nonlocal nodes
        nodes += 1
        if nodes > node_cap or len(sols) >= cap:
            return
        if covered >= target:
            sols.add(frozenset(chosen))
            return
        # 分支格：选候选最少的未覆盖格
        best, best_n = None, 10 ** 9
        for c in target - covered:
            n = len(cov_by_cell.get(c, ()))
            if n < best_n:
                best, best_n = c, n
                if n <= 1:
                    break
        if not best or best_n == 0:
            return
        for i in cov_by_cell[best]:
            if i in chosen:
                continue
            fam, src, cells = pool[i]
            chosen.add(i)
            rec(covered | (cells & target), chosen)
            chosen.discard(i)

    rec(set(), set())
    trunc = nodes > node_cap or len(sols) >= cap
    return sols, trunc, orphan


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", nargs="+", required=True)
    ap.add_argument("--json", default=None)
    ap.add_argument("--max-tiles", type=int, default=0)
    a = ap.parse_args()

    W = tl.World()
    pool_all = build_pool(W)
    print(f"候选池：{len(pool_all)} 条 feature（归一化去重后）")

    report = {}
    for path in a.bit:
        M = tl.load_bits(path)
        act = [int(t) for t in W.active_tiles(M)]
        if a.max_tiles:
            act = act[:a.max_tiles]
        hist = collections.Counter()
        examples, zero_examples = [], []
        fam_in_amb = collections.Counter()
        for ti in act:
            name = W.tiles[ti][0]
            obs = W.observed(M, ti)
            un, obs, sel = W.explain(M, ti)
            target = obs - un
            if not target:
                hist["empty"] += 1
                continue
            pool = [c for c in pool_all if c[2] <= obs]
            sols, trunc, orphan = enumerate_solutions(pool, target)
            hist["trunc" if trunc else len(sols)] += 1
            if not sols and orphan and len(zero_examples) < 5:
                zero_examples.append({"tile": name,
                                      "orphan_cells": [list(c) for c in sorted(orphan)],
                                      "target": len(target)})
            if len(sols) > 1:
                sets = sorted(sols, key=len)

                def as_pips(idx_set):
                    return sorted((pool[i][0], pool[i][1]) for i in idx_set)

                examples.append({
                    "tile": name,
                    "solutions": len(sols),
                    "example_a": as_pips(sets[0]),
                    "example_b": as_pips(sets[1]),
                    "target_cells": sorted(map(list, target)),
                })
                for fam, src in as_pips(sets[0]):
                    fam_in_amb[fam] += 1
        report[Path(path).name] = {
            "tiles": len(act),
            "hist": {str(k): v for k, v in sorted(hist.items(), key=str)},
            "multi": sum(v for k, v in hist.items() if isinstance(k, int) and k > 1),
            "zero": hist.get(0, 0),
            "examples": examples[:4],
            "zero_examples": zero_examples,
            "ambiguous_families": fam_in_amb.most_common(8),
        }
        r = report[Path(path).name]
        print(f"{Path(path).name}: tiles={r['tiles']} 唯一解={hist.get(1,0)} 多解={r['multi']} "
              f"零解={r['zero']} 截断={hist.get('trunc',0)} 空={hist.get('empty',0)}")
        for e in examples[:2]:
            print(f"   多解 {e['tile']} ({e['solutions']} 解) cells={len(e['target_cells'])}")
            print(f"     A: {e['example_a']}")
            print(f"     B: {e['example_b']}")
        for e in zero_examples[:2]:
            print(f"   零解 {e['tile']} target={e['target']} 无候选的格={e['orphan_cells']}")

    if a.json:
        Path(a.json).write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print("->", a.json)


if __name__ == "__main__":
    main()
