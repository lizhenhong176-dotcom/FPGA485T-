#!/usr/bin/env python3
"""decode_clb.py —— S4：CLB site 特征位解码器（LUT INIT 首批验证）。

模型（全部受控实验定论，见 step03_pip/S2_S3_SITE_LAYOUT.md 与 S4_CLB_DECODE.md）：
  frame = base(gridCol, band(Y)) + window(tileType, siteIdx) + frame_off(feature)
  word  = 2*(Y%50) + (Y%50 >= 25)
  bit   = feature 表值（artix7 segbits 直接迁移，V7 实测一致）

window：
  site index 0：CLBLL → 0（表内偏移 32..35 已含）；CLBM → +2
  site index 1：+0（表内 26..29）
（site_cells.json 的 frame_off 已按 artix7 原表；CLBM inst0 需要 +2。）

用法：
  python decode_clb.py design.bit [--ref ref.bit] [--json out.json]
  不给 --ref 时输出所有“置 1”的 site 特征；给 --ref 时输出差分置位。
"""
import argparse
import csv
import json
import os
import re
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "v7re"))
from bitstream.parser import frames_from_bit  # noqa: E402

PHASEA = os.path.join(HERE, "..", "phaseA")

BAND_ROWS = 50


def load_site_cells():
    """site_cells.json → {(tileType, siteIdx): [(family.src, frame_off, bit, parity)]}

    行结构（gen_site_cells.py）：{tile_type, family: 'SLICEL_X0.A5FF', src_wire,
    frame_off, parity, bit, sense}。family 的 X0/X1 即 site 实例号。
    parity 进 word 公式（CLUT/DLUT 等 = 1）。"""
    path = os.path.join(HERE, "site_cells.json")
    raw = json.load(open(path, encoding="utf-8"))
    out = {}
    for row in raw:
        fam = row["family"]                      # 'SLICEL_X0.A5FF'
        inst = int(fam.split("_X")[1].split(".")[0])
        key = (row["tile_type"], inst)
        out.setdefault(key, []).append(
            (fam.split(".")[1] + "." + row["src_wire"],
             int(row["frame_off"]), int(row["bit"]), int(row["parity"])))
    return out


def load_init_cells():
    """artix7 segbits 的 *LUT.INIT 表 → {(tileType, siteIdx): [(LUT.INIT[k], foff, bit)]}

    tile type → 文件/站点实例映射：
      CLBLL_L/R: inst0=SLICEL_X0, inst1=SLICEL_X1
      CLBM_L/R : inst0=SLICEM_X0, inst1=SLICEL_X1
    （V7 实测：CLBLL inst0=32..35、CLBM inst0=34..35 起、inst1=26..29 起——与表一致。）"""
    import re as _re
    refdir = os.path.join(HERE, "..", "prjxray_ref", "artix7")
    files = {
        "CLBLL_L": ("segbits_clbll_l.db", ("SLICEL_X0", "SLICEL_X1")),
        "CLBLL_R": ("segbits_clbll_r.db", ("SLICEL_X0", "SLICEL_X1")),
        "CLBLM_L": ("segbits_clblm_l.db", ("SLICEM_X0", "SLICEL_X1")),
        "CLBLM_R": ("segbits_clblm_r.db", ("SLICEM_X0", "SLICEL_X1")),
    }
    out = {}
    for tt, (fn, sites) in files.items():
        for inst, site in enumerate(sites):
            key = (tt, inst)
            for line in open(os.path.join(refdir, fn), encoding="utf-8",
                             errors="replace"):
                m = _re.match(r"CLB\w+\." + site +
                              r"\.([A-D][56]LUT)\.INIT\[(\d+)\] (\d+)_(\d+)$",
                              line.strip())
                if m:
                    out.setdefault(key, []).append(
                        ("%s.INIT[%s]" % (m.group(1), m.group(2)),
                         int(m.group(3)), int(m.group(4))))
    return out


def load_clb_tiles():
    """clb_tiles.csv → slice name → (tileType, gridCol, siteIdx, Y)

    site 实例号不取 getSites() 顺序（_L tile 会颠倒，如 CLBLL_L_X6 的 site0=X9），
    而按 **slice 名 X 奇偶**：偶 X → X0 实例（32/34 窗口），奇 X → X1（26 窗口）。
    实测 10 个 slice（X8/9,10/11,12/13,44/45,52/53）全部符合。"""
    path = os.path.join(PHASEA, "clb_tiles.csv")
    out = {}
    with open(path, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            for sk in ("site0", "site1"):
                s = r[sk]
                if not s:
                    continue
                m = re.match(r"SLICE_X(\d+)Y(\d+)$", s)
                if not m:
                    continue
                x = int(m.group(1))
                out[s] = (r["type"], int(r["gridCol"]), 0 if x % 2 == 0 else 1,
                          int(m.group(2)))
    return out


def load_clb_blocks():
    """block_tiles.csv + frame_index_far.csv → {(gridCol, ylo): base_frame}"""
    fi = {}
    for r in csv.DictReader(open(os.path.join(PHASEA, "frame_index_far.csv"),
                                 encoding="utf-8")):
        if r["kind"] == "block":
            fi.setdefault(int(r["block_addr"], 16), []).append(int(r["frame_index"]))
    blocks = {}
    for r in csv.DictReader(open(os.path.join(PHASEA, "block_tiles.csv"),
                                 encoding="utf-16")):
        if not r["subType"].startswith(("CLBLL", "CLBLM")):
            continue
        gc = int(r["tileColumn"])
        addr = int(r["far"], 16)
        if addr not in fi:
            continue
        m = re.search(r"_X\d+Y(\d+)$", r["bottomTile"])
        if not m:
            continue
        ylo = int(m.group(1))
        blocks[(gc, ylo // BAND_ROWS)] = min(fi[addr])
    return blocks


def word_of(y, parity):
    """word = 2*(Y%50) + (Y%50>=25) + parity  —— word 50 永不产生（= ECC）。

    实测锚点：ALUT/B6LUT(parity=0) Y20→40、Y21→42、Y40→81；
    C6LUT/CLUT(parity=1) Y20→41、Y40→82（s3_results4.txt）。
    帧内 101 个 word = 100 配置位 + 中间 word 50 ECC（上下半带各 25 行×2 parity）。"""
    w = 2 * (y % BAND_ROWS)
    h = 1 if (y % BAND_ROWS) >= 25 else 0
    return w + h + parity


def bit_matrix(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("bit")
    ap.add_argument("--ref")
    ap.add_argument("--json", default="clb_decode.json")
    a = ap.parse_args()

    t0 = time.time()
    M = bit_matrix(a.bit)
    R = bit_matrix(a.ref) if a.ref else None
    print(f"bit matrix {M.shape} ({time.time()-t0:.1f}s)")

    # 去掉冗余的 load_init_cells（site_cells.json 已含 2,048 行 INIT）
    cells = load_site_cells()
    tiles = load_clb_tiles()
    blocks = load_clb_blocks()
    print(f"site features {sum(len(v) for v in cells.values())}, "
          f"slices {len(tiles)}, blocks {len(blocks)}")

    # window：artix7 表已含 CLBLL(32)/CLBM(34) 与 X1(26) 的差异，实测 V7 一致 → 无需修正
    def shift(tt, idx):
        return 0

    hits = []
    t0 = time.time()
    for sname, (tt, gc, idx, y) in tiles.items():
        base = blocks.get((gc, y // BAND_ROWS))
        if base is None:
            continue
        for feat, foff, bit, par in cells.get((tt, idx), ()):
            w = word_of(y, par)
            f = base + foff
            if f >= M.shape[0]:
                continue
            on = bool(M[f, w, bit])
            if R is not None:
                on = on and not bool(R[f, w, bit])
            if on:
                hits.append([sname, tt, idx, feat, f, w, bit])
    print(f"decode {time.time()-t0:.1f}s, hits {len(hits)}")
    json.dump(hits, open(a.json, "w", encoding="utf-8"), indent=1)
    print("wrote", a.json)


if __name__ == "__main__":
    main()
