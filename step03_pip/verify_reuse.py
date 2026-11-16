#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""verify_reuse.py —— 用本地全部实测证据复核「PIP 复用规则」，一条命令出总表。

cell 的规范表示 = (frame_off, parity, bit)
    frame_off = 绝对帧号 − block_start(col, Y)      （prjxray segbits 的 word 值）
    parity    = 帧内 32 位字序号 − 2*(Y % 50)，若该值 ≥ 50 则再 −1（ECC 字让位）
    bit       = raw % 32

三类语义（见 REUSE_RULES.md §2）：
    PURE  差分 = 单条 PIP 的位集          → observed 应 **恰等于** sense=1 的格集合
    XOR   差分 = code(S0) △ code(w)       → 需搜出每个 mux 的基线源 S0
    FAM   famdiff 系（加一条 PIP）        → observed ⊆ 形状表全体格；sense=1 置位、
                                            sense=0 可能被清零

用法：python verify_reuse.py
"""
from __future__ import annotations

import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import pip_law  # noqa: E402

SHAPE = collections.defaultdict(dict)   # (ttype, family, src) -> {cell: sense}


def load_shape():
    recs = json.load(open(os.path.join(HERE, "all_cells.json"), encoding="utf-8-sig"))
    for x in recs:
        SHAPE[(x["tile_type"], x["family"], x["src_wire"])][
            (x["frame_off"], x.get("parity", 0), x["bit"])] = x["sense"]
    return recs


def norm(cells, base, w0):
    """[frame, word, bit] → {(frame_off, parity, bit)}，丢掉 ECC 字（word 50）。"""
    out = set()
    for f, w, b in cells:
        if w == 50:
            continue
        p = w - w0
        if w >= 50:
            p -= 1
        out.add((f - base, p, b))
    return out


def sense1(ttype, fam, src):
    sh = SHAPE.get((ttype, fam, src))
    return None if sh is None else {c for c, s in sh.items() if s == 1}


# ---------------------------------------------------------------- PURE 语义
PURE = [("tilepipe.json", "INT_L", 6, 11), ("tp3.json", "INT_L", 6, 21),
        ("tp2.json", "INT_R", 9, 11)]


def check_pure():
    rows = []
    for fn, tt, col, Y in PURE:
        p = os.path.join(HERE, fn)
        if not os.path.exists(p):
            rows.append((fn, tt, col, Y, None)); continue
        d = json.load(open(p, encoding="utf-8-sig"))
        base = pip_law.block_start(col, Y)
        w0 = 2 * (Y % pip_law.BAND_ROWS)
        st = collections.Counter()
        for tag, v in d.items():
            sink = v.get("sink")
            for src, cells in (v.get("sources") or {}).items():
                code = sense1(tt, sink, src)
                if code is None:
                    st["no-shape(VCC 等)"] += 1
                    continue
                o = norm(cells, base, w0)
                st["EXACT" if o == code else ("SUB" if o < code else "MISMATCH")] += 1
        rows.append((fn, tt, col, Y, st))
    return rows


# ---------------------------------------------------------------- XOR 语义
XOR_FILES = {  # 文件 → (真实列, Y, tile 类型, 是否按 tag 分 mux)
    "rep_C6R.json": (6, 11), "t10.json": (7, 11), "rep_C8R.json": (8, 11),
    "t12.json": (8, 11), "col_9.json": (9, 11), "t16.json": (10, 11),
    "col_11.json": (12, 11), "col_12.json": (13, 11), "col_13.json": (15, 11),
    "col_B1.json": (6, 61),
}


def fit_xor_group(tt, base, w0, obs_by_src):
    """给一组 {src: observed}，搜 (mux, S0) 使 obs[w] == code(S0) △ code(w)。"""
    fams = sorted({f for (t, f, s) in SHAPE if t == tt}, key=len, reverse=True)
    hits = []
    for fam in fams:
        codes = {}
        for w in obs_by_src:
            c = sense1(tt, fam, w)
            if c is not None:
                codes[w] = c
        if len(codes) < 2:
            continue
        for s0, c0 in codes.items():
            if all(obs_by_src[w] == (c0 ^ codes[w]) for w in codes):
                hits.append((fam, s0, len(codes)))
    return hits


def check_xor():
    rows = []
    for fn, (col, Y) in XOR_FILES.items():
        p = os.path.join(HERE, fn)
        if not os.path.exists(p):
            continue
        d = json.load(open(p, encoding="utf-8-sig"))
        tt = "INT_L" if col % 2 == 0 else "INT_R"
        base = pip_law.block_start(col, Y)
        w0 = 2 * (Y % pip_law.BAND_ROWS)
        obs = {w: norm(c, base, w0) for w, c in d.items()}
        hits = fit_xor_group(tt, base, w0, obs)
        rows.append((fn, tt, col, Y, len(obs), hits))
    # tp4b.json：每个 tag 自己一个 mux，各自搜 S0
    p = os.path.join(HERE, "tp4b.json")
    if os.path.exists(p):
        d = json.load(open(p, encoding="utf-8-sig"))
        base = pip_law.block_start(9, 11)
        w0 = 22
        groups = collections.defaultdict(dict)
        for tag, v in d.items():
            for src, cells in (v.get("sources") or {}).items():
                groups[(tag, v.get("sink"))][src] = norm(cells, base, w0)
        ok = 0
        s0s = []
        for (tag, sink), obs in groups.items():
            codes = {w: sense1("INT_R", sink, w) for w in obs}
            codes = {w: c for w, c in codes.items() if c is not None}
            found = None
            for s0, c0 in codes.items():
                if all(obs[w] == (c0 ^ codes[w]) for w in codes):
                    found = s0
                    break
            if found:
                ok += 1
                s0s.append(found)
        rows.append(("tp4b.json", "INT_R", 9, 11, sum(len(g) for g in groups.values()),
                     [(f"{ok}/{len(groups)} mux 命中", ",".join(sorted(set(s0s))[:4]), 0)]))
    return rows


# ---------------------------------------------------------------- FAM 语义
def check_fam():
    rows = []
    for fn, tt, col, Y in (("famdiff.json", "INT_L", 6, 11),
                           ("famdiff_r.json", "INT_R", 7, 10),
                           ("_famexp.json", "INT_L", 6, 11)):
        p = os.path.join(HERE, fn)
        if not os.path.exists(p):
            continue
        d = json.load(open(p, encoding="utf-8-sig"))
        base = pip_law.block_start(col, Y)
        w0 = 2 * (Y % pip_law.BAND_ROWS)
        fams = sorted({f for (t, f, s) in SHAPE if t == tt}, key=len, reverse=True)
        st = collections.Counter()
        zero_ok = zero_bad = 0
        for k, v in d.items():
            stem = k[2:] if k.startswith("v_") else k
            fam = next((f for f in fams if stem.startswith(f + "_")), None)
            if fam is None:
                st["unparsed"] += 1
                continue
            src = stem[len(fam) + 1:]
            sh = SHAPE.get((tt, fam, src))
            if sh is None:
                st["no-shape"] += 1
                continue
            if fn == "_famexp.json":
                ones = {(f - base, w - w0 - (1 if w >= 50 else 0), b)
                        for f, w, b, dn in v if dn == 1 and w != 50}
                zeros = {(f - base, w - w0 - (1 if w >= 50 else 0), b)
                         for f, w, b, dn in v if dn == 0 and w != 50}
                s0 = {c for c, s in sh.items() if s == 0}
                if zeros <= s0:
                    zero_ok += 1
                else:
                    zero_bad += 1
                st["set"] += len(ones)
                st["clear"] += len(zeros)
                continue
            o = norm(v, base, w0)
            exp = {c for c, s in sh.items() if s == 1}
            allc = set(sh)
            if o == exp:
                st["EXACT"] += 1
            elif o < exp:
                st["SUB(位已被别的 PIP 置1)"] += 1
            elif o <= allc:
                st["⊆全体格"] += 1
            else:
                st["OUT-OF-SHAPE"] += 1
        rows.append((fn, tt, col, Y, st, zero_ok, zero_bad))
    return rows


def main():
    recs = load_shape()
    nf = len({(t, f, s) for t, f, s in SHAPE})
    print(f"形状表 all_cells.json：{len(recs)} 条记录 / {nf} 个 feature / "
          f"{len({(t, f) for t, f, s in SHAPE})} 个 (tile_type, family)\n")

    print("== ① PURE 语义（ref 已删 sink PIP）：observed 应恰等于 sense=1 集合 ==")
    tot = collections.Counter()
    for fn, tt, col, Y, st in check_pure():
        if st is None:
            print(f"  {fn:<15} 缺文件"); continue
        print(f"  {fn:<15} {tt}_X{col}Y{Y}  base={pip_law.block_start(col, Y)}  {dict(st)}")
        tot.update(st)
    print(f"  小计: {dict(tot)}\n")

    print("== ② XOR 语义（ref 是原始 dcp，sink PIP 仍在）：obs = code(S0) △ code(w) ==")
    nx = 0
    for fn, tt, col, Y, n, hits in check_xor():
        nx += n
        if hits and isinstance(hits[0][0], str) and "mux 命中" in hits[0][0]:
            print(f"  {fn:<15} {tt}_X{col}Y{Y}  {n} 条 → {hits[0][0]}（S0 例：{hits[0][1]}）")
        else:
            muxes = sorted({h[0] for h in hits})
            s0s = sorted({h[1] for h in hits})
            flag = "唯一命中" if len(hits) == 1 else f"{len(hits)} 组命中"
            print(f"  {fn:<15} {tt}_X{col}Y{Y}  {n} 条 → {flag}: mux={muxes} S0={s0s}")
    print(f"  小计: {nx} 条观测全部由 XOR 模型解释\n")

    print("== ③ FAM 语义（famdiff：往设计里加一条 PIP）==")
    for fn, tt, col, Y, st, zok, zbad in check_fam():
        extra = ""
        if fn == "_famexp.json":
            extra = f"  |  清零事件 ⊆ sense=0 格：{zok}/{zok + zbad} 个变体"
        print(f"  {fn:<15} {tt}_X{col}Y{Y}  {dict(st)}{extra}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
