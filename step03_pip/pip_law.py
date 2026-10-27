#!/usr/bin/env python3
"""
pip_law.py —— PIP 复用规律的可执行形式（步骤 1）

给定 (tile 名, mux, 源 wire)，直接给出该 PPIP 在比特流里的绝对坐标
(frame, word, bit) 及其极性 (sense)。

公式
====
    frame = block_start(col, region) + 16 + df
    word  = 2*(Y % 50) + parity        # 结果 >= 50 时再 +1（让开 ECC 字）
    bit   = 形状表里的 bit       (0..31，32 位字内位置)
    value = sense               (1=置位，0=清位)

其中
  * `col`   = tile 名里的 X（如 INT_L_X6Y11 → 6）
  * `region` = Y // 50（0..6，每个 clock region 50 行 CLB）
  * `block_start(col, region)` = ROW_FRAMES * BAND_BY_REGION[region] + prefix(col)
    - ROW_FRAMES = 5246 = 每个 CLB 行带的帧数（7 个带：5246*7 = 36,722）
    - BAND_BY_REGION = [6,5,0,1,2,3,4]：region → FAR 行带（**不是**简单反向，
      2026-10-26 七区实测得出，见 PIP_LAW.md §7）
    - prefix(col) = 该带内前 col 个 block 的帧宽之和（154 列，从
      phaseA/frame_index_far.csv 读出，见 load_prefix()）
  * `df`  = 形状表里的帧内偏移（IMUX 0..9；其它家族见 all_cells.json 的 frame_off）
  * `parity` = 行内字奇偶（IMUX 为 (L//4)%2；一般家族为 segbits bit//32）
  * `L`   = mux 编号（IMUX_L8 → 8，IMUX8 → 8）
  * 形状表 (`df`/`frame_off`, `bit`, `sense`, `parity`) 来自 prjxray artix7 segbits，
    见 imux_cells.json（IMUX）与 all_cells.json（全部 172 家族 × 两侧）

形状表是 **tile 类型级常量**：同一 (tile_type, mux, src) 在任何列、任何行带上
的 (df, bit, sense) 完全相同；列/行只改变 block_start 与 word。
"""
import argparse
import collections
import csv
import itertools
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(HERE, "imux_cells.json")
FAR_CSV = os.path.join(os.path.dirname(HERE), "phaseA", "frame_index_far.csv")

ROW_FRAMES = 5246          # 每个 CLB 行带的帧数
BAND_ROWS = 50             # 每带 50 行
SHAPE_ORIGIN = 16          # 形状窗口在 block 内的起点（实测常量）
N_BANDS = 7

_TILE_RE = re.compile(r"_X(\d+)Y(\d+)$")
_MUX_RE = re.compile(r"^IMUX(?:_[LR])?(\d+)$")


# ---------------------------------------------------------------- 器件常量
def load_prefix(csv_path=FAR_CSV):
    """从 FAR 表读出每带的 block 起始帧与宽度，返回 {band: [start,...]}。"""
    by_band = collections.defaultdict(dict)   # band -> col -> [start,end]
    with open(csv_path, newline="") as fh:
        for r in csv.DictReader(fh):
            row = int(r["row"])
            band = row - 1
            if band < 0 or band >= N_BANDS:
                continue
            col = (int(r["block_addr"], 16) >> 7) & 0x7F
            fi = int(r["frame_index"])
            e = by_band[band].setdefault(col, [fi, fi])
            e[0] = min(e[0], fi)
            e[1] = max(e[1], fi)
    starts = {}
    for band, cols in by_band.items():
        s = {}
        for col in sorted(cols):
            s[col] = cols[col][0]
        starts[band] = s
    return starts


def load_cells(path=CELLS):
    table = collections.defaultdict(list)
    with open(path) as fh:
        for c in json.load(fh):
            table[(c["tile_type"], c["mux"], c["src_wire"])].append(
                (c["df"], c["bit"], c["sense"]))
    for v in table.values():
        v.sort()
    return table


_STARTS = load_prefix()
_CELLS = load_cells()
_ALL_PATH = os.path.join(HERE, "all_cells.json")


def load_all(path=_ALL_PATH):
    """全量形状表（228 个家族，含 IMUX 之外的 BYP_ALT/FAN_ALT/BEG/CLK…）。"""
    table = collections.defaultdict(list)
    if not os.path.exists(path):
        return table
    with open(path) as fh:
        for c in json.load(fh):
            table[(c["tile_type"], c["family"], c["src_wire"])].append(
                (c["frame_off"], c["bit"], c["sense"], c["parity"]))
    for v in table.values():
        v.sort()
    return table


_ALL = load_all()


# ---------------------------------------------------------------- 主公式
def parse_tile(name):
    m = _TILE_RE.search(name)
    if not m:
        raise ValueError(f"无法解析 tile 名: {name!r}")
    ttype = name[:m.start()]
    return ttype, int(m.group(1)), int(m.group(2))


def mux_index(mux):
    m = _MUX_RE.match(mux)
    if not m:
        raise ValueError(f"无法解析 mux 名: {mux!r}")
    return int(m.group(1))


# 时钟区域行 (Y//50) → FAR 表里的 CLB 行带编号。实测得到（见 PIP_LAW.md §7）：
#   Y=25→6, 75→5, 125→0, 175→1, 225→2, 275→3, 325→4
# 前两个区域在表尾且顺序相反，因为位流的行遍历在两半区交界处折返。
BAND_BY_REGION = [6, 5, 0, 1, 2, 3, 4]


def _word(y, parity):
    """帧内字号：2*(Y%50)+parity，跨过 ECC 字（第 50 字）时整体后移 1。"""
    w = 2 * (y % BAND_ROWS) + parity
    return w + 1 if w >= 50 else w


def block_start(col, y):
    band = BAND_BY_REGION[y // BAND_ROWS]
    starts = _STARTS[band]
    if col not in starts:
        raise KeyError(f"列 {col} 不在 band {band} 的 FAR 表里")
    return starts[col]


def predict(tile, mux, wire):
    """返回 [(frame, word, bit, sense), ...]；未知 wire 返回 []。"""
    ttype, col, y = parse_tile(tile)
    cells = _CELLS.get((ttype, mux, wire))
    if not cells:
        return []
    base = block_start(col, y)
    word = _word(y, (mux_index(mux) // 4) % 2)
    return [(base + SHAPE_ORIGIN + df, word, bit, sense)
            for df, bit, sense in cells]


def predict_set(tile, mux, wire):
    return {(f, w, b) for f, w, b, _ in predict(tile, mux, wire)}


def predict_family(tile, family, wire, parity=None):
    """0..25 全家族版本：frame = block_start + frame_off（segbits 的 word 值）。

    `parity` 默认取形状表里的 parity（= 原始 bit // 32）；IMUX 已实测证实该规则，
    其它家族沿用同一打包假设，可用 --parity 覆盖做实验对照。
    """
    ttype, col, y = parse_tile(tile)
    cells = _ALL.get((ttype, family, wire))
    if not cells:
        return []
    base = block_start(col, y)
    if parity is None:
        parity = cells[0][3]
    word = _word(y, parity)
    return [(base + off, word, bit, sense) for off, bit, sense, _p in cells]


# ---------------------------------------------------------------- 自检
def _check_one(path, tile, label):
    if not os.path.exists(path):
        print(f"  [skip] 没有 {os.path.basename(path)}")
        return True
    obs = json.load(open(path))
    families = sorted({rec["family"] for rec in json.load(open(_ALL_PATH))},
                      key=len, reverse=True)
    ok = bad = 0
    for name, cells in obs.items():
        stem = name[len("v_"):]
        family = next(f for f in families if stem.startswith(f + "_"))
        src = stem[len(family) + 1:]
        ones = {(f, w, b) for f, w, b in cells if w != 50}
        rows = predict_family(tile, family, src)
        exp = {(f, w, b) for f, w, b, s in rows if s == 1}
        if ones and ones <= exp:
            ok += 1
        else:
            bad += 1
            print(f"  [bad] {name}: 观测 {sorted(ones)[:2]} 不在预测 {sorted(exp)[:2]}")
    print(f"  非 IMUX 家族 {label}（{os.path.basename(path)} 回归）: {ok}/{ok + bad}")
    return bad == 0


def _check_families():
    good = True
    good = _check_one(os.path.join(HERE, "famdiff.json"), "INT_L_X6Y11", "INT_L") and good
    good = _check_one(os.path.join(HERE, "famdiff_r.json"), "INT_R_X7Y10", "INT_R") and good
    return good


def _selftest():
    cases = [
        # (文件, tile, 列, 行, tag→mux 提取方式)
        ("tilepipe.json", "INT_L_X6Y11", 6, 11),
        ("tp3.json",      "INT_L_X6Y21", 6, 21),
        ("tp2.json",      "INT_R_X9Y11", 9, 11),
    ]
    ok = fail = 0
    for fname, tile, col, y in cases:
        path = os.path.join(HERE, fname)
        if not os.path.exists(path):
            print(f"  [skip] {fname} 不存在")
            continue
        with open(path, encoding="utf-8-sig") as fh:
            data = json.load(fh)
        for tag, t in data.items():
            mux = t["sink"]
            for src, obs0 in t["sources"].items():
                pred = predict_set(tile, mux, src)
                obs = {tuple(x[:3]) for x in obs0}
                ok += len(pred & obs)
                fail += len(obs - pred)
        print(f"  [ok]   {fname:<14} {tile:<12} 命中 {ok}/{ok+fail}")
    print(f"  形状表命中率: {ok}/{ok+fail} = {ok/(ok+fail):.4f}" if ok + fail else "  无样本")

    # 列/行扫描：同一形状在不同列、不同行带上完全一致（只需换 block_start）
    scans = [("rep_C6R.json", 6, 11), ("rep_C8R.json", 8, 11), ("col_9.json", 9, 11),
             ("col_11.json", 11, 11), ("col_12.json", 12, 11), ("col_13.json", 13, 11),
             ("col_B1.json", 6, 61)]
    print("  列/行不变性（同 mux 同源，逐格比对）:")
    allscan = True
    for fname, col, y in scans:
        path = os.path.join(HERE, fname)
        if not os.path.exists(path):
            continue
        with open(path, encoding="utf-8-sig") as fh:
            d = json.load(fh)
        ttype = "INT_L" if col % 2 == 0 else "INT_R"
        mux = "IMUX_L8" if ttype == "INT_L" else "IMUX8"
        obs = {tuple(x[:3]) for v in d.values() for x in v}
        best = None
        for cand_col in range(0, 40):
            b = block_start(cand_col, y)
            pred = set()
            for src in d:
                for df, bit, _s in _CELLS.get((ttype, mux, src), []):
                    pred.add((b + SHAPE_ORIGIN + df, 2 * (y % BAND_ROWS), bit))
            hit = len(obs & pred)
            if best is None or hit > best[0]:
                best = (hit, cand_col)
        ok = best[0] == len(obs)
        allscan = allscan and ok
        print(f"    {fname:<14} Y={y:<3d} 唯一格 {best[0]}/{len(obs)}"
              f"  → 第 {best[1]} 列 {'OK' if ok else 'MISMATCH'}")
    return fail == 0 and allscan


def main(argv):
    ap = argparse.ArgumentParser(description="PIP 复用规律：PIP → (frame, word, bit)")
    ap.add_argument("--tile", help="tile 名，如 INT_L_X6Y11")
    ap.add_argument("--mux", help="mux 名，如 IMUX_L8")
    ap.add_argument("--src", help="源 wire，如 GFAN0")
    ap.add_argument("--check", action="store_true", help="跑自检")
    ap.add_argument("--json", action="store_true", help="以 JSON 输出")
    ap.add_argument("--family", help="非 IMUX 家族（如 BYP_ALT0），配合 --parity 使用")
    ap.add_argument("--parity", type=int, default=None, help="行内字奇偶（默认取形状表）")
    a = ap.parse_args(argv)

    if a.family:
        if not (a.tile and a.src):
            print("--family 需要 --tile 与 --src")
            return 2
        rows = predict_family(a.tile, a.family, a.src, a.parity)
        if not rows:
            print(f"没有形状记录: {a.tile} / {a.family} / {a.src}")
            return 2
        print(f"{a.tile} {a.family} <- {a.src}: {len(rows)} 个配置位（parity={a.parity}）")
        for f, w, b, s in rows:
            print(f"  frame {f:6d}  word {w:2d}  bit {b:2d}  -> {'1' if s else '0'}")
        return 0

    if a.check or not (a.tile and a.mux):
        print("自检:")
        good = _selftest()
        good = _check_families() and good
        return 0 if good else 1

    rows = predict(a.tile, a.mux, a.src)
    if not rows:
        print(f"没有形状记录: {a.tile} / {a.mux} / {a.src}")
        return 2
    if a.json:
        print(json.dumps([{"frame": f, "word": w, "bit": b, "sense": s}
                          for f, w, b, s in rows], indent=1))
    else:
        print(f"{a.tile} {a.mux} <- {a.src}: {len(rows)} 个配置位")
        for f, w, b, s in rows:
            print(f"  frame {f:6d}  word {w:2d}  bit {b:2d}  -> {'1' if s else '0'}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
