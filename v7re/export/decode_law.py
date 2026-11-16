#!/usr/bin/env python3
"""decode_law.py —— 全器件 PIP 解码器（判据：族内精确匹配，2026-11-07）。

判定口径（默认：精确匹配）
  1. 取该 (tile_type, family) 全部 sense=1 的格，合成「位域」；
     跨 family 零共享（1,598/1,598 独占）保证位域内只有本族的位。
  2. 在实际位流里读出位域的 0/1 图案；
  3. 与每个候选源的 pattern 要求**完全相等**——恰等是充要条件，不存在子集歧义。
  4. tile 位域全 0 ⇒ 该族未使用，不输出。

  实测（full8）：精确率 100%（误判 0），召回 96%；
  旧判据会把子集源一起判中，full8 上误判 78~92 条。

GCLK 直通
  tile 的 (frame_off=0, parity=1, bit=16) 是「本 tile 有 GCLK 接入」的使能位，不编码线号；
  线号由同 tile 的 CLK_L* family 选中源（形如 GCLK_L_B11_WEST）给出，两者合成真实 PIP。

旧判据（仅用于对照）
  --legacy-allones：all-ones 判据，配合 --min-cells（默认 4）分 EXACT/WEAK。

用法：
  python v7re/export/decode_law.py design.bit --out pips.csv
  python v7re/export/decode_law.py design.bit --legacy-allones --min-cells 4 --out old.csv
"""
import argparse
import json
import os
import sqlite3
import sys
import time
import csv

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

BAND_ROWS = 50


def load_cells(db):
    con = sqlite3.connect(db)
    # law_cells 是主编码（variant 0）；同族同 src 若在不同列/区块上有
    # 另一套实测编码，放在 law_cells_var（variant>=1）。两者都参与判定：
    # 一个 src 只要命中任一 variant 的全部 sense=1 格、且不在其 sense=0 格上
    # 点火，即判为该 PIP 存在。见 STATUS §206。
    has_var = con.execute(
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name='law_cells_var'"
    ).fetchone()
    if has_var:
        rows = con.execute(
            "SELECT tile_type, family, src_wire, variant, frame_off, bit, "
            "sense, parity FROM law_cells_all "
            "ORDER BY tile_type, family, src_wire, variant, frame_off, bit"
        ).fetchall()
    else:
        rows = [r[:3] + (0,) + r[3:] for r in con.execute(
            "SELECT tile_type, family, src_wire, frame_off, bit, sense, parity "
            "FROM law_cells ORDER BY tile_type, family, src_index, frame_off, bit"
        ).fetchall()]
    bands = {}
    for band, col, s in con.execute("SELECT band,col,start_frame FROM far_bands"):
        bands.setdefault(band, {})[col] = s
    tiles = {}
    for name, ttype, col, y in con.execute(
            "SELECT tile_name,tile_type,col,y FROM law_tiles"):
        tiles[name] = (ttype, col, y)
    bbr = json.loads(con.execute(
        "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
    con.close()
    return rows, bands, tiles, bbr


def bit_matrix(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)            # (F, 101)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)          # 1 = bit set


def word_of(y, parity):
    w = 2 * (y % BAND_ROWS) + parity
    return np.where(w >= 50, w + 1, w)


def load_clb(db):
    """S4 集成：CLB site 特征 + 块基址 + slice 归属。

    模型：frame = clb_blocks[(gridCol, Y//50)] + frame_off
          word  = word_of(Y, parity)（与 INT 同一公式）
          inst  = slice 名 X 奇偶（偶→X0，奇→X1）。"""
    con = sqlite3.connect(db)
    cells = con.execute(
        "SELECT tile_type, family, src_wire, frame_off, bit, parity "
        "FROM clb_cells").fetchall()
    blocks = con.execute(
        "SELECT grid_col, band, base_frame FROM clb_blocks").fetchall()
    tiles = con.execute(
        "SELECT slice_name, tile_type, grid_col, inst, y FROM clb_tiles"
    ).fetchall()
    con.close()
    return cells, blocks, tiles


def decode_clb_matrix(M, clb, min_bit=1):
    """CLB 特征位读出：置 1 的 (slice, family.src) 列表。

    CLB 特征是单 bit 读出（INIT 值 / mux 选择码），不走 INT 的 all-ones EXACT 判据。
    向量化：按 (tileType, inst) 分组，每特征对全器件 slice 一次 fancy index。"""
    cells, blocks, tiles = clb
    blk = {(gc, b): base for gc, b, base in blocks}
    fam_cells = {}
    for tt, fam, src, foff, bit, parity in cells:
        # family 形如 'SLICEM_X0.ALUT'：实例号 = 分隔符 _X 之后的数字
        inst = int(fam.split("_X")[1].split(".")[0])
        fam_cells.setdefault((tt, inst), []).append(
            (fam.split(".")[1] + "." + src, foff, bit, parity))
    nframes = M.shape[0]

    # slice 表按 (tt, inst) 分组，预取块基址
    groups = {}
    for sname, tt, gc, inst, y in tiles:
        base = blk.get((gc, y // BAND_ROWS))
        if base is None:
            continue
        g = groups.setdefault((tt, inst), ([], [], []))
        g[0].append(sname)
        g[1].append(base)
        g[2].append(y)

    hits = []
    for key, (names_g, bases_g, ys_g) in groups.items():
        feats = fam_cells.get(key)
        if not feats:
            continue
        names_a = np.array(names_g)
        bases = np.array(bases_g, dtype=np.int64)
        ys = np.array(ys_g, dtype=np.int64)
        for feat, foff, bit, parity in feats:
            frames = bases + foff
            words = word_of(ys, parity)
            ok = (frames >= 0) & (frames < nframes)
            if not ok.all():
                keep = np.nonzero(ok)[0]
                if keep.size == 0:
                    continue
                frames, words = frames[keep], words[keep]
                names_f = names_a[keep]
            else:
                names_f = names_a
            vals = M[frames, words, bit] > 0
            for i in np.nonzero(vals)[0]:
                hits.append((str(names_f[i]), feat, f"{foff}_{bit}"))
    return hits


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bit")
    ap.add_argument("--db", default=r"E:\v7work\model\v7_law.sqlite")
    ap.add_argument("--out", default="pips.csv")
    ap.add_argument("--tiles", help="只解码这些 tile（pips json 里的 tile 字段）")
    ap.add_argument("--legacy-allones", action="store_true",
                    help="用旧的 all-ones 判据（会引入子集歧义，仅用于对照）")
    ap.add_argument("--min-cells", type=int, default=4,
                    help="EXACT 要求的 sense=1 格数下限（默认 4）")
    ap.add_argument("--require-zero", action="store_true",
                    help="额外要求 sense=0 格全为 0")
    ap.add_argument("--ref", help="参考位流：行级差分，只输出 design 有而 ref 没有的行")
    ap.add_argument("--no-clb", action="store_true", help="跳过 CLB site 解码")
    a = ap.parse_args()

    t0 = time.time()
    M = bit_matrix(a.bit)
    nframes = M.shape[0]
    print(f"bit matrix {M.shape} = {M.nbytes/1e6:.1f} MB  ({time.time()-t0:.1f}s)")

    cells, bands, tiles, band_by_region = load_cells(a.db)
    clb = None if a.no_clb else load_clb(a.db)
    if a.tiles:
        wanted = {rec["tile"] for rec in json.load(open(a.tiles))}
        tiles = {k: v for k, v in tiles.items() if k in wanted}
    names = sorted(tiles)
    print(f"tiles={len(names)} law_cells={len(cells)}")

    def run_all(M):
        """INT PIP 判定 + CLB site 读出 → [(tile, family, src, pattern, n)]"""
        tt_arr = np.array([tiles[n][0] for n in names])
        col_arr = np.array([tiles[n][1] for n in names], dtype=np.int64)
        y_arr = np.array([tiles[n][2] for n in names], dtype=np.int64)
        band_arr = np.array(band_by_region)[
            np.minimum(y_arr // BAND_ROWS, len(band_by_region) - 1)]

        base_cache = {}
        for tt in ("INT_L", "INT_R"):
            sel = tt_arr == tt
            if not sel.any():
                continue
            b = np.full(len(names), -1, dtype=np.int64)
            bc = bands
            for i in np.nonzero(sel)[0]:
                s = bc.get(int(band_arr[i]), {}).get(int(col_arr[i]), -1)
                b[i] = s
            base_cache[tt] = b

        groups = {}
        for (tt, fam, src, var, off, bit, sense, parity) in cells:
            groups.setdefault((tt, fam), {}).setdefault(src, {}).setdefault(
                var, []).append((off, bit, sense, parity))

        out_rows = []
        n_exact = n_weak = 0
        for (tt, fam), srcs in groups.items():
            base = base_cache.get(tt)
            if base is None:
                continue
            idx = np.nonzero((tt_arr == tt) & (base >= 0))[0]
            if idx.size == 0:
                continue
            base_t = base[idx]
            y_t = y_arr[idx]
            if a.legacy_allones:
                for src, varmap in srcs.items():
                    for cl in varmap.values():
                        arr = np.array(cl, dtype=np.int64)
                        off, bit, sense, parity = (arr[:, 0], arr[:, 1],
                                                   arr[:, 2], arr[:, 3])
                        m1 = sense > 0
                        if not m1.any():
                            continue
                        frames = base_t[:, None] + off[None, m1]
                        words = word_of(y_t[:, None], parity[None, m1])
                        f_safe = np.clip(frames, 0, M.shape[0] - 1)
                        vals = M[f_safe, words, bit[None, m1]] > 0
                        ok = (frames >= 0) & (frames < M.shape[0])
                        ones = (vals & ok).all(axis=1)
                        if a.require_zero:
                            m0 = ~m1
                            if m0.any():
                                f0 = np.clip(base_t[:, None] + off[None, m0],
                                             0, M.shape[0] - 1)
                                v0 = M[f0,
                                       word_of(y_t[:, None], parity[None, m0]),
                                       bit[None, m0]] > 0
                                ones &= (~v0).all(axis=1)
                        n1 = int(m1.sum())
                        tag = "EXACT" if n1 >= a.min_cells else "WEAK"
                        sel = np.nonzero(ones)[0]
                        for t in sel:
                            out_rows.append((names[idx[t]], fam, src, tag, n1))
                        if tag == "EXACT":
                            n_exact += sel.size
                        else:
                            n_weak += sel.size
                continue
            domain = sorted({(int(o), int(b), int(p))
                             for varmap in srcs.values()
                             for cl in varmap.values()
                             for (o, b, s, p) in cl if s > 0})
            if not domain:
                continue
            d_off = np.array([d[0] for d in domain], dtype=np.int64)
            d_bit = np.array([d[1] for d in domain], dtype=np.int64)
            d_par = np.array([d[2] for d in domain], dtype=np.int64)
            frames_d = base_t[:, None] + d_off[None, :]
            f_safe_d = np.clip(frames_d, 0, M.shape[0] - 1)
            obs = (M[f_safe_d, word_of(y_t[:, None], d_par[None, :]),
                     d_bit[None, :]] > 0) & \
                  (frames_d >= 0) & (frames_d < M.shape[0])
            pos = {d: i for i, d in enumerate(domain)}
            for src, varmap in srcs.items():
                # 每个 variant 一种模式；src 命中任一 variant 即判存在
                hit = np.zeros(len(idx), dtype=bool)
                n1_best = 0
                for cl in varmap.values():
                    pat = np.zeros(len(domain), dtype=bool)
                    n1 = 0
                    for (o, b, s, pp) in cl:
                        if s > 0:
                            pat[pos[(int(o), int(b), int(pp))]] = True
                            n1 += 1
                    if n1 == 0:
                        continue
                    match = (obs == pat[None, :]).all(axis=1)
                    hit |= match
                    n1_best = max(n1_best, n1)
                if n1_best == 0:
                    continue
                for t in np.nonzero(hit)[0]:
                    out_rows.append((names[idx[t]], fam, src, "EXACT", n1_best))
                    n_exact += 1

        # GCLK 直通还原：tile 的 (frame_off=0, parity=1, bit=16) 是「本 tile 有 GCLK 接入」
        # 的使能位（不编码线号）；线号由同 tile 的 CLK_L* family 选中源给出。两者合成真实 PIP。
        name_pos = {n: i for i, n in enumerate(names)}
        clk_src = {}
        for r in out_rows:
            if r[1].startswith("CLK_L") and r[2].startswith("GCLK_L_B"):
                clk_src.setdefault(r[0], set()).add(r[2])
        have = {(r[0], r[1], r[2]) for r in out_rows}
        for tile_name, srcs in clk_src.items():
            i = name_pos[tile_name]
            if not M[base_cache["INT_L"][i] if tt_arr[i] == "INT_L"
                     else base_cache["INT_R"][i],
                      word_of(y_arr[i], 1), 16]:
                continue
            for s in srcs:
                line = s.rsplit("_", 1)[0]          # GCLK_L_B11_WEST -> GCLK_L_B11
                if (tile_name, s, line) in have:
                    continue
                out_rows.append((tile_name, s, line, "EXACT", 1))
                n_exact += 1

        n_clb = 0
        if clb is not None:
            for sname, feat, bitdesc in decode_clb_matrix(M, clb):
                # bitdesc = "foff_bit"：CLB 特征的位位置必须进 row，
                # 否则 --ref 差分会把同 (slice,feat) 的不同 bit 行折叠抵消
                out_rows.append((sname, feat, bitdesc, "CLB_SET", 1))
                n_clb += 1
        return out_rows, n_exact, n_weak, n_clb

    out_rows, n_exact, n_weak, n_clb = run_all(M)
    if a.ref:
        R = bit_matrix(a.ref)
        ref_rows, _, _, _ = run_all(R)
        ref_set = set(map(tuple, ref_rows))
        out_rows = [r for r in out_rows if tuple(r) not in ref_set]
        n_exact = sum(1 for r in out_rows if r[3] == "EXACT")
        n_weak = sum(1 for r in out_rows if r[3] == "WEAK")
        n_clb = sum(1 for r in out_rows if r[3] == "CLB_SET")

    with open(a.out, "w", newline="") as fh:
        w = csv.writer(fh)
        w.writerow(["tile", "family", "src", "pattern", "cells1"])
        w.writerows(out_rows)

    print(f"EXACT={n_exact} WEAK={n_weak} CLB_SET={n_clb} "
          f"({time.time()-t0:.1f}s) -> {a.out}")


if __name__ == "__main__":
    main()
