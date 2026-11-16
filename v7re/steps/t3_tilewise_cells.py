#!/usr/bin/env python3
"""T3 逐 tile 核账同一 family 的相对格集合（只读探针）。

问题：同一个 family（如 IMUX_L34、WW4BEG0）出现在很多 tile 上，
      它们的「格集合」在三个口径下分别是什么关系？
      ① abs  = (frame, word, bit)        绝对落点
      ② rel2 = (frame_off, word, bit)     减块基址，保留行项
      ③ rel3 = (frame_off, parity, bit)   再减去 2*(y%50) 的行项

数据：
  * 实例来源：_full8.pips（net TILE/TT.SRC->>DST，DST=family、SRC=驱动线）
  * 布局来源：pip_reuse_law.json（mux 区 64 族公式） + law_cells 表（其余族）
  * 观测来源：_full8.bit 的 payload 位（独立于上两者）

输出：t3_tilewise_out.txt（人读） + t3_tilewise_out.json（机读）
"""
import sys, os, json, collections

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)          # v7re
PROJ = os.path.dirname(ROOT)          # 项目根
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.join(ROOT, "scripts"))

import fasm2bit as F

PIPS = os.path.join(PROJ, "_full8.pips")
BIT = os.path.join(PROJ, "_full8.bit")
MODEL_DB = r"E:\v7work\model\v7_model.sqlite"

OUT = []
def w(s=""):
    OUT.append(s)
    print(s)

def cells_abs(base, y, cells):
    return sorted({(base + fo, F.Model.word_of(y, par), bit) for (fo, bit, par) in cells})

def cells_rel2(y, cells):
    return sorted({(fo, F.Model.word_of(y, par), bit) for (fo, bit, par) in cells})

def cells_rel3(cells):
    return sorted({(fo, par, bit) for (fo, bit, par) in cells})


def main():
    m = F.Model(r"E:\v7work\model\v7_law.sqlite",
                os.path.join(ROOT, "steps", "pip_reuse_law.json"),
                os.path.join(ROOT, "steps", "ecc_model.json"),
                MODEL_DB)
    data, sp, words = F.load_words(BIT)
    poff = F.payload_offset(words)
    nframes = (len(words) - poff) // F.FRAME_WORDS

    def widx(f, w_):
        return poff + f * F.FRAME_WORDS + w_

    def bit_at(f, w_, b):
        return (words[widx(f, w_)] >> b) & 1

    # ---------------- 实例抽取 ----------------
    raw = [l.strip() for l in open(PIPS, encoding="utf-8") if "->>" in l]
    inst = []
    for l in raw:
        lhs, dst = l.split("->>")
        path = lhs.split()[-1]
        tile = path.split("/")[0]
        src = path.split(".")[-1]
        tt = m.tiles.get(tile, (None,))[0]
        if tt not in ("INT_L", "INT_R"):
            continue
        inst.append({"tile": tile, "tt": tt, "src": src, "family": dst})

    w("=" * 78)
    w("T3 逐 tile 核账：同一 family 的格集合（三口径）")
    w("=" * 78)
    w("")
    w("[0] 输入")
    w("  实例文件 : _full8.pips   （含 '->>' 的行 %d 条，其中 INT tile %d 条）" % (len(raw), len(inst)))
    w("  位流     : _full8.bit   （payload %d 帧 x %d word）" % (nframes, F.FRAME_WORDS))
    w("  布局     : pip_reuse_law.json + v7_law.sqlite(law_cells)")
    w("  位序     : word 的 LSB = bit 0；word = 2*(y%50)+parity，>=50 时 +1")
    w("")

    # ---------------- 解析每条实例的格 ----------------
    resolved, zero_bit = [], []
    for it in inst:
        cells = m.cells_of(it["tt"], it["family"], it["src"])
        if not cells:
            zero_bit.append(it)
            continue
        tb = m.tile_base(it["tile"])
        if not tb:
            continue
        tt, base, y = tb
        it2 = dict(it)
        it2.update({"col": m.tiles[it["tile"]][1], "y": y, "base": base,
                    "cells": sorted(cells),
                    "abs": cells_abs(base, y, cells),
                    "rel2": cells_rel2(y, cells),
                    "rel3": cells_rel3(cells)})
        resolved.append(it2)

    w("[1] 实例解析总账")
    w("  有配置位的实例 : %d" % len(resolved))
    w("  零配置位实例   : %d   （见第 [9] 节）" % len(zero_bit))
    w("  去重 tile 数   : %d" % len({x["tile"] for x in resolved}))
    w("  出现 family 数 : %d" % len({x["family"] for x in resolved}))
    w("  每实例格数分布 : %s" % dict(collections.Counter(len(x["cells"]) for x in resolved)))
    w("")

    # ---------------- 目标 family 逐个核账 ----------------
    def account(family, src=None):
        sub = [x for x in resolved if x["family"] == family and (src is None or x["src"] == src)]
        if not sub:
            w("  （无实例）")
            return None, None
        w("  实例 %d 条，tile %d 个，来源 src %d 种" %
          (len(sub), len({x["tile"] for x in sub}), len({x["src"] for x in sub})))
        w("  %-16s %3s %3s %6s %-14s %-2s %-22s %-22s %-16s" %
          ("tile", "col", "y", "base", "src", "n", "abs(frame,word,bit)", "rel2(fo,word,bit)", "rel3(fo,par,bit)"))
        rows = []
        for x in sorted(sub, key=lambda z: (z["col"], z["y"])):
            w("  %-16s %3d %3d %6d %-14s %-2d %-22s %-22s %-16s" %
              (x["tile"], x["col"], x["y"], x["base"], x["src"], len(x["cells"]),
               ",".join("%d/%d/%d" % t for t in x["abs"]),
               ",".join("%d/%d/%d" % t for t in x["rel2"]),
               ",".join("%d/%d/%d" % t for t in x["rel3"])))
            rows.append(x)
        w("")
        # 三口径比对
        for label, key in (("abs", "abs"), ("rel2", "rel2"), ("rel3", "rel3")):
            sets = [tuple(x[key]) for x in rows]
            distinct = sorted({s for s in sets})
            w("  口径 %-5s : 不同集合种类 %d / %d 实例" % (label, len(distinct), len(sets)))
        base_set = rows[0]["rel3"]
        bad3 = [x["tile"] for x in rows if x["rel3"] != base_set]
        base2 = rows[0]["rel2"]
        bad2 = [x["tile"] for x in rows if x["rel2"] != base2]
        w("  以 %s 为基准：" % rows[0]["tile"])
        w("    rel3 不一致 tile 数 = %d   %s" % (len(bad3), bad3 if bad3 else ""))
        w("    rel2 不一致 tile 数 = %d   %s" % (len(bad2), bad2 if bad2 else ""))
        w("    abs  不一致 tile 数 = %d   （若=实例数，则每个 tile 的绝对落点都不同）"
          % sum(1 for x in rows if x["abs"] != rows[0]["abs"]))
        frames = sorted({t[0] for x in rows for t in x["abs"]})
        w("    abs 出现的帧号：%s" % frames)
        w("    abs 出现的 word：%s" % sorted({t[1] for x in rows for t in x["abs"]}))
        w("")
        return rows, bad3

    w("[2] IMUX_L34 · 沿列/行分布")
    r_imux, bad_imux = account("IMUX_L34")
    w("[3] WW4BEG0 · 全部来源")
    r_ww_all, bad_ww_all = account("WW4BEG0")
    w("[4] WW4BEG0 / WW4END0（T2 §2.1 的 14 tile 组合）")
    r_ww_ww, bad_ww_ww = account("WW4BEG0", "WW4END0")

    # ---------------- 按 (family, src) 分组 ----------------
    w("[5] 按 (family, src) 分组的「同名是否同布局」核账")
    w("    为什么必须分组：family 是 mux 的「汇」（sink），src 是「选中的那一根输入线」。")
    w("    同一个 family 在不同 tile 上选不同 src 时，格集合本来就该不同——那不是布局差异。")
    w("")
    sub_stats = {}
    for family in ("IMUX_L34", "WW4BEG0"):
        w("  == %s ==" % family)
        w("  %-18s %-3s %-5s %-10s %-10s %-10s" %
          ("src", "n", "格", "rel3种类", "rel2种类", "abs种类"))
        groups = collections.defaultdict(list)
        for x in resolved:
            if x["family"] == family:
                groups[x["src"]].append(x)
        for src in sorted(groups, key=lambda s: -len(groups[s])):
            g = groups[src]
            k3 = {tuple(x["rel3"]) for x in g}
            k2 = {tuple(x["rel2"]) for x in g}
            ka = {tuple(x["abs"]) for x in g}
            ncell = {len(x["cells"]) for x in g}
            w("  %-18s %-3d %-5s %-10d %-10d %-10d" %
              (src, len(g), ",".join(map(str, sorted(ncell))), len(k3), len(k2), len(ka)))
            sub_stats["%s/%s" % (family, src)] = {
                "n_tiles": len(g), "cells": sorted(ncell),
                "rel3_kinds": len(k3), "rel2_kinds": len(k2), "abs_kinds": len(ka),
                "tiles": sorted(x["tile"] for x in g)}
            if len(g) > 1 and len(k3) > 1:
                w("     !! rel3 不一致：")
                for k in sorted(k3):
                    w("        %s <- %s" % (k, [x["tile"] for x in g if tuple(x["rel3"]) == k]))
        w("")
        bad = [k for k, v in sub_stats.items()
               if k.startswith(family + "/") and v["n_tiles"] > 1 and v["rel3_kinds"] > 1]
        w("  多 tile 且 rel3 不一致的 (family,src) 组数 = %d %s" % (len(bad), bad if bad else ""))
        w("")

    # ---------------- 观测核对 ----------------
    w("[6] 观测核对（独立于表的位流读数）")
    miss = 0
    tot = 0
    for x in resolved:
        for (f, wd, b) in x["abs"]:
            tot += 1
            if f >= nframes:
                miss += 1
                continue
            if not bit_at(f, wd, b):
                miss += 1
    w("  预测格总数 %d，位流中未置位 %d" % (tot, miss))
    # 互斥核对：同 family 的「别的源」的格是否被点亮（必须 0，否则 mux 不互斥）
    other_lit = 0
    other_total = 0
    for x in resolved:
        mine = set(x["abs"])
        for s in m.all_sources(x["tt"], x["family"]):
            if s == x["src"]:
                continue
            c = m.cells_of(x["tt"], x["family"], s)
            if not c:
                continue
            for (f, wd, b) in cells_abs(x["base"], x["y"], c):
                if (f, wd, b) in mine:
                    continue
                other_total += 1
                other_lit += bit_at(f, wd, b)
    w("  同 family「其他源」候选格 %d 个，其中被点亮 %d 个（>0 则 mux 不互斥）"
      % (other_total, other_lit))
    w("")

    # ---------------- 窗口残差 ----------------
    w("[7] 窗口残差：目标 tile 的 (frame_off 0..25) x (word ∈ {2y,2y+1}) 内，")
    w("    置位位是否全部被某个已解 family 的预测格覆盖")
    targets = sorted({x["tile"] for x in resolved if x["family"] in ("IMUX_L34", "WW4BEG0")})
    fam_pats = {}
    for tt in ("INT_L", "INT_R"):
        fams = {k[1] for k in m.cells if k[0] == tt}
        if tt == "INT_L":
            fams |= set(m.law)
        dom = set()
        for fam in fams:
            for s in m.all_sources(tt, fam):
                c = m.cells_of(tt, fam, s)
                if c:
                    dom |= set(c)
        fam_pats[tt] = dom
    tot_res = 0
    for tile in targets:
        tt, base, y = m.tile_base(tile)
        words_ = {F.Model.word_of(y, 0), F.Model.word_of(y, 1)}
        obs = set()
        for fo in range(26):
            for wd in words_:
                v = words[widx(base + fo, wd)]
                while v:
                    b = (v & -v).bit_length() - 1
                    obs.add((fo, b, wd & 1))
                    v &= v - 1
        pred = {(fo, bit, par) for (fo, bit, par) in fam_pats.get(tt, set())}
        res = obs - pred
        tot_res += len(res)
        w("  %-16s obs=%3d pred覆盖=%3d 残余=%d" % (tile, len(obs), len(obs & pred), len(res)))
    w("  合计残余 %d 位（0 = 该窗口内没有被表遗漏的置位位）" % tot_res)
    w("")

    # ---------------- WW4END0 的角色 ----------------
    w("[8] WW4END0：它是 family 还是 wire")
    as_dst = [x for x in inst if x["family"] == "WW4END0"]
    as_src = [x for x in inst if x["src"] == "WW4END0"]
    w("  作为 DST（family）出现 : %d 条" % len(as_dst))
    w("  作为 SRC（驱动线）出现 : %d 条，被 %d 个不同 family 使用：%s"
      % (len(as_src), len({x["family"] for x in as_src}), sorted({x["family"] for x in as_src})))
    w("  law_cells 中 family='WW4END0' 的行数 : %d"
      % m.con.execute("select count(*) from law_cells where family='WW4END0'").fetchone()[0])
    w("")

    # ---------------- 零配置位伪 PIP ----------------
    w("[9] 零配置位实例（在 _full8.pips 里有名字、但表里无任何位）")
    w("  %-16s %-14s %-16s %s" % ("tile", "family(=DST)", "src(=SRC)", "law_ppips.kind"))
    for x in zero_bit:
        k = m.con.execute("select kind from law_ppips where tile_type=? and family=? and src_wire=?",
                          (x["tt"], x["family"], x["src"])).fetchone()
        w("  %-16s %-14s %-16s %s" % (x["tile"], x["family"], x["src"], k[0] if k else "(无记录)"))
    w("  合计 %d 条；这些名字与有位 family 共用同一命名空间。" % len(zero_bit))
    w("")

    # ---------------- JSON ----------------
    out = {
        "n_instances_total": len(inst),
        "n_resolved": len(resolved),
        "n_zero_bit": len(zero_bit),
        "n_tiles": len({x["tile"] for x in resolved}),
        "IMUX_L34": [{"tile": x["tile"], "col": x["col"], "y": x["y"], "base": x["base"],
                      "src": x["src"], "abs": x["abs"], "rel2": x["rel2"], "rel3": x["rel3"]}
                     for x in (r_imux or [])],
        "WW4BEG0": [{"tile": x["tile"], "col": x["col"], "y": x["y"], "base": x["base"],
                     "src": x["src"], "abs": x["abs"], "rel2": x["rel2"], "rel3": x["rel3"]}
                    for x in (r_ww_all or [])],
        "WW4BEG0__WW4END0": [{"tile": x["tile"], "col": x["col"], "y": x["y"], "base": x["base"],
                              "abs": x["abs"], "rel2": x["rel2"], "rel3": x["rel3"]}
                             for x in (r_ww_ww or [])],
        "substats": sub_stats,
        "zero_bit": zero_bit,
        "obs_missing": miss, "obs_total": tot,
        "other_src_total": other_total, "other_src_lit": other_lit,
        "window_residual": tot_res,
    }
    with open(os.path.join(HERE, "t3_tilewise_out.json"), "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=1)
    with open(os.path.join(HERE, "t3_tilewise_out.txt"), "w", encoding="utf-8") as f:
        f.write("\n".join(OUT) + "\n")
    print("\n-> t3_tilewise_out.txt / .json")


if __name__ == "__main__":
    main()
