#!/usr/bin/env python3
"""
reuse_stats.py —— PIP「复用规则」的量化统计（只读，不改任何数据）。

回答四个问题：
  1. 位域归属：一个 cell（frame_off, parity, bit）属于几个 family？跨 family 共享吗？
  2. 复用度  ：一个 cell 被多少个 feature（family,src）置 1？
  3. 编码    ：family 内 N 个源共用 k 格域，码是否唯一？
  4. 覆盖率  ：本地实测证据（tilepipe / famdiff / famdiff_r / 列扫描 / bands2）
               覆盖了 3,636 个 feature 里的多少个？

用法：python reuse_stats.py [--md]
"""
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def cell(x):
    return (x["frame_off"], x.get("parity", 0), x["bit"])


def load(name):
    p = os.path.join(HERE, name)
    if not os.path.exists(p):
        return None
    with open(p, encoding="utf-8-sig") as fh:
        return json.load(fh)


def side_stats(recs, t):
    rs = [x for x in recs if x["tile_type"] == t]
    cellfam = collections.defaultdict(set)
    cellfeat = collections.Counter()
    dom = collections.defaultdict(set)
    src = collections.defaultdict(set)
    code = collections.defaultdict(dict)
    ones = 0
    for x in rs:
        c = cell(x)
        cellfam[c].add(x["family"])
        dom[x["family"]].add(c)
        src[x["family"]].add(x["src_wire"])
        if x["sense"] == 1:
            cellfeat[c] += 1
            ones += 1
            code[(x["family"], x["src_wire"])][c] = 1
    feats = {(x["family"], x["src_wire"]) for x in rs}
    inj = sum(1 for f in dom
              if len({tuple(sorted(p)) for (ff, s), p in code.items() if ff == f})
              == len(src[f]))
    off_zone = collections.defaultdict(set)
    for x in rs:
        off_zone[x["frame_off"]].add(x["family"])
    return {
        "tile_type": t,
        "records": len(rs),
        "cells": len(cellfam),
        "features": len(feats),
        "families": len(dom),
        "cell_exclusive": sum(1 for v in cellfam.values() if len(v) == 1),
        "cell_shared": sum(1 for v in cellfam.values() if len(v) > 1),
        "feat_per_cell_min": min(cellfeat.values()),
        "feat_per_cell_max": max(cellfeat.values()),
        "feat_per_cell_mean": round(sum(cellfeat.values()) / len(cellfeat), 2),
        "sense1_records": ones,
        "sense1_per_feature": round(ones / len(feats), 2),
        "unique_code_families": inj,
        "domain_hist": dict(collections.Counter(len(v) for v in dom.values())),
        "src_hist": dict(collections.Counter(len(v) for v in src.values())),
        "zone": {off: len(f) for off, f in sorted(off_zone.items())},
        "cell_density": round(100 * len(cellfam) / (26 * 2 * 32), 1),
    }


def coverage(recs):
    """本地实测证据覆盖了多少 feature。"""
    feats = {(x["tile_type"], x["family"], x["src_wire"]) for x in recs}
    seen = set()
    detail = {}

    # tilepipe 系（纯 PIP 差分，ref 已删 sink PIP）：键 → {sink, sources}
    for fn, tt in (("tilepipe.json", "INT_L"), ("tp3.json", "INT_L"),
                   ("tp2.json", "INT_R"), ("tp4b.json", "INT_R")):
        tp = load(fn)
        if not tp:
            continue
        n = 0
        for tag, v in tp.items():
            if not isinstance(v, dict):
                continue
            sink = (v.get("sink") or "").strip()
            for w in (v.get("sources") or {}):
                if sink:
                    seen.add((tt, sink, w))
                    n += 1
        detail[fn] = n

    # famdiff / famdiff_r：键形如 v_<FAMILY>_<SRC>，按最长 family 名匹配
    fams = sorted({(x["tile_type"], x["family"]) for x in recs}, key=lambda z: -len(z[1]))
    for fn, tt in (("famdiff.json", "INT_L"), ("famdiff_r.json", "INT_R")):
        d = load(fn)
        if not d:
            continue
        got = 0
        for k in d:
            stem = k[2:] if k.startswith("v_") else k
            for _t, fam in fams:
                if _t != tt or not stem.startswith(fam + "_"):
                    continue
                s = stem[len(fam) + 1:]
                if (tt, fam, s) in feats:
                    seen.add((tt, fam, s))
                    got += 1
                break
        detail[fn + "(matched)"] = got

    per_side = collections.Counter(t for t, f, s in seen)
    total = collections.Counter(t for t, f, s in feats)
    return {
        "observed_features": len(seen),
        "per_side": {t: (per_side[t], total[t], round(100 * per_side[t] / total[t], 1))
                     for t in sorted(total)},
        "detail": detail,
    }


def main():
    recs = load("all_cells.json")
    if recs is None:
        print("缺少 all_cells.json", file=sys.stderr)
        return 1
    out = {"sides": [side_stats(recs, t) for t in ("INT_L", "INT_R")],
           "coverage": coverage(recs)}
    if "--md" in sys.argv:
        for s in out["sides"]:
            print(f"\n### {s['tile_type']}")
            for k in ("records", "cells", "features", "families", "cell_exclusive",
                      "cell_shared", "feat_per_cell_min", "feat_per_cell_max",
                      "feat_per_cell_mean", "sense1_records", "sense1_per_feature",
                      "unique_code_families", "cell_density"):
                print(f"- {k}: {s[k]}")
            print(f"- domain_hist: {s['domain_hist']}")
            print(f"- src_hist: {s['src_hist']}")
            print(f"- zone(frame_off→family 数): {s['zone']}")
        print("\n### 覆盖率")
        print(json.dumps(out["coverage"], ensure_ascii=False, indent=1))
    else:
        with open(os.path.join(HERE, "reuse_stats.json"), "w", encoding="utf-8") as fh:
            json.dump(out, fh, ensure_ascii=False, indent=1)
        print("写出 reuse_stats.json")
        for s in out["sides"]:
            print(f"  {s['tile_type']}: cell {s['cells']} 独占 {s['cell_exclusive']} "
                  f"共享 {s['cell_shared']} | feature {s['features']} family {s['families']} "
                  f"| 每 cell 被 {s['feat_per_cell_min']}..{s['feat_per_cell_max']} "
                  f"个 feature 置1(均 {s['feat_per_cell_mean']}) | 唯一码 {s['unique_code_families']}/{s['families']}")
        print("  覆盖:", json.dumps(out["coverage"]["per_side"], ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
