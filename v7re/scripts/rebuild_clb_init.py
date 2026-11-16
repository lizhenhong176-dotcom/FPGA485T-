#!/usr/bin/env python3
"""rebuild_clb_init.py —— 用 LOCK_PINS 实测表重建 site_frames 的 CLB INIT 行。

背景：旧表来自 prjxray（artix7）形状表，且未锁引脚，索引空间与真实设计不一致
（T18/T19 结论）。本脚本用 T19/T21 实测表替换 `site_frames` 里所有 INIT 行。

输入表格式（JSON）：
    {"A6LUT": {"0": [abs_frame, word, bit], ... "63": [...]}, "B6LUT": {...}, ...}
其中 abs_frame 是参考 slice（SLICE_X12Y20 / SLICE_X13Y20，块基址 31716）的绝对帧号，
word 是 40（A/B、parity 0）或 41（C/D、parity 1）。

用法：
    python rebuild_clb_init.py --check                # 只统计，不写库
    python rebuild_clb_init.py --apply                # 事务内替换 INIT 行
    python rebuild_clb_init.py --apply --x1 x1.json   # 同时写入 X1 slice 表
"""
import argparse
import json
import os
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
MODEL_DB = os.environ.get("V7RE_MODEL_DB", r"E:\v7work\model\v7_model.sqlite")
REF_BASE = 31752           # SLICE_X12Y20 所在 CLB 块基址（col=20, band=0）
DEVICE = "xc7vx485t"
BAND_ROWS = 50


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return w + 1 if w >= 50 else w


def load_table(path):
    """→ {bel: {k: (frame_off, parity, bit)}}"""
    raw = json.load(open(path, encoding="utf-8"))
    out = {}
    for bel, m in raw.items():
        entry = {}
        for k, (fr, wd, bit) in m.items():
            entry[int(k)] = (int(fr) - REF_BASE, int(wd) - 40, int(bit))
        if len(entry) != 64:
            raise SystemExit("%s 的 %s 只有 %d 位" % (path, bel, len(entry)))
        out[bel] = entry
    return out


def slices(law_db):
    con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    blocks = {(c, b): f for c, b, f in
              con.execute("SELECT grid_col, band, base_frame FROM clb_blocks")}
    rows = con.execute("SELECT slice_name, grid_col, inst, y FROM clb_tiles").fetchall()
    con.close()
    out = []
    for name, col, inst, y in rows:
        base = blocks.get((col, y // BAND_ROWS))
        if base is None:
            continue
        out.append((name, int(inst), int(base), int(y)))
    return out


BEL_RENAME = {"A6LUT": "ALUT", "B6LUT": "BLUT", "C6LUT": "CLUT", "D6LUT": "DLUT"}


def emit_rows(table, slice_rows):
    rows = []
    for name, inst, base, y in slice_rows:
        for bel, entry in table.items():
            bel = BEL_RENAME.get(bel, bel)
            for k, (fo, parity, bit) in entry.items():
                rows.append((DEVICE, name, bel, "INIT[%02d]" % k,
                             base + fo, word_of(y, parity), bit, "t19_locked_init"))
    return rows


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--x0", default=os.path.join(ROOT, "steps", "clb_init_locked_x12y20_4lut.json"))
    ap.add_argument("--x1", default=None, help="X1 slice 表（SLICE_X13Y20 实测）")
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--model-db", default=MODEL_DB)
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--ref-base", type=int, default=None, help="参考 slice 的 CLB 块基址")
    a = ap.parse_args()

    global REF_BASE
    if a.ref_base:
        REF_BASE = a.ref_base
    t0 = load_table(a.x0)
    t1 = load_table(a.x1) if a.x1 else None
    sl = slices(a.law_db)
    n0 = sum(1 for s in sl if s[1] == 0)
    n1 = sum(1 for s in sl if s[1] == 1)
    print("slice 总数 %d（X0 %d / X1 %d）" % (len(sl), n0, n1))
    print("X0 表 %d BEL，X1 表 %s" % (len(t0), len(t1) if t1 else "无"))

    rows = emit_rows(t0, [s for s in sl if s[1] == 0])
    if t1:
        rows += emit_rows(t1, [s for s in sl if s[1] == 1])
    print("待写入 INIT 行：%d" % len(rows))
    if a.check and not a.apply:
        return

    con = sqlite3.connect(a.model_db)
    con.isolation_level = None
    try:
        con.execute("BEGIN")
        scope = "AND CAST(substr(site,7,instr(site,'Y')-7) AS INTEGER) %% 2 = %d" % (
            0 if t1 else 0)
        old = con.execute(
            "SELECT COUNT(*) FROM site_frames WHERE feature LIKE 'INIT[%]' " + scope).fetchone()[0]
        print("旧 INIT 行（本次范围）：%d" % old)
        con.execute("DELETE FROM site_frames WHERE feature LIKE 'INIT[%]' " + scope)
        con.executemany(
            "INSERT OR REPLACE INTO site_frames(device,site,bel,feature,frame,word,bit,source) "
            "VALUES (?,?,?,?,?,?,?,?)", rows)
        new = con.execute("SELECT COUNT(*) FROM site_frames WHERE feature LIKE 'INIT[%]'").fetchone()[0]
        print("新 INIT 行：%d" % new)
        con.execute("COMMIT")
    except Exception as exc:
        con.execute("ROLLBACK")
        raise SystemExit("已回滚：%s" % exc)
    finally:
        con.close()


if __name__ == "__main__":
    main()
