#!/usr/bin/env python3
"""all_int_tiles_check.py —— 全器件 INT tile「同一套规则」的观测检验。

判据（可证伪、不依赖解码器输出）：
  对**每一个** INT_L / INT_R 实例，取它的窗口
      frames = base + [0..25]，words = {2*(y%50)+parity}（y%50>=25 再 +1，与 site_frames 一致）
  窗口内所有置 1 的位，其相对坐标 (frame_off, parity, bit) 必须落在
  「该 tile_type 的格宇宙」= law_cells 里所有 (family, src, sense=1) 格的并集内。
  只要有一个置位不在宇宙里 → 该 tile 违反「同一套规则」。

  另外统计：多少 tile 的窗口为空（未被任何设计用到），多少非空，残差分布。

用法：
    python all_int_tiles_check.py --bit _full8.bit [--bit _c0.bit ...]
"""
import argparse
import json
import os
import pickle
import sqlite3
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

CACHE = os.path.join(os.path.dirname(ROOT), "_tiles_cache.pkl")
BAND_ROWS = 50
OFFS = range(0, 26)

# 非族级控制位白名单：语义已知、不在 law_cells 里，不算"规律失效"。
#   (0,16,1)        GCLK 直通使能位（T41 / bitwriter.GCLK_PASS_BIT）
#   (1,3,0) (1,7,0) BYP/FAN 二级旁路控制位（T5）
#   (1,31,0)        同族旁路（T78 实测）
CONTROL_BITS = {
    (0, 16, 1),                       # GCLK 直通使能（T41）
    (1, 3, 0), (1, 7, 0), (1, 31, 0), # BYP/FAN 二级旁路，parity 0（T5/T78）
    (1, 3, 1), (1, 7, 1),             # 同族旁路，parity 1（_c3/_c4 实测，T79）
}


def load_cache():
    with open(CACHE, "rb") as fh:
        return pickle.load(fh)


def bit_matrix(path):
    frames = frames_from_bit(path)
    arr = np.array(frames, dtype=np.uint32)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--bit", action="append", required=True)
    ap.add_argument("--limit", type=int, default=0, help="只查前 N 个 tile（调试用）")
    a = ap.parse_args()

    tiles, bands, bbr, U = load_cache()
    # 白名单并入宇宙：这些位已知语义，不计入残差
    for _tt in list(U):
        U[_tt] = set(U[_tt]) | CONTROL_BITS
    names = sorted(tiles)
    if a.limit:
        names = names[:a.limit]

    covered = set()
    total_bits = total_res = 0
    fail_list = []
    for bitfile in a.bit:
        M = bit_matrix(bitfile)
        nframes = M.shape[0]
        nonempty = 0
        bits_here = res_here = 0
        samples = []
        for name in names:
            tt, col, y = tiles[name]
            band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
            base = bands.get((band, col), -1)
            if base < 0:
                continue
            w0 = 2 * (y % BAND_ROWS)
            if (y % BAND_ROWS) >= 25:
                w0 += 1
            u = U[tt]
            nz = 0
            for fo in OFFS:
                fi = base + fo
                if fi >= nframes:
                    continue
                for k in (0, 1):
                    w = w0 + k
                    if w >= 101 or w == 50:
                        continue
                    v = M[fi, w, :]
                    if not v.any():
                        continue
                    nz += int(v.sum())
                    for b in np.nonzero(v)[0]:
                        if (fo, int(b), k) in u:
                            pass
                        else:
                            res_here += 1
                            if len(samples) < 5:
                                samples.append((name, fo, w, int(b)))
            if nz:
                nonempty += 1
                covered.add(name)
            bits_here += nz
        total_bits += bits_here
        total_res += res_here
        if res_here:
            fail_list.append((bitfile, res_here, samples))
        print("%-46s tile=%3d bits=%4d residual=%d" % (os.path.basename(bitfile), nonempty, bits_here, res_here))
    print()
    print("=== 汇总 ===")
    print("检查 bitstream: %d 个" % len(a.bit))
    print("累计覆盖 INT tile 实例: %d / %d（%.2f%%）" % (len(covered), len(names), 100.0 * len(covered) / len(names)))
    print("窗口内置位总数: %d；落在格宇宙外的: %d" % (total_bits, total_res))
    if fail_list:
        print("失败的 bitstream: %d 个" % len(fail_list))
        for f, r, sm in fail_list[:5]:
            print("   %s residual=%d 例: %s" % (f, r, sm))
    print("判定:", "PASS（所有观测到的 INT tile 同一套规则）" if total_res == 0 else "FAIL")
    return 0 if total_res == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
