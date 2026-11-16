#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""G2：精确覆盖解码 vs Vivado 真值对账（ref.bit）

目的
----
把 INT tile 的解码从「逐 PIP 独立判全格置位 + min-cells 过滤」换成「精确覆盖」：
要求所选 feature 的位集并集**恰好等于**观测到的目标位集（目标位 = 置位 - 已知标记格）。

然后与 `tamper/ref/pips_all.txt`（Vivado `get_pips` 真值）逐 tile 对账，回答三个问题：

Q1 每个 tile 的解空间有多大（唯一 / 多解 / 无解）？
Q2 真值是否总是解空间里的一个解？
Q3 多出来的那些 PIP 是"解码器错"还是"模型层面的 2 格长线共位"？

输出：step03_pip/out/g2_exact_cover.json
"""
from __future__ import annotations

import argparse
import collections
import io
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))

import tamper_localize as tl                              # noqa: E402
from verify_all_pip import name_variants                  # noqa: E402

WHITELIST = set(tl.KNOWN_UNMODELED)                        # {(1,0,0),(1,1,0),(0,16,1)}
INT_RE = re.compile(r"^(INT_[LR])_X(\d+)Y(\d+)/(INT_[LR])\.(.+?)-(>>|>)>(.+)$")


def canon_map(names):
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


def load_truth(path):
    """-> {tile_name: {(dst, src), ...}}"""
    out = collections.defaultdict(set)
    with io.open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            m = INT_RE.match(line)
            if not m:
                continue
            tile = f"{m.group(1)}_X{m.group(2)}Y{m.group(3)}"
            # 写法是 `src->>dst`：第 5 组是驱动线，第 7 组是目的线（= 我们的 family）
            # Vivado 对反向/双向线常加 `<<` `>>` 后缀，这里先剥掉再交给 canon_map
            src = m.group(5).replace("<<", "").replace(">>", "")
            dst = m.group(7).replace("<<", "").replace(">>", "")
            out[tile].add((dst, src))
    return out


def enumerate_exact(pool_idx, cells_of, target, cap, node_cap):
    cov = collections.defaultdict(list)
    for i in pool_idx:
        for c in cells_of[i] & target:
            cov[c].append(i)
    orphan = [c for c in target if c not in cov]
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
        best, best_n = None, 1 << 30
        for c in target - covered:
            n = len(cov.get(c, ()))
            if n < best_n:
                best, best_n = c, n
                if n <= 1:
                    break
        if best is None or best_n == 0:
            return
        for i in cov[best]:
            if i in chosen:
                continue
            chosen.add(i)
            rec(covered | (cells_of[i] & target), chosen)
            chosen.discard(i)

    rec(set(), set())
    return sols, (nodes > node_cap or len(sols) >= cap), orphan, nodes


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", default=str(ROOT / "tamper" / "ref" / "ref.bit"))
    ap.add_argument("--truth", default=str(ROOT / "tamper" / "ref" / "pips_all.txt"))
    ap.add_argument("--json", default=str(ROOT / "step03_pip" / "out" / "g2_exact_cover.json"))
    ap.add_argument("--cap", type=int, default=200)
    ap.add_argument("--node-cap", type=int, default=400_000)
    ap.add_argument("--max-tiles", type=int, default=0)
    a = ap.parse_args()

    W = tl.World()
    raw = [(fam, src, frozenset(cells)) for fam, src, cells in W.cands["INT_L"]]
    truth_raw = load_truth(a.truth)
    all_names = {n for fam, src, _ in raw for n in (fam, src)}
    for tset in truth_raw.values():
        for dst, src in tset:
            all_names.add(dst)
            all_names.add(src)
    cm = canon_map(all_names)

    pool, cells_of = [], {}
    for fam, src, cells in raw:
        key = (cm[fam], cm[src])
        if key in cells_of:
            continue
        cells_of[key] = cells
        pool.append(key)
    cells_of = [cells_of[k] for k in pool]
    idx_of = {k: i for i, k in enumerate(pool)}
    truth = {t: {(cm[d], cm[s]) for d, s in v} for t, v in truth_raw.items()}

    M = tl.load_bits(a.bit)
    act = [int(t) for t in W.active_tiles(M)]
    if a.max_tiles:
        act = act[:a.max_tiles]

    stats = collections.Counter()
    nsol_hist = collections.Counter()
    rows = []
    for ti in act:
        name = W.tiles[ti][0] if isinstance(W.tiles[ti], (list, tuple)) else str(W.tiles[ti])
        obs = set(W.observed(M, ti))
        target = obs - WHITELIST
        if not target:
            continue
        cand = [i for i, cells in enumerate(cells_of) if cells <= obs]
        sols, trunc, orphan, nodes = enumerate_exact(cand, cells_of, target, a.cap, a.node_cap)
        T = truth.get(name, set())
        T_idx = frozenset(i for i in (idx_of.get(p) for p in T) if i is not None)
        nsol = len(sols)
        nsol_hist[nsol] += 1
        stats["tiles"] += 1
        if trunc:
            stats["trunc"] += 1
        if orphan:
            stats["orphan_tiles"] += 1
        if T:
            stats["tiles_with_truth"] += 1
            if T_idx in sols:
                stats["truth_is_solution"] += 1
            else:
                stats["truth_not_solution"] += 1
        if nsol == 1:
            stats["unique"] += 1
            sol = next(iter(sols))
            got = {pool[i] for i in sol}
            tp = len(got & T)
            stats["uniq_tp"] += tp
            stats["uniq_fp"] += len(got - T)
            stats["uniq_fn"] += len(T - got)
        else:
            stats["multi" if nsol > 1 else "zero"] += 1
            # 真值解之外的多余分支：是否为「格被真值全部点亮」的共位候选
            if T_idx:
                collateral = 0
                for sol in sols:
                    extra = {pool[i] for i in sol} - T
                    for fam, src in extra:
                        i = idx_of[(fam, src)]
                        if cells_of[i] <= {c for p in T for c in cells_of[idx_of[p]]}:
                            collateral += 1
                stats["multi_extra_collateral"] += 1 if collateral else 0
        rows.append({
            "tile": name, "nsol": nsol, "trunc": bool(trunc), "orphan": len(orphan),
            "truth_n": len(T), "truth_in_sols": bool(T_idx and T_idx in sols),
            "target_bits": len(target), "cand": len(cand), "nodes": nodes,
        })

    out = {
        "bit": str(a.bit), "stats": dict(stats), "nsol_hist": dict(nsol_hist),
        "pool": len(pool), "tiles": rows,
    }
    p = Path(a.json)
    p.parent.mkdir(parents=True, exist_ok=True)
    io.open(p, "w", encoding="utf-8", newline="\n").write(
        json.dumps(out, ensure_ascii=False, indent=1))

    print(f"候选池 {len(pool)} 条（归一化）")
    print(f"tile {stats['tiles']} ｜ 唯一解 {stats['unique']} ｜ 多解 {stats['multi']} ｜ 零解 {stats['zero']} ｜ 截断 {stats['trunc']} ｜ 有孤格 {stats['orphan_tiles']}")
    print(f"有真值的 tile {stats['tiles_with_truth']}｜真值∈解空间 {stats['truth_is_solution']}｜不在 {stats['truth_not_solution']}")
    print(f"唯一解 tile 上：TP {stats['uniq_tp']}／FP {stats['uniq_fp']}／FN {stats['uniq_fn']}")
    print("解数分布（前 8）：", nsol_hist.most_common(8))
    print(f"→ {p}")


if __name__ == "__main__":
    main()
