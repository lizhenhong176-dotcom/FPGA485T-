#!/usr/bin/env python3
"""T2 补充：family 名字的作用域（tile_type 级 vs 实例级）。

数据：tamper/ref/pips_all.txt —— Vivado 2017.2 `get_pips -of_objects [get_nets -hier]`
的直接导出（生成语句见 `tamper/ref/build.tcl:14-19`，器件 xc7vx485tffg1761-2），
每行 `TILE/TILE_TYPE.DRIVER->DST`（配置型 mux PIP）或 `...->>DST`（相邻/静态固定连接）。
箭头语义：两种形式都是「左侧驱动右侧」，DST 在右。
输出：v7re/steps/t2_scope.out.txt
"""
import collections
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(os.path.dirname(HERE))
PIPS = os.path.join(PROJECT, "tamper", "ref", "pips_all.txt")
ALL_CELLS = os.path.join(PROJECT, "step03_pip", "all_cells.json")
OUT = os.path.join(HERE, "t2_scope.out.txt")

NAMES = ["IMUX_L34", "WW4BEG0", "WW4END0"]


def parse():
    rows = []
    with open(PIPS, encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line or "/" not in line:
                continue
            tile, rest = line.split("/", 1)
            if "->>" in rest:
                kind = "->>"
                a, b = rest.split("->>", 1)
            elif "->" in rest:
                kind = "->"
                a, b = rest.split("->", 1)
            else:
                continue
            ttype, src = a.split(".", 1)
            dst = b.split(".", 1)[-1]
            rows.append((tile, ttype, kind, src, dst))
    return rows


def main():
    lines = []

    def emit(s=""):
        lines.append(s)
        print(s)

    rows = parse()
    emit(f"pips_all.txt 解析 {len(rows)} 行（'->' 站点内部直连={sum(1 for r in rows if r[2]=='->')}，"
         f"'->>' 互连级 PIP={sum(1 for r in rows if r[2]=='->>')}）；两种形式都是 左驱动右，DST 在右")

    emit("\n== A) 三个名字各自作为 DST / SRC 的 tile 实例数 ==")
    for name in NAMES:
        dst = [r for r in rows if r[4] == name]
        src = [r for r in rows if r[3] == name]
        emit(f"   {name}: DST {len(dst)} 行 / {len({r[0] for r in dst})} 个 tile；"
             f"SRC {len(src)} 行 / {len({r[0] for r in src})} 个 tile")
        if dst:
            arrow = dst[0][2]
            emit(f"      作 DST 例: {dst[0][0]}/{dst[0][1]}.{dst[0][3]}{arrow}{dst[0][4]}"
                 f"（{dst[0][2]}）")
            emit(f"      作 DST 的 tile_type={sorted({r[1] for r in dst})}，"
                 f"前 4 个 tile={sorted({r[0] for r in dst})[:4]}")
        if src:
            emit(f"      作 SRC 例: {src[0][0]}/{src[0][1]}.{src[0][3]} -> {src[0][4]}")

    emit("\n== B) tile_type 命名空间：INT_L 与 INT_R 的 family 名集合关系 ==")
    cells = json.load(open(ALL_CELLS, encoding="utf-8"))
    fam = collections.defaultdict(set)
    for c in cells:
        fam[c["tile_type"]].add(c["family"])
    both = fam["INT_L"] & fam["INT_R"]
    emit(f"   INT_L family={len(fam['INT_L'])}  INT_R family={len(fam['INT_R'])}  交集={len(both)}")
    emit(f"   交集样例: {sorted(both)[:10]}")
    emit(f"   仅 INT_L {len(fam['INT_L']-fam['INT_R'])} 例: {sorted(fam['INT_L']-fam['INT_R'])[:6]}")
    emit(f"   仅 INT_R {len(fam['INT_R']-fam['INT_L'])} 例: {sorted(fam['INT_R']-fam['INT_L'])[:6]}")

    emit("\n== C) 同一 family 名在 segbits 表里有无坐标维度（作用域的结构性证据）==")
    emit("   segbits 行格式 = TILE_TYPE.FAMILY.SRC word_bit...，无 col/y 字段")
    emit("   → 一条记录描述的是「该 tile 类型内的一次连接」，解码时对每个实例施加同一份表")

    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
