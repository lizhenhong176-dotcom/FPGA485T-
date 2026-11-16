#!/usr/bin/env python3
"""
gen_site_cells.py —— 把 artix7 的 CLB site 内 segbits 迁移成形状表（S1）。

输入：prjxray_ref/artix7/segbits_clb{ll,m}_{l,r}.db
      格式  <TILE>.<SITE_INST>.<BEL>.<ATTR> <word>_<bit> [!]<word>_<bit> ...
输出：step03_pip/site_cells.json
      [{tile_type, family, src_wire, frame_off, bit, sense, parity}, ...]

约定
====
* family = "<SITE_INST>.<BEL>"，如 "SLICEL_X0.AFFMUX"。
  SLICEL_X0/X1 是 tile 内左/右 site 实例——实测两者形状不同
  （X0: word30 bit0..3；X1: word30 bit4 + word31 bit0..2），必须分开。
* src_wire = ATTR（IN_A / INIT[00] / ZINI ...）。
* word/bit 解析与 INT 相同：raw//32 为 parity、raw%32 为 bit。
* sense：`!` 前缀 = 清 0。
"""
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REF = os.path.join(os.path.dirname(HERE), "prjxray_ref", "artix7")
OUT = os.path.join(HERE, "site_cells.json")

FILES = (
    ("segbits_clbll_l.db", "CLBLL_L"),
    ("segbits_clbll_r.db", "CLBLL_R"),
    ("segbits_clblm_l.db", "CLBLM_L"),
    ("segbits_clblm_r.db", "CLBLM_R"),
)


def parse(path, tile_type, out):
    n_inst = collections.Counter()
    n_mux = collections.Counter()
    with open(path, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            seg = parts[0].split(".")
            if len(seg) != 4:
                continue
            _tile, site_inst, bel, attr = seg
            family = f"{site_inst}.{bel}"
            n_inst[site_inst] += 1
            if "MUX" in bel:
                n_mux[bel] += 1
            for b in parts[1:]:
                sense = 0 if b.startswith("!") else 1
                bb = b.lstrip("!")
                word, bit = bb.split("_")
                raw = int(bit)
                out.append({
                    "tile_type": tile_type,
                    "family": family,
                    "src_wire": attr,
                    "frame_off": int(word),
                    "parity": raw // 32,
                    "bit": raw % 32,
                    "sense": sense,
                })
    return n_inst, n_mux


def main():
    out = []
    for fname, ttype in FILES:
        p = os.path.join(REF, fname)
        if not os.path.exists(p):
            print(f"缺少 {p}", file=sys.stderr)
            return 1
        n_inst, n_mux = parse(p, ttype, out)
        print(f"{ttype}: features按实例 {dict(n_inst)}")
        print(f"  mux BEL 种类 {len(n_mux)}: {sorted(n_mux)}")
    with open(OUT, "w") as fh:
        json.dump(out, fh)
    by_tt = collections.Counter(r["tile_type"] for r in out)
    fams = {(r["tile_type"], r["family"]) for r in out}
    pairs = {(r["tile_type"], r["family"], r["src_wire"]) for r in out}
    print(f"写出 {OUT}")
    print(f"  单元 {len(out)} 行；按类型 {dict(by_tt)}")
    print(f"  family 实例 {len(fams)}；family×attr 对 {len(pairs)}")
    dfo = collections.Counter(r["frame_off"] for r in out)
    print(f"  frame_off 分布 {dict(sorted(dfo.items()))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
