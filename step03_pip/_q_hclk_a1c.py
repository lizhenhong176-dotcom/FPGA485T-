# -*- coding: utf-8 -*-
"""A1 决定性检验：直接解 FAR 字段，看观测帧到底属于哪个 (block, top, row, col, minor)。"""
import sqlite3

MODEL = r"E:\v7work\model\v7_model.sqlite"
con = sqlite3.connect(MODEL)

FRAMES = [22144, 22145, 22146, 22147, 32636, 32639, 35528, 35585, 31752, 6510]

def dec(far):
    return dict(block=(far >> 23) & 0x7, top=(far >> 22) & 0x1,
                row=(far >> 17) & 0x1F, col=(far >> 7) & 0x3FF, minor=far & 0x7F)

for f in FRAMES:
    r = con.execute("select far, block_type, is_overhead, row_number, block_addr "
                    "from frame_map where frame_index=?", (f,)).fetchone()
    if r is None:
        print(f, "无记录"); continue
    far, bt, ovh, rn, ba = r
    print(f"frame {f:6d} far=0x{far:08x} block_type={bt} row_number={rn} "
          f"block_addr={ba} overhead={ovh} -> {dec(far)}")
