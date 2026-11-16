#!/usr/bin/env python3
"""prune_chains.py —— 用 net 链连通性消解 2 格 pattern 的歧义（T6c）。

问题：位流解码（`roundtrip.py`）在 `--min-cells 2` 时召回 96%，但精确率只有 67%：
2 格 pattern 会被邻居顺带点亮的位误命中。仅凭位无法区分。

思路：一条 net 的 PIP 链必须首尾相接。若某条候选 PIP 的源线在本 tile / 相邻 tile
里根本没有任何「已解码 PIP 的输出」驱动它，而该源线本身又不是 net 根，它就是误判。

连接关系（离线、不跑 Vivado）：
  * 同 tile：`routing/out_routing/templates/<TYPE>.json` 的 `pip_defs`（src→dst）
  * 跨 tile：`v7_routing.db` 的 `conn_rules(type, wire, dx, dy, target_type, target_wire)`

用法：
  python prune_chains.py --bit _full8.bit --pips _full8.pips --min-cells 2
"""
import argparse
import collections
import json
import os
import sqlite3
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
import roundtrip as rt  # noqa: E402

ROUTING_DB = os.environ.get(
    "V7RE_ROUTING_DB", r"E:\v7work\_curated_20261021\routing\v7_routing.db")
TEMPLATES = os.environ.get(
    "V7RE_TEMPLATES", r"E:\v7work\_curated_20261021\routing\out_routing\templates")


def load_templates(types):
    """TYPE → {dst: {src,...}}（同 tile 内驱动关系）"""
    out = {}
    for tt in types:
        p = os.path.join(TEMPLATES, tt + ".json")
        if not os.path.exists(p):
            continue
        j = json.load(open(p, encoding="utf-8"))
        d = collections.defaultdict(set)
        for src, dst, _i, _b in j["pip_defs"]:
            d[dst].add(src)
        out[tt] = d
    return out


def load_rules(ttypes):
    """(target_type, target_wire) → [(source_type, source_wire, dx, dy)]"""
    con = sqlite3.connect("file:%s?mode=ro" % ROUTING_DB, uri=True)
    idx = collections.defaultdict(list)
    q = ("select type, wire, dx, dy, target_type, target_wire from conn_rules "
         "where target_type in (%s)" % ",".join("?" * len(ttypes)))
    for stype, swire, dx, dy, ttype, twire in con.execute(q, tuple(ttypes)):
        idx[(ttype, twire)].append((stype, swire, int(dx), int(dy)))
    con.close()
    return idx


def tile_grid():
    con = sqlite3.connect("file:%s?mode=ro" % ROUTING_DB, uri=True)
    grid = {}
    for name, ttype, gx, gy in con.execute(
            "select tile_name, type, grid_x, grid_y from tiles"):
        grid[(int(gx), int(gy))] = (name, ttype)
    con.close()
    return grid


def grid_of(name):
    """tile 名 → (gx, gy)，用于定位；名字形如 INT_L_X8Y20。"""
    parts = name.rsplit("_", 2)
    if len(parts) != 3:
        return None
    try:
        return int(parts[1][1:]), int(parts[2][1:])
    except ValueError:
        return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", required=True)
    ap.add_argument("--pips", required=True)
    ap.add_argument("--law", default=os.path.join(ROOT, "steps", "pip_reuse_law.json"))
    ap.add_argument("--min-cells", type=int, default=2)
    ap.add_argument("--rounds", type=int, default=3)
    a = ap.parse_args()

    model = json.load(open(a.law, encoding="utf-8"))
    names, ttypes, cols, ys, bases = rt.load_tiles(rt.LAW_DB)
    con = sqlite3.connect("file:%s?mode=ro" % rt.LAW_DB, uri=True)
    fb = collections.defaultdict(list)
    for fam, src, ctt, fo, bit, par, se in con.execute(
            "select family,src_wire,tile_type,frame_off,bit,parity,sense from law_cells "
            "where tile_type in ('INT_L','INT_R')"):
        fb[(fam, src)].append((fo, bit, par, se))
    con.close()

    cands = rt.candidates(model, fb, ("INT_L", "INT_R"))
    M = rt.load_bits(a.bit)
    words = {p: rt.word_of(ys, p) for p in (0, 1)}
    dec = set()
    for tt, fam, src, cells in cands:
        if len(cells) < a.min_cells:
            continue
        sel = ttypes == tt
        if not sel.any():
            continue
        b = bases[sel]
        ok = np.logical_and.reduce(
            [M[b + fo, words[par][sel], bit] > 0 for (fo, bit, par) in cells])
        idxs = np.nonzero(sel)[0]
        for i in np.nonzero(ok)[0]:
            dec.add((names[int(idxs[i])], src, fam))

    tpl = load_templates(("INT_L", "INT_R"))
    rules = load_rules(("INT_L", "INT_R"))
    grid = tile_grid()

    def name_at(gx, gy):
        v = grid.get((gx, gy))
        return v[0] if v else None

    def driven_by(rec, dstset):
        """rec=(tile, src, fam) 的源线是否被 dstset 中某条 PIP 驱动（或为 net 根）。"""
        tile, src, _ = rec
        tt = "INT_L" if tile.startswith("INT_L_") else "INT_R"
        possible = False
        # 同 tile
        for d in tpl.get(tt, {}).get(src, ()):
            possible = True
            if (tile, d) in dstset:
                return True
        # 跨 tile
        pos = grid_of(tile)
        if pos:
            for (stype, swire, dx, dy) in rules.get((tt, src), ()):
                possible = True
                nb = name_at(pos[0] - dx, pos[1] - dy)
                if nb and (nb, swire) in dstset:
                    return True
        return not possible   # 没有任何驱动可能 → net 根，保留

    cur = set(dec)
    for r in range(a.rounds):
        dstset = {(t, f) for (t, s, f) in cur}
        keep = {rec for rec in cur if driven_by(rec, dstset)}
        dropped = len(cur) - len(keep)
        cur = keep
        print("第 %d 轮：保留 %d，剪掉 %d" % (r + 1, len(cur), dropped))
        if not dropped:
            break

    # 对账
    tru = set()
    for line in open(a.pips, encoding="utf-8"):
        p = line.split()
        if len(p) < 2 or "->>" not in p[1]:
            continue
        tile, rest = p[1].split("/", 1)
        if not tile.startswith(("INT_L_", "INT_R_")):
            continue
        s, d = rest.split("->>")
        s = s.split(".", 1)[1] if "." in s else s
        tru.add((tile, s, d))
    for tag, S in (("剪枝前", dec), ("剪枝后", cur)):
        tp, fp, fn = S & tru, S - tru, tru - S
        print("%-6s 解码 %3d 命中 %3d 多 %2d 漏 %2d 精确率 %5.1f%% 召回 %5.1f%%"
              % (tag, len(S), len(tp), len(fp), len(fn),
                 100 * len(tp) / max(len(S), 1), 100 * len(tp) / max(len(tru), 1)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
