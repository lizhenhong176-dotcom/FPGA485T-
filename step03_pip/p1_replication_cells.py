#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""P1 级补强：在远端 8 个独立设计上跑 G2（精确覆盖 vs Vivado 真值）。

输入（每个设计一组）：
  <name>.cells.txt   `frame word bit`（该位流里所有置 1 的配置位）
  <name>.pips        `get_pips -of_objects [get_nets -hier]` 导出

做法：把 (frame,word,bit) 归到 INT tile 的 (frame_off,word,bit)，构成观测位集，
      再用与 G2 完全相同的精确覆盖判据与真值对账。
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
import p1_replication as p1                        # noqa: E402

HI = 26


BAND = [6, 5, 0, 1, 2, 3, 4]


def word_row(word):
    """word -> (row, parity)；word 50 是 ECC，返回 None。"""
    if word == 50:
        return None
    w = word if word < 50 else word - 1
    return (w // 2, w % 2)


def obs_from_cells(W, path):
    """frame/word/bit -> {tile_index: set((frame_off, word, bit))}

    一帧被同一 (band,col) 的 50 个 tile 共享，各自用不同的 word；
    所以必须按 word -> row 把位分给正确的 tile。
    """
    idx = {}
    spans = []
    seen = set()
    for ti, (name, tt, col, y, base) in enumerate(W.tiles):
        if base is None:
            continue
        band = BAND[y // 50]
        idx[(band, col, y % 50)] = ti
        key = (band, col, base)
        if key not in seen:
            seen.add(key)
            spans.append(key)
    obs = collections.defaultdict(set)
    with io.open(path, encoding="utf-8") as f:
        for line in f:
            parts = line.split()
            if len(parts) != 3:
                continue
            fr, w, b = int(parts[0]), int(parts[1]), int(parts[2])
            rp = word_row(w)
            if rp is None:
                continue
            for band, col, base in spans:
                fo = fr - base
                if 0 <= fo < HI:
                    ti = idx.get((band, col, rp[0]))
                    if ti is not None:
                        obs[ti].add((fo, b, rp[1]))
                    break
    return obs


def one_design(W, name, cells, pips, pool, cells_of, idx, cm, cap=200, node_cap=400_000):
    truth_raw = g.load_truth(str(pips))
    truth = {t: {(cm[d], cm[s]) for d, s in v} for t, v in truth_raw.items()}
    obs = obs_from_cells(W, cells)
    st = collections.Counter()
    st["outside_bits"] = 0
    for ti, o in obs.items():
        tn = W.tiles[ti][0]
        target = set(o) - g.WHITELIST
        if not target:
            st["empty"] += 1
            continue
        cand = [i for i, c in enumerate(cells_of) if c <= o]
        cover = set()
        for i in cand:
            cover |= cells_of[i]
        outside = target - cover          # 模型外位（表外格），单独计数
        target = target & cover
        st["outside_bits"] += len(outside)
        sols, trunc, orphan, _ = g.enumerate_exact(cand, cells_of, target, cap, node_cap)
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
            st["with_truth"] += 1
            st["exact"] += int(T == got)
        st["tp"] += len(got & T)
        st["fp"] += len(got - T)
        st["fn"] += len(T - got)
    prec = st["tp"] / max(1, st["tp"] + st["fp"])
    rec = st["tp"] / max(1, st["tp"] + st["fn"])
    return {
        "design": name,
        "tiles": st["tiles"], "empty": st["empty"],
        "unique": st["unique"], "multi": st["multi"], "zero": st["zero"],
        "trunc": st["trunc"], "orphan": st["orphan"],
        "with_truth": st["with_truth"], "exact": st["exact"],
        "tp": st["tp"], "fp": st["fp"], "fn": st["fn"],
        "outside_bits": st["outside_bits"],
        "precision": round(prec, 4), "recall": round(rec, 4),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", default=str(ROOT / "tamper" / "ref" / "p1" / "remote" / "out"))
    ap.add_argument("--json", default=str(ROOT / "step03_pip" / "out" / "p1_replication.json"))
    a = ap.parse_args()
    d = Path(a.dir)
    W = tl.World()
    truth_all = {}
    rows = []
    files = sorted(d.glob("*.cells.txt"))
    for cells in files:
        name = cells.name[:-len(".cells.txt")]
        pips = d / (name + ".pips")
        if not pips.exists():
            print("skip", name)
            continue
        truth_all.update(g.load_truth(str(pips)))
        cm, pool, cells_of, idx = p1.build_pool(W, truth_all)
        r = one_design(W, name, cells, pips, pool, cells_of, idx, cm)
        rows.append(r)
        print("%-12s tiles %4d 唯一 %4d 多解 %3d 零解 %2d 表外位 %3d 真值tile %4d 全对 %4d "
              "P %.4f R %.4f (TP %4d FP %3d FN %3d)" % (
                  name, r["tiles"], r["unique"], r["multi"], r["zero"], r["outside_bits"],
                  r["with_truth"], r["exact"], r["precision"], r["recall"],
                  r["tp"], r["fp"], r["fn"]))
    out = {"designs": rows}
    p = Path(a.json)
    p.parent.mkdir(parents=True, exist_ok=True)
    io.open(p, "w", encoding="utf-8", newline="\n").write(json.dumps(out, ensure_ascii=False, indent=1))
    if rows:
        tp = sum(r["tp"] for r in rows)
        fp = sum(r["fp"] for r in rows)
        fn = sum(r["fn"] for r in rows)
        tiles = sum(r["tiles"] for r in rows)
        uniq = sum(r["unique"] for r in rows)
        print("\n合计 %d 设计 ｜ tile %d ｜ 唯一解 %d ｜ TP %d FP %d FN %d ｜ P %.4f R %.4f" % (
            len(rows), tiles, uniq, tp, fp, fn, tp / max(1, tp + fp), tp / max(1, tp + fn)))
    print("→", p)


if __name__ == "__main__":
    main()
