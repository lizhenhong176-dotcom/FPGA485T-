#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""make_fig_data.py —— 从库与既有 json 生成论文图表的 CSV 数据。

用法:
    python make_fig_data.py            # 写入 figs/*.csv
    python make_fig_data.py --check    # 只打印摘要，不写文件

产物（figs/）:
    fig1_frame_blocks.csv   器件帧布局：每个 (band, far_col) 区块的帧区间与类别
    fig2_fanin_families.csv 636 个 family 的 fan-in / cell 数（全 tile 类型）
    fig2_fanin_hist.csv     按 tile_type 的 fan-in 直方图
    fig3_coverage.csv       三档覆盖率
    fig4_family_shape.csv   族形状（mux 6x4 / BEG K(a,b) / 长线乘积网格）
    fig5_clb_bits.csv       CLB 位级规格（已知位 + 未定位位）
    fig6_cells_per_feature.csv 复用度量：每个 feature 占几格
数据源与口径见 SINGLE_SOURCE_OF_TRUTH.md。
"""
from __future__ import annotations

import argparse
import csv
import json
import os
import sqlite3

MODEL = r"E:\v7work\model\v7_model.sqlite"
LAW = r"E:\v7work\model\v7_law.sqlite"
OUT = "figs"

# 长线族形状（来自 step03_pip/_q_longline_pairs.py 的实测结果；见 STATUS §178）
LONGLINE = {
    "LH0":     dict(src=12, cells=9, a=5, b=4, edges=12, complete=False),
    "LH12":    dict(src=12, cells=7, a=4, b=3, edges=12, complete=True),
    "LVB_L0":  dict(src=18, cells=9, a=6, b=3, edges=18, complete=True),
    "LVB_L12": dict(src=18, cells=9, a=3, b=6, edges=18, complete=True),
    "LV_L0":   dict(src=10, cells=7, a=4, b=3, edges=10, complete=False),
    "LV_L18":  dict(src=12, cells=9, a=4, b=5, edges=12, complete=False),
}

# CLB 已知位（frame_off, word, bit）→ 语义。来源 v7re/docs/CLB_BIT_SPEC.md
CLB_KNOWN = {
    (0, 41, 16): ("FFSYNC", "confirmed"),
    (1, 41, 19): ("CLKINV", "confirmed"),
    (30, 41, 0): ("LATCH", "confirmed"),
    (30, 40, 0): ("AFFMUX(O5/O6)", "confirmed"),
    (0, 40, 12): ("PRECYINIT(1)", "confirmed"),
    (1, 41, 7): ("CEUSEDMUX", "strong-candidate"),
    (1, 41, 2): ("SR_used_b2", "confirmed"),
    (1, 41, 3): ("SR_used_b3", "confirmed"),
    (1, 41, 9): ("SR_used_b9", "confirmed"),
    (23, 41, 0): ("CE_target_b23", "candidate"),
    (24, 41, 0): ("CE_target_b24", "candidate"),
    (25, 41, 0): ("CE_target_b25", "candidate"),
}
AOUTMUX = {
    "O5": [(3, 40, 8), (4, 40, 10), (6, 41, 4), (7, 41, 5)],
    "O6": [(3, 40, 4), (4, 41, 10), (6, 41, 8), (7, 40, 5)],
}


def frame_class(n: int) -> str:
    return {36: "CLB", 28: "INT", 30: "CLOCK", 32: "BOUNDARY", 42: "UNDETERMINED"}.get(n, "?")


def fig1():
    """全器件区块表：1,183 块 / 50,148 帧（帧 0..50,175 扣掉 28 个 overhead）。

    数据来自 `frame_blocks_full`（由 v7re/scripts/build_frame_blocks_full.py 生成），
    它同时给出 FAR block_type/top_bottom/row/col 与 far_bands 的 band 对应关系。
    """
    l = sqlite3.connect(LAW)
    rows = l.execute(
        "select block_type, top_bottom, row_addr, col_addr, far_band, clb_col,"
        " start_frame, end_frame, n_frames, class"
        " from frame_blocks_full order by start_frame"
    ).fetchall()
    with open(os.path.join(OUT, "fig1_frame_blocks.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "block_type", "top_bottom", "row_addr", "far_col", "far_band", "clb_col",
            "start_frame", "end_frame", "n_frames", "class",
        ])
        for bt, tb, row, col, band, gc, s, e, n, cls in rows:
            w.writerow([bt, tb, row, col, "" if band is None else band,
                        "" if gc is None else gc, s, e, n, cls])
    return len(rows)


def fig2():
    d = json.load(open("v7re/steps/tile_pip_lawscan.json", encoding="utf-8"))
    fams = d["families"]
    with open(os.path.join(OUT, "fig2_fanin_families.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["tile_type", "family", "sources", "cells"])
        for r in fams:
            w.writerow([r["tile_type"], r["family"], r["sources"], r["cells"]])
    hist: dict[tuple[str, int], int] = {}
    for r in fams:
        key = (r["tile_type"], r["sources"])
        hist[key] = hist.get(key, 0) + 1
    with open(os.path.join(OUT, "fig2_fanin_hist.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["tile_type", "sources", "n_families"])
        for (tt, s), n in sorted(hist.items(), key=lambda kv: (kv[0][0], kv[0][1])):
            w.writerow([tt, s, n])
    return len(fams)


def fig3():
    rows = [
        ("family", 172, 172, "两侧各 172 族，verify_all_pip.py"),
        ("feature", 3634, 3634, "verify_all_pip.py 精确命中 0 不符"),
        ("feature(可由槽位表生成)", 3552, 3634, "gen_slots.py；差集 82 = 6 长线族"),
        ("(feature,cell) 记录", 8900, 8900, "law_cells sense=1"),
        ("不同 cell", 1598, 1598, "law_cells sense=1 去重"),
        ("INT tile 实例(实测)", 12565, 53100, "all_int_tiles_check.py；23.66%"),
        ("全器件可配置 PIP 实例", 198434700, 207253149, "INT 占比 95.7%"),
    ]
    with open(os.path.join(OUT, "fig3_coverage.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["metric", "covered", "total", "pct", "note"])
        for name, cov, tot, note in rows:
            w.writerow([name, cov, tot, round(100.0 * cov / tot, 2), note])
    return len(rows)


def fig4():
    out = []
    # mux：64 族，每族 6x4 满填
    l = sqlite3.connect(LAW)
    n_mux = l.execute(
        "select count(distinct family) from law_cells where tile_type='INT_L' and sense=1 and frame_off between 16 and 21"
    ).fetchone()[0]
    for _ in range(n_mux):
        out.append(["INT_L", "mux", 24, 6, 4, 1536 // max(n_mux, 1), True])
    # BEG
    beg = json.load(open("v7re/steps/beg_families.json", encoding="utf-8"))["families"]
    for name, v in beg.items():
        if "A" not in v or "B" not in v:
            # 时钟/控制/复合族：没有二分形状，记 kind 与源数
            out.append(["INT_L", f"{v.get('kind', 'other')}:{name}", len(v["sources"]), "", "", "", ""])
            continue
        A, B = len(v["A"]), len(v["B"])
        out.append(["INT_L", "BEG", len(v["sources"]), A, B, A * B, bool(v["complete"])])
    # 长线
    for name, v in LONGLINE.items():
        out.append(["INT_L", "longline:" + name, v["src"], v["a"], v["b"], v["edges"], v["complete"]])
    with open(os.path.join(OUT, "fig4_family_shape.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["tile_type", "kind", "sources", "axis_A", "axis_B", "edges", "complete_product"])
        w.writerows(out)
    return len(out)


def fig5():
    l = sqlite3.connect(LAW)
    aout = {}
    for k, cells in AOUTMUX.items():
        for c in cells:
            aout[c] = f"AOUTMUX({k})"
    rows = []
    for tt, fam, src, fo, bit, sense, par in l.execute(
        "select tile_type,family,src_wire,frame_off,bit,sense,parity from clb_cells "
        "where sense=1 order by frame_off,parity,bit"
    ):
        key = (fo, par, bit)
        if key in CLB_KNOWN:
            meaning, conf = CLB_KNOWN[key]
        elif key in aout:
            meaning, conf = aout[key], "confirmed"
        elif fo in (34, 35, 36, 37) and par in (0, 1):
            meaning, conf = f"{fam}:{src}", "confirmed(INIT)"
        else:
            meaning, conf = f"{fam}:{src}", "unknown"
        rows.append([tt, fo, par, bit, fam, src, meaning, conf, "db:clb_cells"])
    # T82–T87 的受控差分实测位：clb_cells 未收录，单列 clb_manual_bits.json
    man = os.path.join(os.path.dirname(os.path.abspath(__file__)), "v7re", "steps", "clb_manual_bits.json")
    if os.path.exists(man):
        seen = {(r[1], r[2], r[3]) for r in rows}
        with open(man, encoding="utf-8") as f:
            for r in json.load(f)["rows"]:
                key = (r["frame_off"], r["parity"], r["bit"])
                if key in seen:
                    continue
                seen.add(key)
                rows.append(
                    ["CLBLM_L", r["frame_off"], r["parity"], r["bit"], r["family"],
                     r["src_wire"], r["meaning"], r["confidence"], "manual:T82-T87"]
                )
    with open(os.path.join(OUT, "fig5_clb_bits.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["tile_type", "frame_off", "parity", "bit", "family", "src_wire",
                    "meaning", "confidence", "provenance"])
        w.writerows(rows)
    return len(rows)


def fig6():
    l = sqlite3.connect(LAW)
    rows = l.execute(
        "select n, count(*) from (select family, count(*) n from law_cells "
        "where tile_type='INT_L' and sense=1 group by family) group by n order by n"
    ).fetchall()
    with open(os.path.join(OUT, "fig6_cells_per_feature.csv"), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["cells_per_family", "n_families"])
        for n, c in rows:
            w.writerow([n, c])
    return len(rows)


def main() -> int:
    global OUT
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="dry-run：写到临时目录，不碰 figs/")
    args = ap.parse_args()
    if args.check:
        import tempfile

        OUT = tempfile.mkdtemp(prefix="figdry_")
    else:
        os.makedirs(OUT, exist_ok=True)
    counts = {
        "fig1_frame_blocks": fig1(),
        "fig2_fanin_families": fig2(),
        "fig3_coverage": fig3(),
        "fig4_family_shape": fig4(),
        "fig5_clb_bits": fig5(),
        "fig6_cells_per_feature": fig6(),
    }
    for k, v in counts.items():
        print(f"{k:26s} {v:>8,d} rows")
    print("written to" if not args.check else "dry-run", OUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
