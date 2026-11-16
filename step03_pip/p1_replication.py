#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""P1 级补强：在 N 个独立设计上重跑 G2（精确覆盖 vs Vivado 真值）。

每个设计目录需含：
  <name>.bit     位流
  <name>.pips    `get_pips -of_objects [get_nets -hier]` 导出

输出：step03_pip/out/p1_replication.json + 屏幕汇总表
"""
from __future__ import annotations

import argparse
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


def build_pool(W, truth):
    raw = [(f, s, frozenset(c)) for f, s, c in W.cands["INT_L"]]
    names = {n for f, s, _ in raw for n in (f, s)}
    for ts in truth.values():
        for d, s in ts:
            names.add(d)
            names.add(s)
    cm = g.canon_map(names)
    cells, pool = {}, []
    for f, s, c in raw:
        k = (cm[f], cm[s])
        if k in cells:
            continue
        cells[k] = c
        pool.append(k)
    return cm, pool, [cells[k] for k in pool], {k: i for i, k in enumerate(pool)}


def one_design(W, name, bit, pips, cap=200, node_cap=400_000):
    truth_raw = g.load_truth(str(pips))
    cm, pool, cells_of, idx = build_pool(W, truth_raw)
    truth = {t: {(cm[d], cm[s]) for d, s in v} for t, v in truth_raw.items()}
    M = tl.load_bits(str(bit))
    st = collections.Counter()
    tiles = []
    for ti in W.active_tiles(M):
        tn = W.tiles[ti][0]
        obs = set(W.observed(M, ti))
        target = obs - g.WHITELIST
        if not target:
            st["tiles_empty_target"] += 1
            continue
        cand = [i for i, c in enumerate(cells_of) if c <= obs]
        sols, trunc, orphan, nodes = g.enumerate_exact(cand, cells_of, target, cap, node_cap)
        T = truth.get(tn, set())
        st["tiles"] += 1
        st["trunc"] += int(trunc)
        st["orphan"] += int(bool(orphan))
        if len(sols) == 1:
            st["unique"] += 1
            got = {pool[i] for i in next(iter(sols))}
        elif sols:
            st["multi"] += 1
            got = {pool[i] for i in next(iter(sols))}
        else:
            st["zero"] += 1
            continue
        if T:
            st["tiles_with_truth"] += 1
            if T == got:
                st["tiles_exact"] += 1
        # TP/FP/FN 用真值去重后的集合
        st["tp"] += len(got & T)
        st["fp"] += len(got - T)
        st["fn"] += len(T - got)
        tiles.append({"tile": tn, "nsol": len(sols), "truth_n": len(T)})
    prec = st["tp"] / max(1, st["tp"] + st["fp"])
    rec = st["tp"] / max(1, st["tp"] + st["fn"])
    return {
        "design": name, "bit": str(bit), "pips": str(pips),
        "active_tiles": st["tiles"] + st["tiles_empty_target"],
        "tiles": st["tiles"], "tiles_empty_target": st["tiles_empty_target"],
        "unique": st["unique"], "multi": st["multi"], "zero": st["zero"],
        "trunc": st["trunc"], "orphan": st["orphan"],
        "tiles_with_truth": st["tiles_with_truth"], "tiles_exact": st["tiles_exact"],
        "tp": st["tp"], "fp": st["fp"], "fn": st["fn"],
        "precision": round(prec, 4), "recall": round(rec, 4),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(ROOT / "tamper" / "ref" / "p1" / "out"))
    ap.add_argument("--json", default=str(ROOT / "step03_pip" / "out" / "p1_replication.json"))
    a = ap.parse_args()
    d = Path(a.dir)
    W = tl.World()
    rows = []
    for bit in sorted(d.glob("*.bit")):
        name = bit.stem
        pips = d / f"{name}.pips"
        if not pips.exists():
            print(f"skip {name}: no .pips")
            continue
        r = one_design(W, name, bit, pips)
        rows.append(r)
        print(f"{name:14s} tiles {r['tiles']:4d} 唯一 {r['unique']:4d} 多解 {r['multi']:3d} "
              f"真值tile {r['tiles_with_truth']:4d} 完全一致 {r['tiles_exact']:4d} "
              f"P {r['precision']:.4f} R {r['recall']:.4f} (TP {r['tp']} FP {r['fp']} FN {r['fn']})")
    out = {"designs": rows}
    p = Path(a.json)
    p.parent.mkdir(parents=True, exist_ok=True)
    io.open(p, "w", encoding="utf-8", newline="\n").write(json.dumps(out, ensure_ascii=False, indent=1))
    if rows:
        tp = sum(r["tp"] for r in rows)
        fp = sum(r["fp"] for r in rows)
        fn = sum(r["fn"] for r in rows)
        print(f"\n合计设计 {len(rows)} ｜ TP {tp} FP {fp} FN {fn} ｜ "
              f"P {tp/max(1,tp+fp):.4f} R {tp/max(1,tp+fn):.4f} ｜ "
              f"唯一解 {sum(r['unique'] for r in rows)}/{sum(r['tiles'] for r in rows)}")
    print(f"→ {p}")


if __name__ == "__main__":
    main()
