#!/usr/bin/env python3
"""PIP 复用定律（mux 区）——生成式实现与验证。

定律（对 INT_L / INT_R 的 64 个 mux 区 family，每侧）：

  一个 family = 24 个源，占据固定的 6x4 网格：
      slot(row r ∈ 0..5, colcode c ∈ {0001, 0010, 0111, 1011})
  源 S 的配置位 = 行部分 + 列部分：
      frame_row = 16 + r
      frame_col = {25 - i : 第 i 位(LSB=0) 为 1 的 c}
  位平面：
      family 拥有一对相邻位 (B, B+1) 与字 parity p
      列帧始终在 primary 位 P 上；行帧在 r∈{0,1,4,5} 时用 P，r∈{2,3} 时用另一相位 S
      P/S 的二选一称为 family 的 phase，64 个 family 恰好用尽
      16 个位对 × 2 个 parity × 2 个 phase = 64

不在定律内的部分（仍是数据）：
  源 -> slot 的排列（每个 family 24 条），它是器件布线图给出的顺序，不能由线名推出。

用法：
    python pip_reuse_law.py --build          # 从 law_cells 抽取定律参数，写 pip_reuse_law.json
    python pip_reuse_law.py --verify         # 用定律重算全部 mux 区 cell 并与 law_cells 对账
"""
import argparse
import collections
import json
import os
import sqlite3
import sys

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
OUT = os.environ.get("V7RE_LAW_OUT",
                     os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                  "..", "steps", "pip_reuse_law.json"))

MUX_PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")
ROW_MIRROR = {0: "P", 1: "P", 2: "S", 3: "S", 4: "P", 5: "P"}
COL_FRAMES = (25, 24, 23, 22)          # LSB -> MSB of colcode


def load_cells(law_db, tile_type="INT_L"):
    """(family, src) -> set((frame, bit, parity)) ，只取 sense=1。"""
    con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    cells = collections.defaultdict(set)
    for fam, src, fo, bit, sense, par in con.execute(
            "select family,src_wire,frame_off,bit,sense,parity from law_cells "
            "where tile_type=? and sense=1", (tile_type,)):
        cells[(fam, src)].add((fo, bit, par))
    con.close()
    return cells


def slot_of(cells):
    """从 cell 集合反推 slot (row, colcode) 与所用位。"""
    rows = {fo for fo, b, p in cells if 16 <= fo <= 21}
    if len(rows) != 1:
        return None
    r = rows.pop() - 16
    code = 0
    for i, f in enumerate(COL_FRAMES):
        if any(fo == f for fo, b, p in cells):
            code |= 1 << i
    return r, code


def build(law_db):
    cells = load_cells(law_db)
    families = sorted({f for (f, s) in cells if f.startswith(MUX_PREFIX)})
    out = {"device": "xc7vx485t", "tile_type": "INT_L", "version": 1,
           "law": {
               "row_frames": "16 + row, row in 0..5",
               "col_frames": "frame 25-i for bit i (LSB=0) of colcode",
               "row_phase": ROW_MIRROR,
               "grid": "row 0..5 x colcode {1,2,7,11}",
           },
           "families": {}}
    for fam in families:
        srcs = [s for (f, s) in cells if f == fam]
        slots = {}
        allcells = set()
        for s in srcs:
            sl = slot_of(cells[(fam, s)])
            if sl is None:
                sys.exit("family %s 源 %s 不符合 mux 区结构" % (fam, s))
            slots[s] = sl
            allcells |= cells[(fam, s)]
        bits = {}
        for fo, b, p in allcells:
            bits.setdefault(p, set()).add(b)
        par = sorted(bits)
        if len(par) != 1:
            sys.exit("family %s 的 parity 不唯一: %s" % (fam, par))
        par = par[0]
        bset = sorted(bits[par])
        if len(bset) != 2 or bset[1] != bset[0] + 1:
            sys.exit("family %s 的位不是相邻对: %s" % (fam, bset))
        # 列帧用哪一位 = primary
        colbits = set()
        for s in srcs:
            for fo, b, p in cells[(fam, s)]:
                if 22 <= fo <= 25:
                    colbits.add(b)
        if len(colbits) != 1:
            sys.exit("family %s 的列位不唯一: %s" % (fam, colbits))
        primary = colbits.pop()
        pair = bset[0]
        out["families"][fam] = {
            "pair": pair, "parity": par,
            "primary": "P" if primary == pair else "S",
            "slots": {s: [r, c] for s, (r, c) in sorted(slots.items(),
                                                         key=lambda kv: kv[1][0] * 4 + kv[1][1])},
        }
    # 定律自检：64 个 family 用尽 16 对 × 2 parity × 2 phase
    combos = collections.Counter((v["pair"], v["parity"], v["primary"])
                                 for v in out["families"].values())
    out["combo_check"] = {
        "families": len(out["families"]),
        "distinct_combos": len(combos),
        "max_per_combo": max(combos.values()),
        "pairs": sorted({v["pair"] for v in out["families"].values()}),
    }
    return out


def predict(model, family, src):
    f = model["families"][family]
    r, code = f["slots"][src]
    pair, par, primary = f["pair"], f["parity"], f["primary"]
    pbit = pair if primary == "P" else pair + 1
    sbit = pair + 1 if primary == "P" else pair
    cells = {(16 + r, pbit if ROW_MIRROR[r] == "P" else sbit, par)}
    for i in range(4):
        if code >> i & 1:
            cells.add((COL_FRAMES[i], pbit, par))
    return cells


def verify(law_db, model):
    cells = load_cells(law_db)
    checked = ok = 0
    bad = []
    for (fam, src), got in cells.items():
        if not fam.startswith(MUX_PREFIX):
            continue
        checked += 1
        exp = predict(model, fam, src)
        if exp == got:
            ok += 1
        else:
            bad.append((fam, src, sorted(got), sorted(exp)))
    print("mux 区 (family, src) 对账：%d / %d 精确命中，%d 不符" % (ok, checked, len(bad)))
    for b in bad[:5]:
        print("  不符:", b)
    return ok == checked


def stats_all(law_db, tile_type="INT_L"):
    """全域结构统计：各帧窗的源数/格数/网格判定/位对×parity×相位组合数。"""
    cells = load_cells(law_db, tile_type)
    fam = collections.defaultdict(dict)
    for (f, s), v in cells.items():
        fam[f][s] = sorted(v)

    def window(f, d):
        if f.startswith(MUX_PREFIX):
            return "16-25 mux区"
        fo = min(x[0] for v in d.values() for x in v)
        return "0-1  clk/ctrl" if fo <= 1 else ("2-7  BEG6/4" if fo == 2 else "6-15 BEG2/1")

    def grid(d):
        pats = list(d.values())
        if {len(p) for p in pats} != {2}:
            return None
        # 每源两格 = 图上一条边；网格 ⇔ 完全二分图 K(|A|,|B|)
        adj = collections.defaultdict(set)
        for a, b in pats:
            adj[tuple(a)].add(tuple(b))
            adj[tuple(b)].add(tuple(a))
        color = {}
        for start in adj:
            if start in color:
                continue
            color[start] = 0
            stack = [start]
            while stack:
                u = stack.pop()
                for v in adj[u]:
                    if v not in color:
                        color[v] = 1 - color[u]
                        stack.append(v)
                    elif color[v] == color[u]:
                        return None          # 非二分 → 不是网格
        A = {n for n, c in color.items() if c == 0}
        B = {n for n, c in color.items() if c == 1}
        if len(A) * len(B) != len(pats):
            return None                      # 非完全二分
        if len({(tuple(a), tuple(b)) for a, b in pats}) != len(pats):
            return None
        return len(A), len(B)

    agg = collections.defaultdict(lambda: {"families": 0, "grid": collections.Counter(),
                                            "uniq": 0, "combos": collections.Counter(),
                                            "sizes": collections.Counter()})
    for f, d in fam.items():
        g = window(f, d)
        a = agg[g]
        a["families"] += 1
        a["grid"][grid(d)] += 1
        pats = [frozenset(v) for v in d.values()]
        a["uniq"] += (len(set(pats)) == len(pats))
        a["sizes"][tuple(sorted({len(p) for p in pats}))] += 1
        bits = sorted({b for v in d.values() for (_, b, _) in v})
        pars = sorted({p for v in d.values() for (_, _, p) in v})
        # 相位只对网格族有意义
        if grid(d) and len(bits) == 2:
            a["combos"][(tuple(bits), tuple(pars))] += 1
    for g in sorted(agg):
        a = agg[g]
        print("== %s  family=%d  唯一pattern=%d/%d  每源格数=%s"
              % (g, a["families"], a["uniq"], a["families"], dict(a["sizes"])))
        print("   网格判定:", {str(k): v for k, v in a["grid"].items()})
        if a["combos"]:
            print("   (位对,parity) 种类=%d  最大族数/种=%d"
                  % (len(a["combos"]), max(a["combos"].values())))
    return agg


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--law-db", default=LAW_DB)
    ap.add_argument("--build", action="store_true")
    ap.add_argument("--verify", action="store_true")
    ap.add_argument("--stats", action="store_true")
    ap.add_argument("--out", default=OUT)
    a = ap.parse_args()
    if a.stats:
        stats_all(a.law_db)
        if not (a.build or a.verify):
            return
    if a.build:
        model = build(a.law_db)
        with open(a.out, "w", encoding="utf-8") as fh:
            json.dump(model, fh, indent=1, ensure_ascii=False)
        print("写出 %s" % a.out)
        print("family 数:", len(model["families"]))
        print("组合自检:", model["combo_check"])
    else:
        with open(a.out, encoding="utf-8") as fh:
            model = json.load(fh)
    if a.verify:
        sys.exit(0 if verify(a.law_db, model) else 1)


if __name__ == "__main__":
    main()
