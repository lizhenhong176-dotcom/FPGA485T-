# -*- coding: utf-8 -*-
"""IMUX 编码表（位级、含极性）生成器。

与 gen_imux_table.py 的区别
---------------------------
旧表把每个输入抽象成 (row, col_code)，丢掉了两件事：
  1. 极性（segbits 里 `!22_02` 表示该位必须为 0）；
  2. 行 2/3 的位并不总在同一列（L7 是 bit 24，L8 是 bit 3），抽象会掩盖它。
本脚本直接保留 segbits 的原始 (df, bit, sense) 三元组：
  df   = segbits word - 16      （0..9，对应 tile 内帧偏移）
  bit  = segbits bit % 32       （prjxray 用 0..63 打包，物理位取模 32）
  sense= 1 置位 / 0 清零

输出
----
- imux_cells.json : [{tile_type,mux,lut_input,src_wire,df,bit,sense}]
- imux_domain.json: {"INT_L|IMUX_L7": [[df,bit], ...]}  该 mux 的完整位域（编码前要清零的范围）

验证
----
用 485T 实测的 36 mux × 24 源（tilepipe.json）比对「正极性位集合」：
必须是 864/864 完全相同，否则拒绝写表。
"""
from __future__ import annotations

import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SEGBITS = [
    (os.path.join(ROOT, "prjxray_ref", "artix7", "segbits_int_l.db"), "INT_L"),
    (os.path.join(ROOT, "prjxray_ref", "artix7", "segbits_int_r.db"), "INT_R"),
]
TILEPIPE = os.path.join(HERE, "tilepipe.json")
OUT_CELLS = os.path.join(HERE, "imux_cells.json")
OUT_DOMAIN = os.path.join(HERE, "imux_domain.json")


def parse(path: str, tile_type: str):
    rx = re.compile(r"%s\.(IMUX(?:_L)?\d+)\.(.+)$" % re.escape(tile_type))
    cells = []  # (mux, wire, df, bit, sense)
    for line in open(path, encoding="utf-8"):
        parts = line.split()
        if not parts or parts[0].startswith("#"):
            continue
        m = rx.match(parts[0])
        if not m:
            continue
        mux, wire = m.group(1), m.group(2)
        for tok in parts[1:]:
            sense = 0 if tok.startswith("!") else 1
            word, bit = (int(x) for x in tok.lstrip("!").split("_"))
            if not (16 <= word <= 25):
                continue  # 只保留 IMUX 选择字段
            cells.append((mux, wire, word - 16, bit % 32, sense))
    return cells


def validate(all_cells) -> tuple[int, int, list]:
    pos = {}
    for mux, wire, df, bit, sense in all_cells:
        if sense:
            pos.setdefault((mux, wire), set()).add((df, bit))
    data = json.load(open(TILEPIPE, encoding="utf-8-sig"))
    total = ok = 0
    bad = []
    for rec in data.values():
        mux = rec["sink"]
        sources = rec["sources"]
        frames = [c[0] for cells in sources.values() for c in cells]
        if not frames:
            continue
        f0 = min(frames)
        for wire, coords in sources.items():
            if (mux, wire) not in pos:
                continue
            total += 1
            obs = {(f - f0, b) for f, _w, b in coords}
            if obs == pos[(mux, wire)]:
                ok += 1
            else:
                bad.append((mux, wire, sorted(obs - pos[(mux, wire)]),
                            sorted(pos[(mux, wire)] - obs)))
    return total, ok, bad


def main() -> int:
    all_cells = []
    for path, ttype in SEGBITS:
        if not os.path.exists(path):
            print("missing", path)
            continue
        got = parse(path, ttype)
        muxes = {c[0] for c in got}
        print("%s: %d mux, %d cells" % (ttype, len(muxes), len(got)))
        all_cells.extend((ttype,) + c for c in got)

    left = [c for c in all_cells if c[0] == "INT_L"]
    total, ok, bad = validate([(m, w, d, b, s) for _t, m, w, d, b, s in left])
    print("validate vs 485T tilepipe: %d/%d bit-exact" % (ok, total))
    for b in bad[:5]:
        print("  mismatch", b)
    if total == 0 or ok != total:
        print("VALIDATION FAILED")
        return 1

    rows = []
    domain = {}
    for ttype, mux, wire, df, bit, sense in all_cells:
        lut = int(re.search(r"(\d+)$", mux).group(1))
        rows.append({"tile_type": ttype, "mux": mux, "lut_input": lut,
                     "src_wire": wire, "df": df, "bit": bit, "sense": sense})
        domain.setdefault("%s|%s" % (ttype, mux), set()).add((df, bit))
    domain = {k: sorted(map(list, v)) for k, v in domain.items()}

    json.dump(rows, open(OUT_CELLS, "w", encoding="utf-8"), indent=0)
    json.dump(domain, open(OUT_DOMAIN, "w", encoding="utf-8"), indent=0)
    print("wrote", OUT_CELLS, len(rows), "cells;", len(domain), "mux domains")
    print("domain sizes:", sorted({len(v) for v in domain.values()}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
