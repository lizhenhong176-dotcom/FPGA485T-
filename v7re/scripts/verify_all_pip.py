#!/usr/bin/env python3
"""verify_all_pip.py —— 统一的对账：mux 区（闭式）+ BEG6/4（二分结构）覆盖多少 feature。

对每个 `(family, src)` 的 sense=1 格集合，用对应模型重算并与实测比较：
  * mux 区 64 族  → `pip_reuse_law.json` 的 (pair, parity, primary, slots) 闭式；
  * BEG6/4 32 族  → `beg_families.json` 的 (A格, B格) 对；
  * 其余族         → 无模型，计入「未覆盖」。

用法：
    python verify_all_pip.py
    python verify_all_pip.py --tile-type INT_R
"""
import argparse
import collections
import json
import os
import re
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from pip_reuse_law import predict as predict_mux, COL_FRAMES, ROW_MIRROR  # noqa: E402

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
MUX_JSON = os.path.join(ROOT, "steps", "pip_reuse_law.json")
BEG_JSON = os.path.join(ROOT, "steps", "beg_families.json")


def load_cells(law_db, tile_type):
    con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    out = collections.defaultdict(set)
    for fam, src, fo, bit, sense, par in con.execute(
            "select family,src_wire,frame_off,bit,sense,parity from law_cells "
            "where tile_type=? and sense=1", (tile_type,)):
        out[(fam, src)].add((fo, par, bit))
    con.close()
    return out


def name_variants(name):
    """同一条线在 INT_L / INT_R 两侧的可能写法（INT_R 侧常省掉 `_L`）。

    `IMUX40` / `IMUX_L40`、`LOGIC_OUTS0` / `LOGIC_OUTS_L0`、
    `GCLK_B0_EAST` / `GCLK_B0_WEST` 都只是同一根 mux 输入线的两种叫法。
    """
    seen = []

    def add(x):
        if x and x not in seen:
            seen.append(x)

    add(name)
    for suf in ("_L", "_R"):
        if name.endswith(suf):
            add(name[:-2])
    m = re.match(r"^(.*?)(\d+)$", name)
    if m:
        add(m.group(1) + "_L" + m.group(2))
        add(m.group(1) + m.group(2))
    if name.endswith("_EAST"):
        add(name[:-5] + "_WEST")
    elif name.endswith("_WEST"):
        add(name[:-5] + "_EAST")
    # 时钟族：INT_R 叫 `GCLK_B0_EAST` / `GCLK_B10`，INT_L 叫 `GCLK_L_B0` / `GCLK_L_B10_WEST`
    m2 = re.match(r"^GCLK_B(\d+)(?:_(EAST|WEST))?$", name)
    if m2:
        for base in ("GCLK_L_B" + m2.group(1), "GCLK_B" + m2.group(1)):
            add(base)
            add(base + "_WEST")
            add(base + "_EAST")
    return seen


def norm_name(name, mux_fams, beg_fams):
    """在 `name_variants` 里挑一个能在这两张表里查到的写法，挑不到就原样返回。"""
    for cand in name_variants(name):
        if cand in mux_fams or cand in beg_fams:
            return cand
    return name


def norm_key(key, table):
    """源线名查表：挑一个在 `table` 里存在的写法。"""
    for cand in name_variants(key):
        if cand in table:
            return cand
    return key


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--tile-type", default="INT_L")
    ap.add_argument("--normalize", action="store_true",
                    help="INT_R 线名去掉 _L/_R 后缀后再查表")
    a = ap.parse_args()

    mux = json.load(open(MUX_JSON, encoding="utf-8"))
    beg = json.load(open(BEG_JSON, encoding="utf-8"))["families"]
    cells = load_cells(a.law_db, a.tile_type)

    fams = {f for f, _s in cells}
    stats = collections.Counter()
    bad = []
    mux_fams = set(mux["families"])
    for (fam, src), got in cells.items():
        exp = None
        fam_key, src_key = fam, src
        if a.normalize:
            fam_key = norm_name(fam, mux_fams, set(beg))
            src_key = norm_name(src, mux_fams, set(beg))
        if fam_key in mux["families"]:
            key = src_key
            if a.normalize:
                key = norm_key(src, mux["families"][fam_key]["slots"])
            if key not in mux["families"][fam_key]["slots"]:
                stats["mux_缺源"] += 1
                continue
            exp = {(fo, par, bit) for (fo, bit, par) in predict_mux(mux, fam_key, key)}
            kind = "mux"
        elif fam_key in beg:
            e = beg[fam_key]["sources"].get(src_key)
            if a.normalize:
                src_key = norm_key(src, beg[fam_key]["sources"])
                e = beg[fam_key]["sources"].get(src_key)
            if e is not None:
                exp = {tuple(c) for c in e}
            kind = "beg"
        else:
            stats["未覆盖"] += 1
            continue
        stats[kind + "_总"] += 1
        if exp is None:
            stats[kind + "_缺源"] += 1
            bad.append((fam, src, "缺源"))
        elif {tuple(c) for c in exp} == got:
            stats[kind + "_命中"] += 1
        else:
            stats[kind + "_不符"] += 1
            bad.append((fam, src, sorted(got), sorted(exp)))

    total_feat = len(cells)
    covered = stats["mux_总"] + stats["beg_总"]
    hit = stats["mux_命中"] + stats["beg_命中"]
    print("tile_type=%s  家族 %d  feature %d" % (a.tile_type, len(fams), total_feat))
    print("模型覆盖 feature：%d（%.1f%%）  精确命中：%d（%.1f%%）"
          % (covered, 100.0 * covered / total_feat, hit, 100.0 * hit / total_feat))
    for k in ("mux_总", "mux_命中", "mux_不符", "beg_总", "beg_命中", "beg_不符", "未覆盖"):
        print("  %-10s %d" % (k, stats[k]))
    covered_fams = len({f for f, _s in cells
                        if norm_name(f, mux_fams, set(beg)) in mux["families"]}
                       | {f for f, _s in cells
                          if norm_name(f, mux_fams, set(beg)) in beg})
    print("覆盖家族：%d / %d" % (covered_fams, len(fams)))
    for b in bad[:5]:
        print("  不符:", b)


if __name__ == "__main__":
    main()
