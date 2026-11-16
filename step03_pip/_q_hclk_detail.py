# -*- coding: utf-8 -*-
"""A2：逐源差分明细（排除 word 50 = ECC 重算副作用）。"""
import json, collections, io

d = json.load(io.open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out\hclk_cells.json", encoding="utf-8"))

for exp in ("hclk5", "hclk4"):
    block = d["experiments"][exp]
    print(f"\n===== {exp}  base={block['base']} ({block['base_src']})")
    for nm, s in block["samples"].items():
        cells = [c for c in s["rel_cells"] if c[3] != 50]
        ecc = [c for c in s["rel_cells"] if c[3] == 50]
        print(f"  {nm} ({s['src']}): 数据格 {len(cells)}  ECC格 {len(ecc)}")
        for c in sorted(cells):
            band, col, off, word, bit, vb, vs = c
            print(f"     band{band} col{col} frame_off={off:2d} word={word:3d} bit={bit:2d}  {vb}->{vs}")
