#!/usr/bin/env python3
"""
gen_all_cells.py —— 把 prjxray artix7 的 INT segbits 全量转成形状表。

输入：prjxray_ref/artix7/segbits_int_{l,r}.db
      格式  INT_L.<mux>.<src> <word>_<bit> [!]<word>_<bit> ...
输出：step03_pip/all_cells.json
      [{tile_type, family, sink, src_wire, frame_off, bit, sense}, ...]

约定
====
* `frame_off` = segbits 里的 word 值。实测（IMUX 系列）证明
  `frame = block_start(col, Y) + word`，bit 用 segbits 的 bit。
* `sense`：前缀 `!` 表示该位要清 0（0），否则置 1。
* 实际比特流里的 32 位字序号 = 2*(Y % 50) + p，p 由 mux 决定；
  IMUX 的 p = (L // 4) % 2（已实测），其它家族的 p 未验证。
"""
import collections
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REF = os.path.join(os.path.dirname(HERE), "prjxray_ref", "artix7")
OUT = os.path.join(HERE, "all_cells.json")


def parse(path, tile_type, out, fam_count):
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            parts = line.split()
            feat, bits = parts[0], parts[1:]
            seg = feat.split(".")
            if len(seg) != 3:
                continue
            _t, family, src = seg
            if family != _t:  # 形如 INT_L.IMUX_L8.GFAN0
                fam_count[(tile_type, family)] += 1
            for b in bits:
                sense = 0 if b.startswith("!") else 1
                bb = b.lstrip("!")
                word, bit = bb.split("_")
                raw = int(bit)
                out.append({
                    "tile_type": tile_type,
                    "family": family,
                    "src_wire": src,
                    "frame_off": int(word),
                    # prjxray 把行内两个字 (2Y, 2Y+1) 打包进 0..63：
                    # 低 32 位属 2Y，高 32 位属 2Y+1（IMUX 12 个 mux 已实测证实）
                    "parity": raw // 32,
                    "bit": raw % 32,
                    "sense": sense,
                })


def main():
    out = []
    fam = collections.Counter()
    for fname, ttype in (("segbits_int_l.db", "INT_L"), ("segbits_int_r.db", "INT_R")):
        p = os.path.join(REF, fname)
        if not os.path.exists(p):
            print(f"缺少 {p}", file=sys.stderr)
            return 1
        parse(p, ttype, out, fam)
    with open(OUT, "w") as fh:
        json.dump(out, fh)

    by_type = collections.Counter(r["tile_type"] for r in out)
    fams = sorted({r["family"] for r in out})
    imux = sorted({r["family"] for r in out if r["family"].replace("_L", "").startswith("IMUX")})
    print(f"写出 {OUT}")
    print(f"  单元 {len(out)}  类型 {dict(by_type)}  家族 {len(fams)}")
    print(f"  IMUX 家族 {len(imux)}：{imux[:6]} …")
    other = [f for f in fams if f not in imux]
    print(f"  其它家族 {len(other)}：{other[:10]} …")
    dfo = collections.Counter(r["frame_off"] for r in out)
    print(f"  frame_off 分布 {dict(sorted(dfo.items()))}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
