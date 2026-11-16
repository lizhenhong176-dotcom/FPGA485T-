#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""col_xor_model.py —— 解释 col_*/rep_*/t1* 这批「列扫描」证据到底是什么

发现（本脚本要证明的）：
    `blkcol*.sh` / `colscan*.sh` 的 ref_$TAG.bit 是用**原始 dcp**（路由已选好 sink PIP）
    生成的，而 p6_make2.py 的变体是「把 sink PIP 换成候选源」。
    所以 col_diff.py 记录的差分 = code(原始源 S0) XOR code(候选源 S)，
    不是单个 PIP 的位集 —— 这解释了为什么它比 tilepipe 多出 sense=0 的格。

    对照：tilepipe 的 ref 是 p6_make2 写出的 `ref_$TAG.dcp`（**已删掉 sink PIP**），
    所以 tilepipe 的差分 = code(S) 本身 = 形状表里 sense=1 的格。

判定方法：
    对每个列扫描文件，暴力搜索 (mux, S0)，使得对所有 25 条 wire 都有
        observed[w] == sense1(mux, S0) △ sense1(mux, w)
    若唯一命中 → 模型成立，且顺带把该文件的 mux 与原始源认出来。
"""
from __future__ import annotations

import json
import os
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pip_law  # noqa: E402

# 文件 → (真实 tile 列, 行)。列由 SLICE_X 反查 model DB 得到（SLICE 编号会跳过非 CLB 列！）
#   SLICE_X8 →CLBLL_L_X6   X10→CLBLM_R_X7  X12→CLBLM_L_X8   X14→CLBLM_R_X9
#   SLICE_X16→CLBLL_L_X10  X18→CLBLM_L_X12 X20→CLBLM_R_X13  X22→CLBLM_R_X15
FILES = {
    "rep_C6R.json": (6, 11, "SLICE_X8Y11"),
    "t10.json":     (7, 11, "SLICE_X10Y11"),
    "rep_C8R.json": (8, 11, "SLICE_X12Y11"),
    "t12.json":     (8, 11, "SLICE_X12Y11"),
    "col_9.json":   (9, 11, "SLICE_X14Y11"),
    "t16.json":     (10, 11, "SLICE_X16Y11"),
    "col_11.json":  (12, 11, "SLICE_X18Y11"),
    "col_12.json":  (13, 11, "SLICE_X20Y11"),
    "col_13.json":  (15, 11, "SLICE_X22Y11"),
    "col_B1.json":  (6, 61, "SLICE_X8Y61"),
}


def sense1(ttype: str, mux: str, wire: str):
    cells = pip_law._CELLS.get((ttype, mux, wire))
    if not cells:
        return None
    return {(df, bit) for df, bit, s in cells if s == 1}


def all_senses(ttype: str, mux: str, wire: str):
    cells = pip_law._CELLS.get((ttype, mux, wire))
    if not cells:
        return None
    return {(df, bit) for df, bit, s in cells}


def muxes_of(ttype: str):
    return sorted({m for (t, m, w) in pip_law._CELLS if t == ttype},
                  key=lambda s: int("".join(ch for ch in s if ch.isdigit()) or 0))


def fit(fname, col, y):
    d = json.load(open(os.path.join(HERE, fname), encoding="utf-8-sig"))
    ttype = "INT_L" if col % 2 == 0 else "INT_R"
    base = pip_law.block_start(col, y)
    obs = {}
    for w, cells in d.items():
        obs[w] = {(f - base - pip_law.SHAPE_ORIGIN, b) for f, ww, b in cells if ww != 50}
    hits = []
    for mux in muxes_of(ttype):
        for s0 in obs:
            code0 = sense1(ttype, mux, s0)
            if code0 is None:
                continue
            good = bad = 0
            for w, o in obs.items():
                code = sense1(ttype, mux, w)
                if code is None:
                    continue
                if o == (code0 ^ code):
                    good += 1
                else:
                    bad += 1
            if bad == 0 and good:
                hits.append((mux, s0, good))
    return obs, hits, ttype, base


def main():
    print("== 列扫描文件 = XOR 模型判定 ==")
    print("   （observed[w] 是否等于 code(S0) △ code(w)，S0 = 该设计路由原本选中的源）\n")
    all_ok = True
    summary = []
    for fname, (col, y, sl) in FILES.items():
        if not os.path.exists(os.path.join(HERE, fname)):
            print(f"  {fname:<14} 缺文件")
            continue
        obs, hits, ttype, base = fit(fname, col, y)
        if hits:
            muxes = sorted({h[0] for h in hits})
            s0s = sorted({h[1] for h in hits})
            print(f"  {fname:<14} col {col:<3} Y{y:<3} {sl:<12} base {base}  "
                  f"命中 {len(hits)} 组: mux={muxes} S0={s0s}  → XOR 模型成立")
            summary.append((fname, col, y, muxes, s0s, len(obs)))
        else:
            all_ok = False
            # 退一步：只用「code(w) ⊆ 全体 sense」看是不是纯 PIP 差分
            print(f"  {fname:<14} col {col:<3} Y{y:<3} base {base}  ✗ 没有 (mux,S0) 能解释全部 {len(obs)} 条")
    print(f"\n结论: {'全部文件都能用 XOR 模型解释' if all_ok else '有文件不能用 XOR 模型解释'}")

    # ---- 交叉验证：tilepipe 是「纯 PIP 差分」= sense=1 集合
    print("\n== tilepipe = 纯 PIP 差分（observed 应恰等于 sense=1 的格）==")
    tp = json.load(open(os.path.join(HERE, "tilepipe.json"), encoding="utf-8-sig"))
    ex = sub = extra = miss = 0
    for tag, rec in tp.items():
        mux = rec["sink"]
        if not mux:
            continue
        col, y = (6, 11) if tag.startswith("SLICE_X8") else (6, 11)
        base = pip_law.block_start(col, y)
        for w, cells in rec["sources"].items():
            o = {(f - base - pip_law.SHAPE_ORIGIN, b) for f, ww, b in cells if ww != 50}
            code = sense1("INT_L", mux, w)
            full = all_senses("INT_L", mux, w)
            if code is None:
                miss += 1
                continue
            if o == code:
                ex += 1
            elif o <= code:
                sub += 1
            elif full and o <= full:
                extra += 1
            else:
                extra += 1
    print(f"  EXACT(= sense1 集合) {ex}   SUB {sub}   其它 {extra}   无形状记录 {miss}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
