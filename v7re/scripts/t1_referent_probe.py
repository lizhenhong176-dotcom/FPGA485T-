#!/usr/bin/env python3
"""t1_referent_probe.py —— 为「两个一样的」指代解析提供可复算证据（只读）。

回答四个问题，全部离线：
1) `_xcheck_local` 的 c08 / c20 两个构建，逐帧 payload 位集合是什么？
2) 是否存在 4 帧的双射 mu 使 c08 与 c20 的格集合完全相等（missing=0 / extra=0）？
   24 种双射全部枚举，打印每种的行数差。
3) `clb_init_locked_map.json` 的 SLICEM / SLICEL 两张 INIT 表：
   64 个索引的 bit 是否逐位相同？帧号映射 sigma 是什么？sigma 是否让实测集合相等？
4) 两条被否掉的候选帧映射（XOR2、67-rel 镜像）与真映射 sigma 在哪些帧上重合？
   同时复算：解码 tile 数（76 = INT_L 70 + INT_R 6）与 law 库的「格」重复计数口径。

用法：python v7re/scripts/t1_referent_probe.py
"""
from __future__ import annotations

import collections
import itertools
import json
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, os.path.dirname(HERE))

from bitstream.frames import diff_bits_in_frame, diff_frame_indices, load_frames  # noqa: E402

BITS = os.path.join(ROOT, "_xcheck_local")
PAIRS = (("c20", 31924), ("c08", 31680))
FRAMES = [32, 33, 34, 35]


def payload_sets(tag, base):
    a = load_frames(os.path.join(BITS, tag + "z.bit"))
    b = load_frames(os.path.join(BITS, tag + "v.bit"))
    out = collections.defaultdict(set)
    for fr in diff_frame_indices(a, b):
        for w, bit in diff_bits_in_frame(a, b, fr):
            if w == 40:
                out[fr - base].add(bit)
    return {f: out[f] for f in FRAMES if f in out}


def p1(s08, s20):
    print("=" * 78)
    print("1) 两个构建的 payload 位集合（word 40，相对块基址）")
    print("=" * 78)
    for name, s in (("c20 (CLBLM_R, SLICE_X20Y20)", s20), ("c08 (CLBLL_L, SLICE_X8Y20)", s08)):
        print(name)
        for f in FRAMES:
            print("  rel %d: n=%2d %s" % (f, len(s[f]), sorted(s[f])))
        print("  合计 %d 位" % sum(len(v) for v in s.values()))


def p2(s08, s20):
    print()
    print("=" * 78)
    print("2) 枚举 4 帧的全部双射 mu，判 S08[f] == S20[mu(f)]")
    print("=" * 78)
    print("  mu(c08 帧) -> c20 帧        missing  extra")
    hits = []
    for perm in itertools.permutations(FRAMES):
        mu = dict(zip(FRAMES, perm))
        mapped = {(mu[f], b) for f in FRAMES for b in s08[f]}
        actual = {(f, b) for f in FRAMES for b in s20[f]}
        miss, extra = len(actual - mapped), len(mapped - actual)
        flag = "  <== 完全相等" if miss == 0 and extra == 0 else ""
        print("  %-26s %4d %6d%s" % (str(mu), miss, extra, flag))
        if miss == 0 and extra == 0:
            hits.append(mu)
    print("  完全相等的双射个数：%d" % len(hits))
    return hits


def p3(s08, s20, hits):
    print()
    print("=" * 78)
    print("3) 两张 INIT 表：bit 是否逐位相同 / 帧映射 sigma")
    print("=" * 78)
    locked = json.load(open(os.path.join(ROOT, "v7re", "steps", "clb_init_locked_map.json"),
                            encoding="utf-8"))
    m = {int(k): tuple(v) for k, v in locked["orders"]["SLICEM"].items()}
    e = {int(k): tuple(v) for k, v in locked["orders"]["SLICEL"].items()}
    bit_diff = [k for k in range(64) if m[k][1] != e[k][1]]
    sig = collections.defaultdict(set)
    for k in range(64):
        sig[e[k][0]].add(m[k][0])
    print("  bit 不同的索引个数：%d %s" % (len(bit_diff), bit_diff))
    print("  SLICEL 帧 -> SLICEM 帧：%s" % {k: sorted(v) for k, v in sorted(sig.items())})
    sigma = {32 + k: 32 + sorted(v)[0] for k, v in sig.items()}
    print("  绝对相对帧形式 sigma：%s" % sigma)
    mapped = {(sigma[f], b) for f in FRAMES for b in s08[f]}
    actual = {(f, b) for f in FRAMES for b in s20[f]}
    print("  sigma(c08) vs c20：missing %d / extra %d / equal %s"
          % (len(actual - mapped), len(mapped - actual), mapped == actual))


def p4(s08, s20, sigma):
    print()
    print("=" * 78)
    print("4) 被否掉的两种候选映射与真映射 sigma 的重合帧 + 计数口径")
    print("=" * 78)
    cands = {"XOR2 (32<->34, 33<->35)": {32: 34, 33: 35, 34: 32, 35: 33},
             "mirror (67-rel: 32<->35, 33<->34)": {32: 35, 33: 34, 34: 33, 35: 32}}
    for name, mu in cands.items():
        mapped = {(mu[f], b) for f in FRAMES for b in s08[f]}
        actual = {(f, b) for f in FRAMES for b in s20[f]}
        same = [f for f in FRAMES if s08[f] == s20[mu[f]]]
        print("  %-36s missing %2d extra %2d   与 sigma 重合的帧: %s"
              % (name, len(actual - mapped), len(mapped - actual), same))

    # 解码 tile 计数
    fasm = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
    rows = []
    for line in open(fasm, encoding="utf-8"):
        parts = line.strip().split(":")[0].split(".")
        if len(parts) == 3:
            rows.append(tuple(parts))
    tiles = {r[0] for r in rows}
    split = collections.Counter(t.split("_X")[0] for t in tiles)
    print("\n  解码特征 %d 条 / tile %d 个 / %s" % (len(rows), len(tiles), dict(split)))
    print("  (tile, family) 重复：%d"
          % len([1 for k, v in collections.Counter((r[0], r[1]) for r in rows).items() if v > 1]))

    # law 库「格」的重复计数口径
    db = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
    if not os.path.exists(db):
        print("  law 库不存在，跳过：%s" % db)
        return
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    pair_cell, cell_src = collections.defaultdict(set), collections.defaultdict(set)
    for fam, src, off, par, bit, se in con.execute(
            "select family,src_wire,frame_off,parity,bit,sense from law_cells "
            "where tile_type='INT_L'"):
        if se == 1:
            pair_cell[(fam, src)].add((off, par, bit))
            cell_src[(fam, (off, par, bit))].add(src)
    triples = sum(len(v) for v in pair_cell.values())
    print("  INT_L sense=1：不同 (family,cell) %d 个；按 (family,src) 累加得 %d 个格 → 膨胀 %.2f 倍"
          % (len(cell_src), triples, triples / len(cell_src)))
    print("  每个格被多少条源共用：%s" % dict(sorted(collections.Counter(
        len(v) for v in cell_src.values()).items())))


def p5():
    """IMUX_L34 的跨列实例：同源跨列是否存在；family 级并集两列差多少。"""
    print()
    print("=" * 78)
    print("5) IMUX_L34 的跨列实例（同源 / family 级并集）")
    print("=" * 78)
    import re
    fasm = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
    per = collections.defaultdict(list)
    for line in open(fasm, encoding="utf-8"):
        parts = line.strip().split(":")[0].split(".")
        if len(parts) == 3 and parts[1] == "IMUX_L34":
            m = re.search(r"_X(\d+)Y(\d+)$", parts[0])
            per[parts[2]].append((parts[0], int(m.group(1)), int(m.group(2))))
    for src, v in sorted(per.items()):
        print("  %-16s %s  cols=%s" % (src, [x[0] for x in v], sorted({x[1] for x in v})))
    cross = {s: v for s, v in per.items() if len({x[1] for x in v}) > 1}
    print("  同源跨列的组合数：%d %s" % (len(cross), list(cross)))
    print("  IMUX_L34 共 %d tile / %d 源" % (sum(len(v) for v in per.values()), len(per)))

    db = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
    if not os.path.exists(db):
        print("  law 库不存在，跳过 family 级并集：%s" % db)
        return
    con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
    cells = collections.defaultdict(set)
    for fam, src, off, par, bit, se in con.execute(
            "select family,src_wire,frame_off,parity,bit,sense from law_cells "
            "where tile_type='INT_L' and family='IMUX_L34' and sense=1"):
        cells[src].add((off, par, bit))

    def union(ss):
        out = set()
        for s in ss:
            out |= cells[s]
        return out

    col32 = [s for s, v in per.items() if all(c == 32 for _, c, _ in v)]
    col8 = [s for s, v in per.items() if all(c == 8 for _, c, _ in v)]
    a, b = union(col32), union(col8)
    print("  family 级并集 col32（%s）n=%d %s" % (",".join(col32), len(a), sorted(a)))
    print("  family 级并集 col8 （%s）n=%d %s" % (",".join(col8), len(b), sorted(b)))
    print("  col8 vs col32：missing %d / extra %d" % (len(b - a), len(a - b)))


def p6():
    """解码文件的行的构成：PIP 行 vs 非 PIP 行（CLB INIT 行）——「191/77」两个数字的来源。"""
    print()
    print("=" * 78)
    print("6) 解码文件的行构成（191 条 / 77 tile 是从哪来的）")
    print("=" * 78)
    fasm = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
    body = [l.strip() for l in open(fasm, encoding="utf-8")
            if l.strip() and not l.strip().startswith("#")]
    pip = [l for l in body if "=" not in l]
    nonpip = [l for l in body if "=" in l]
    print("  非注释行 %d = PIP 行 %d + 非 PIP 行 %d" % (len(body), len(pip), len(nonpip)))
    for l in nonpip:
        print("  非 PIP 行：%s" % l)
    tiles = {l.split(":")[0].split(".")[0] for l in pip}
    all_tiles = {l.split(":")[0].split(".")[0] for l in body}
    print("  PIP 行 tile：%d %s" % (len(tiles), dict(collections.Counter(
        t.split("_X")[0] for t in tiles))))
    print("  全部行 tile：%d（多出的 %s）" % (len(all_tiles), sorted(all_tiles - tiles)))


def main():
    s20, s08 = payload_sets("c20", 31924), payload_sets("c08", 31680)
    p1(s08, s20)
    hits = p2(s08, s20)
    # 从枚举结果反推真实 sigma（若唯一）
    sigma = hits[0] if len(hits) == 1 else None
    p3(s08, s20, hits)
    if sigma is None:
        return 0
    p4(s08, s20, sigma)
    p5()
    p6()
    return 0


if __name__ == "__main__":
    sys.exit(main())
