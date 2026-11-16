# -*- coding: utf-8 -*-
"""A2/A3：HCLK_CMT 的 MUX_CLK_13 族：逐源 (frame_off, word, bit) 表 + 结构判定。

输入：
  step03_pip/out/hclk_diff_raw.json  远端全量差分（绝对 frame/word/bit）
  step03_pip/out/hclk_regions.json   字段区原始字值 + PLL 受控差分
  v7re/steps/hclk_sources.json       模板源集合
  .pips 证据：所有样本 dst = HCLK_CMT_MUX_CLK_13
输出：
  step03_pip/out/hclk_mux13_cells.json
"""
import json, collections, io

BASE = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\out"
raw = json.load(io.open(f"{BASE}/hclk_diff_raw.json", encoding="utf-8"))
reg = json.load(io.open(f"{BASE}/hclk_regions.json", encoding="utf-8"))

# 段基址（A1 实测）：band4 col33 -> 22118；band6 col33 -> 32610
BASE_FRAME = {4: {33: 22118}, 6: {33: 32610}}
# 由绝对帧定位 (band, off)
LOC = {}
for b, cols in ((4, [22118]), (6, [32610])):
    for f in range(min(cols), min(cols) + 30):
        LOC[f] = (b, 33, f - min(cols))

SRC_PIPS = {
    "k0": "MUX_CLK_MMCM0", "k1": "MUX_CLK_MMCM2", "k2": "MUX_CLK_MMCM4",
    "k3": "MUX_CLK_MMCM6", "k4": "MUX_CLK_MMCM8", "k5": "MUX_CLK_MMCM9",
    "k6": "MUX_CLK_MMCM10",
    "g0": "MUX_CLK_MMCM0", "g1": "MUX_CLK_MMCM2", "g2": "MUX_CLK_MMCM4",
    "p0": "MUX_CLK_PLL0", "p1": "MUX_CLK_PLL1", "p2": "MUX_CLK_PLL2",
    "p3": "MUX_CLK_PLL3", "p4": "MUX_CLK_PLL4", "p5": "MUX_CLK_PLL5",
}
FAMILY = "MUX_CLK_13"

out = {"family": FAMILY, "evidence": {}, "by_src": {}}

# 1) MMCM 组：hclk5(k0..k6, band4) 与 hclk4(g0..g2, band6) —— 两点独立复现
for exp, base_name in (("hclk5", "k0"), ("hclk4", "g0")):
    block = raw[exp]
    base_cells = {}
    for nm, s in block["samples"].items():
        cells = [c for c in s["cells"] if c[1] != 50]
        rel = []
        for f, w, b, vb, vs in cells:
            L = LOC.get(f)
            rel.append(dict(band=L[0], col=L[1], off=L[2], word=w, bit=b, base=vb, sample=vs))
        out["evidence"].setdefault(f"{exp}/{nm}", {
            "src": SRC_PIPS[nm], "n_data_cells": len(rel),
            "n_ecc_cells": s["n_cells"] - len(rel), "cells": rel})

# 2) PLL 组：hclk6 p_i vs p0（受控）
for nm, v in reg["pll_diff"].items():
    cells = [c for c in v["cells"] if c[1] != 50]
    rel = []
    for f, w, b, vb, vs in cells:
        L = LOC.get(f)
        rel.append(dict(band=L[0], col=L[1], off=L[2], word=w, bit=b, base=vb, sample=vs))
    out["evidence"][f"hclk6/{nm}"] = {"src": SRC_PIPS[nm], "n_data_cells": len(rel),
                                     "n_ecc_cells": v["n"] - len(rel), "cells": rel}

# 3) 结构判定：把每个源的差分格按 (off, word) 归类
def classify(cells):
    field = collections.defaultdict(list)
    for c in cells:
        field[(c["off"], c["word"])].append(c["bit"])
    return {f"{k[0]}/{k[1]}": sorted(v) for k, v in field.items()}

print("族：", FAMILY)
print("\n== MMCM 样本（band4, hclk5 vs k0）")
for nm in ("k1", "k2", "k3", "k4", "k5", "k6"):
    e = out["evidence"][f"hclk5/{nm}"]
    print(f"  {e['src']:<18} 数据格 {e['n_data_cells']}  ECC格 {e['n_ecc_cells']}")
    print("     ", classify(e["cells"]))
print("\n== MMCM 复现（band6, hclk4 vs g0）")
for nm in ("g1", "g2"):
    e = out["evidence"][f"hclk4/{nm}"]
    print(f"  {e['src']:<18} 数据格 {e['n_data_cells']}  ECC格 {e['n_ecc_cells']}")
    print("     ", classify(e["cells"]))
print("\n== PLL 样本（hclk6 vs p0）")
for nm in ("p1", "p2", "p3", "p4", "p5"):
    e = out["evidence"][f"hclk6/{nm}"]
    print(f"  {e['src']:<18} 数据格 {e['n_data_cells']}  ECC格 {e['n_ecc_cells']}")
    print("     ", classify(e["cells"]))

json.dump(out, io.open(f"{BASE}/hclk_mux13_cells.json", "w", encoding="utf-8"),
          indent=1, ensure_ascii=False)
print("\nWROTE", f"{BASE}/hclk_mux13_cells.json")
