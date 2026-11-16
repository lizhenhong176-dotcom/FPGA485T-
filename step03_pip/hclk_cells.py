# -*- coding: utf-8 -*-
"""A1/A2：把远端差分（绝对帧/字/位）归一化成 tile 内相对坐标，并按源建表。

来源：/opt/lzh/v7re/work/hclk_diff_20261109.json（本地副本 step03_pip/out/hclk_diff_raw.json）
"""
import json, collections, io

RAW = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\hclk_diff_raw.json"
PLAN = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\hclk_cells.json"

raw = json.load(io.open(RAW, encoding="utf-8"))

# 观测帧 -> (band, far_col, frame_off)（A1 已用 far_bands 算过，这里按段内累加复算）
import sqlite3
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
bands = collections.defaultdict(list)
for b, c, s, n in con.execute("select band, col, start_frame, frames from far_bands"):
    bands[b].append((c, s, n or 0))

def locate(frame):
    for b in sorted(bands):
        lst = bands[b]
        base = lst[0][1]
        end = max(s + n for _, s, n in lst)
        if base <= frame < end:
            for c, s, n in lst:
                if s <= frame < s + n:
                    return b, c, frame - s
    return None

# 每个实验的“被测源”名字（来自 T48/T49 的设计定义）
SRC = {
    "hclk5": {"k0": "MMCM0", "k1": "MMCM1", "k2": "MMCM2", "k3": "MMCM3",
              "k4": "MMCM4", "k5": "MMCM5", "k6": "MMCM6"},
    "hclk4": {"g0": "MMCMOUT0", "g1": "MMCMOUT1", "g2": "MMCMOUT2"},
}

out = {"experiments": {}, "note": "diff cells are (frame, word, bit, base_value, sample_value)"}
for exp, rec in raw.items():
    base = rec["base"]
    block = {"base": base, "base_src": SRC.get(exp, {}).get(base, base),
             "loc": {}, "samples": {}}
    for nm, s in rec["samples"].items():
        loc = {}
        rel = []
        for f, w, b, vb, vs in s["cells"]:
            L = locate(f)
            loc[f] = L
            off = L[2] if L else None
            rel.append([L[0], L[1], off, w, b, vb, vs])
        block["loc"] = {str(k): v for k, v in loc.items()}
        block["samples"][nm] = {
            "src": SRC.get(exp, {}).get(nm, nm),
            "n_cells": s["n_cells"],
            "frames": s["frames"],
            "rel_cells": rel,
        }
    out["experiments"][exp] = block

json.dump(out, io.open(PLAN, "w", encoding="utf-8"), indent=1, ensure_ascii=False)

# 打印结构摘要
for exp, block in out["experiments"].items():
    print(f"== {exp}  基线={block['base']} ({block['base_src']})")
    print("   帧定位:", block["loc"])
    for nm, s in block["samples"].items():
        by = collections.Counter((c[2], c[3]) for c in s["rel_cells"])
        print(f"   {nm}({s['src']}): {s['n_cells']} 格, (frame_off,word) 组合 {len(by)}")
        print("      ", sorted(by.items())[:10])
