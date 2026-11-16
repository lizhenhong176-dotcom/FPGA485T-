#!/usr/bin/env python3
"""beg_families.py —— BEG6/4 家族的二分图结构与可验证预测。

背景（T3 §9）：帧 2–7 上的 32 个 BEG 家族，每个家族的 24 个源呈**完全二分图 K(4,5)**：
    源 = (A 侧一个格) × (B 侧一个格)，边集 = 4×5 = 20 条，全部用满。
每个源只占 **2 个格**（A 侧一格 + B 侧一格），这与 mux 区的 2–4 格不同。

本脚本：
  1. 取帧 2..7 的家族，把「源 → 2 个格」看成图的一条边，做二分判定并验证 K(m,n)；
  2. 用「源 = (A格, B格)」重建每个 (family, src) 的格集合，与实测逐条对账；
  3. 输出结构参数 JSON。

用法：
    python beg_families.py --build      # 建结构并验证
    python beg_families.py --report     # 只打印统计
"""
import argparse
import collections
import json
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
OUT = os.path.join(ROOT, "steps", "beg_families.json")
FRAMES = range(2, 8)


def load(law_db, tile_type="INT_L"):
    con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    cells = collections.defaultdict(set)
    for fam, src, fo, bit, sense, par in con.execute(
            "select family,src_wire,frame_off,bit,sense,parity from law_cells "
            "where tile_type=? and sense=1", (tile_type,)):
        cells[(fam, src)].add((fo, par, bit))
    con.close()
    # 只保留完全落在帧 2..7 的家族
    fams = collections.defaultdict(list)
    for (fam, src), cs in cells.items():
        if all(fo in FRAMES for fo, _p, _b in cs):
            fams[fam].append(src)
    return {f: {s: cells[(f, s)] for s in srcs} for f, srcs in fams.items()
            if len(srcs) >= 12}


def bipartite(cells_by_src):
    """源=边、格=节点。返回 (A侧, B侧, 是否二分, 每源所属端)。"""
    adj = collections.defaultdict(set)
    for src, cs in cells_by_src.items():
        cs = list(cs)
        if len(cs) != 2:
            return None
        a, b = cs
        adj[a].add(b)
        adj[b].add(a)
    color = {}
    for start in adj:
        if start in color:
            continue
        color[start] = 0
        q = [start]
        while q:
            n = q.pop()
            for m in adj[n]:
                if m in color:
                    if color[m] == color[n]:
                        return None
                else:
                    color[m] = 1 - color[n]
                    q.append(m)
    A = {n for n, c in color.items() if c == 0}
    B = {n for n, c in color.items() if c == 1}
    return A, B


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--tile-type", default="INT_L")
    ap.add_argument("--build", action="store_true")
    ap.add_argument("--report", action="store_true")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()

    fams = load(a.law_db, a.tile_type)
    print("帧 %d–%d 家族数：%d" % (FRAMES[0], FRAMES[-1], len(fams)))

    shapes = collections.Counter()
    ok_cnt = bad = notbip = 0
    out = {}
    for fam, cells_by_src in sorted(fams.items()):
        r = bipartite(cells_by_src)
        if r is None:
            notbip += 1
            shapes["非二分/非2格"] += 1
            continue
        A, B = r
        def key(x, y):
            return tuple(sorted((x, y)))

        edges = {key(n, m) for n in A for m in B}
        used = {key(*list(cs)) for cs in cells_by_src.values()}
        complete = used == edges
        shapes["K(%d,%d)%s" % (len(A), len(B), "" if complete else "不全")] += 1
        # 用 (A格,B格) 重建并逐条对账
        rebuild_ok = used <= edges
        if complete and rebuild_ok:
            ok_cnt += 1
            out[fam] = {"A": sorted([list(x) for x in A]), "B": sorted([list(x) for x in B]),
                        "sources": {src: sorted([list(x) for x in cs])
                                    for src, cs in cells_by_src.items()}}
        else:
            bad += 1
        if a.report:
            print("  %-12s 源 %2d  A %d  B %d  完全=%s 重建=%s"
                  % (fam, len(cells_by_src), len(A), len(B), complete, rebuild_ok))
    print("形状分布:", dict(shapes))
    print("完全二分且可重建：%d / %d（非二分 %d，异常 %d）" % (ok_cnt, len(fams), notbip, bad))
    feats = sum(len(v) for v in fams.values())
    print("覆盖 feature 数：%d" % feats)
    if a.build:
        with open(a.out, "w", encoding="utf-8") as fh:
            json.dump({"tile_type": a.tile_type, "frames": [FRAMES[0], FRAMES[-1] - 1],
                       "families": out}, fh, indent=0)
        print("写出 %s（%d 族）" % (a.out, len(out)))


if __name__ == "__main__":
    main()
