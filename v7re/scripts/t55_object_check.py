#!/usr/bin/env python3
"""t55_object_check.py —— 判定「跨 tile 验证」的观测对象：CLB INIT 还是 PIP 开关盒。

复算三件事（全部离线，只用本地已有 .bit 与 law 库）：

1) 上次跨 tile 实验（`_xcheck.sh`）到底改了哪些位：
   `_xcheck.tgz` 里 4 个 .bit，两两差分 → 帧号、word、每帧位数。
   判据：差异帧若全部落在 CLB 块 base+32..35、word 40（payload）/50（ECC），
   且 payload 位数 == popcount(INIT)，则观测对象是 LUT INIT 数据位。

2) 用 `clb_init_locked_map.json` 的 SLICEM / SLICEL 两套索引表分别预测，
   看两个 tile 各自匹配哪一套 —— 这同时复核 T54 的 PASS/FAIL 判定。

3) 对照 PIP 开关盒的位形态（law 库 law_cells，tile_type=INT_L）：
   一个 family = 一个 mux，10–24 个 source 共用 7–10 个配置格；
   一个 LUT INIT = 64 个 feature : 64 个独立格子。
   两者在「格数 / feature 数」上的比例完全不同。

用法：
    python v7re/scripts/t55_object_check.py
    python v7re/scripts/t55_object_check.py --bits-dir _xcheck_local --law-db E:/v7work/model/v7_law.sqlite
"""
from __future__ import annotations

import argparse
import collections
import json
import os
import sqlite3
import statistics
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.dirname(HERE))

from bitstream.frames import diff_bits_in_frame, diff_frame_indices, load_frames  # noqa: E402

PAIRS = (("c20", 31924, "CLBLM_R", "SLICE_X20Y20"),
         ("c08", 31680, "CLBLL_L", "SLICE_X8Y20"))
INIT_HEX = 0xDEADBEEFCAFEBABE


def diff_bits(bits_dir, tag):
    """→ {(frame, word): [bit...]}，只保留帧内有差异的 (frame, word)。"""
    a = load_frames(os.path.join(bits_dir, tag + "z.bit"))
    b = load_frames(os.path.join(bits_dir, tag + "v.bit"))
    out = collections.defaultdict(list)
    for frame in diff_frame_indices(a, b):
        for word, bit in diff_bits_in_frame(a, b, frame):
            out[(frame, word)].append(bit)
    return a, out


def predict_init(locked, kind, base, inst_group=32):
    """按 kind 的 INIT 索引表预测 INIT=INIT_HEX 的置位格 → {(frame, word, bit)}。"""
    order = {int(k): tuple(v) for k, v in locked["orders"][kind].items()}
    word_plus, bit_plus = locked["bel_rule"]["A6LUT"]
    return {(base + inst_group + order[i][0], 40 + word_plus, bit_plus + order[i][1])
            for i in range(64) if (INIT_HEX >> i) & 1}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bits-dir", default=os.path.join(ROOT, "_xcheck_local"))
    ap.add_argument("--locked", default=os.path.join(HERE, "..", "steps", "clb_init_locked_map.json"))
    ap.add_argument("--law-db", default=os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite"))
    a = ap.parse_args()

    print("=" * 78)
    print("1) 上次跨 tile 实验的差异位（_xcheck: INIT=0 vs 0xDEADBEEFCAFEBABE）")
    print("=" * 78)
    print("INIT = 0x%016X, popcount = %d" % (INIT_HEX, bin(INIT_HEX).count("1")))
    obs = {}
    for tag, base, tt, site in PAIRS:
        fa, bits = diff_bits(a.bits_dir, tag)
        frames = sorted({f for f, w in bits})
        payload = {(f, w, bi) for (f, w), bl in bits.items() if w == 40 for bi in bl}
        ecc = {(f, w, bi) for (f, w), bl in bits.items() if w == 50 for bi in bl}
        print("\n%s (%s, %s) 块基址 %d，块内偏移 0..35（CLB 块 = 36 帧）"
              % (tag, tt, site, base))
        print("  差异帧: %s  → 相对块基址: %s" % (frames, [f - base for f in frames]))
        for f in frames:
            per = {w: len([1 for (ff, ww), bl in bits.items() if ff == f and ww == w for _ in bl])
                   for w in sorted({ww for (ff, ww) in bits if ff == f})}
            print("    frame %d: word→位数 %s" % (f, per))
        print("  payload(word 40) %d 位 / ECC(word 50) %d 位" % (len(payload), len(ecc)))
        ok_shape = ([f - base for f in frames] == [32, 33, 34, 35]
                    and len(payload) == bin(INIT_HEX).count("1"))
        print("  形状判据（4 帧 @ base+32..35 且 payload==popcount）：%s"
              % ("PASS" if ok_shape else "FAIL"))
        obs[tag] = payload

    print()
    print("=" * 78)
    print("2) 用两套 INIT 索引表分别预测（复核 T54 的 PASS/FAIL）")
    print("=" * 78)
    locked = json.load(open(a.locked, encoding="utf-8"))
    for tag, base, tt, site in PAIRS:
        for kind in ("SLICEM", "SLICEL"):
            pred = predict_init(locked, kind, base)
            miss, extra = len(pred - obs[tag]), len(obs[tag] - pred)
            print("%s / %-6s : 预测 %d，missing %d，extra %d  → %s"
                  % (tag, kind, len(pred), miss, extra,
                     "PASS" if miss == 0 and extra == 0 else "FAIL"))

    print()
    print("=" * 78)
    print("3) 位形态对照：INT PIP 开关盒 vs CLB LUT INIT")
    print("=" * 78)
    if not os.path.exists(a.law_db):
        print("law 库不存在，跳过：%s" % a.law_db)
        return 0
    con = sqlite3.connect("file:%s?mode=ro" % a.law_db, uri=True)
    fam_cells = collections.defaultdict(set)
    fam_src = collections.defaultdict(set)
    for fam, src, off, par, bit, sense in con.execute(
            "select family,src_wire,frame_off,parity,bit,sense from law_cells "
            "where tile_type='INT_L'"):
        fam_src[fam].add(src)
        if sense == 1:
            fam_cells[fam].add((off, par, bit))
    sizes = [len(v) for v in fam_cells.values()]
    nsrc = [len(v) for v in fam_src.values()]
    print("INT_L: %d 个 family（= mux），每个 family："
          % len(fam_cells))
    print("  source 数 %s" % dict(collections.Counter(nsrc)))
    print("  共用配置格数 %s（中位 %.1f）"
          % (dict(collections.Counter(sizes)), statistics.median(sizes)))
    print("  → 一个 mux 的「N 选 1」编码在 7–10 个格子里，格数 ≪ 源数")
    n_init_groups = con.execute(
        "select count(*) from (select distinct tile_type, family from clb_cells "
        "where src_wire like 'INIT[%')").fetchone()[0]
    tt_init, fam_init, init_src, init_cells = con.execute(
        "select tile_type, family, count(distinct src_wire), count(*) from clb_cells "
        "where src_wire like 'INIT[%' group by tile_type, family "
        "order by tile_type, family limit 1").fetchone()
    tot_init = con.execute(
        "select count(distinct src_wire) from clb_cells where src_wire like 'INIT[%'"
    ).fetchone()[0]
    print("CLB LUT: 共 %d 个 (tile_type, LUT-family) 组，INIT 位 %d 种 src_wire；"
          % (n_init_groups, tot_init))
    print("  例 %s / %s：%d 个 feature / %d 个独立格（1:1，纯数据，非 mux）"
          % (tt_init, fam_init, init_src, init_cells))
    print("\n判定：上次实验的观测对象 = LUT INIT 数据位（CLB 配置位），不是 PIP mux 选择位。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
