# -*- coding: utf-8 -*-
"""gen_slots.py —— 从「族名 + 源名」生成源占据的槽位，并与 law_cells 逐条对账。

模型（与本仓库已验证的定律一致）：
  · 每个族是一张二分网格：源 = 边，它占的两个 cell 是两端点。
  · 一类端点 = 「行/组」节点，另一类 = 「列/码」节点。
  · mux 侧（24 源）：6 行 × 4 码；BEG 侧（20 源）：5 组 × 4 列。
  · 归属规则：列/码由源的线类决定；行/组由源的方向令牌决定。

三级口径：
  L1 纯定律  —— 只用两条全局规则（线类→码、方向→行）+ 每族的少量配置，不读该族数据
  L2 回落表  —— 纯定律解决不了的族，用逐族表（表规模 = 族数，不是 cell 数）
  L3 位坐标  —— 槽位 → (frame_off, parity, bit) 还需要每族的 (bit 对, parity)

用法：
    python step03_pip/gen_slots.py
    python step03_pip/gen_slots.py --json step03_pip/out/gen_slots.json
"""
import sqlite3, collections, re, json, argparse, io

DB = r"E:\v7work\model\v7_law.sqlite"


def load(db=DB, tile="INT_L"):
    con = sqlite3.connect(db)
    rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                       "where tile_type=? and sense=1", (tile,)).fetchall()
    fam = collections.defaultdict(lambda: collections.defaultdict(set))
    for f, s, fo, b, p in rows:
        fam[f][s].add((fo, p, b))
    return fam


def line_class(src):
    if re.match(r"^(NE|NW|SE|SW)", src):
        return "diag"
    if re.match(r"^(NL|SL|EL|WL)", src):
        return "rlineL"
    if re.match(r"^(NR|SR|ER|WR)", src):
        return "rlineR"
    if re.match(r"^(EE|WW|NN|SS)\d", src):
        return "axis"
    if re.match(r"^(LH|LV)", src):
        return "longL"
    if src.startswith(("LOGIC_OUTS", "GFAN")):
        return "logic"
    if src.startswith(("BYP_", "FAN_")):
        return "bounce"
    return "other"


def dir_token(src):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|NL|SL|EL|WL|NR|SR|ER|WR)", src)
    if m:
        return m.group(1)
    if src.startswith("LOGIC_OUTS"):
        return "LOGIC"
    return "EXTRA"


def geo_class(src):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", src)
    if m:
        return "len" + m.group(2)
    if re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)", src):
        return "line"
    if src.startswith("LH"):
        return "LH"
    if src.startswith("LV"):
        return "LV"
    if src.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"


# ---------------- BEG 变体 32 族：方向桶 + 长线表（640/640） ----------------
AXIS2 = {"EE", "WW", "NN", "SS"}
FLIP2 = {"EE", "NE", "WW", "SW"}
LONG_TBL = {0: {"LH12", "LV_L0"}, 1: {"LH6", "LV_L9"},
            2: {"LVB_L0", "LVB_L12"}, 3: {"LH0", "LV_L18"}}
BUCKET_TBL = {frozenset({"EE", "SE"}): {"EE4", "NE6", "SW6"},
              frozenset({"WW", "NW"}): {"WW4", "NE6", "SW6"},
              frozenset({"NE", "NN"}): {"EE4", "NE6", "WW4"},
              frozenset({"SS", "SW"}): {"EE4", "SW6", "WW4"}}


def short_wire(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|EL|ER|NL|NR|SL|SR|WL|WR)(\d)END", s)
    if m:
        return m.group(1) + m.group(2)
    m = re.match(r"^LOGIC_OUTS_?L?(\d+)$", s)          # INT_L: LOGIC_OUTS_L0；INT_R: LOGIC_OUTS0
    if m:
        return "L" + m.group(1)
    m = re.match(r"^LV(B?)_?L?(\d+)$", s)              # INT_L: LV_L0 / LVB_L0；INT_R: LV0
    if m:
        return "LV" + ("B" if m.group(1) else "") + "_L" + m.group(2)
    return s


def beg_variant_cols(fname, sources):
    """32 个 BEG 变体族的列归属（只吃名字）：返回 [C0,C1,C2,C3]；不可套用返回 None。

    规则：C0/C1 = 6 条 len2 按「轴 vs 斜」3+3，方向位 b(D)=1 的族（EE/NE/WW/SW）轴进 C1；
         LOGIC_OUTS 同分组：{L_i,L_i+4} 与 {L_i+8,L_i+12} 分列，L≥16 的两格恒 C3（i 与 (i+2)%4）；
         C2 = 方向桶给出的 3 条长距离线 + 该族序号决定的 2 条长线；C3 = 余下 3 条 + C3 的两格逻辑。
    """
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)BEG(\d)$", fname)
    if not m:
        return None
    D, idx = m.group(1), int(m.group(3))
    pool = {short_wire(s) for s in sources}
    len2 = {x for x in pool if re.match(r"^[A-Z]{2}2$", x)}
    hi = {x for x in pool if re.match(r"^[A-Z]{2}[46]$", x) and not x.startswith(("LH", "LV"))}
    if len(len2) != 6 or len(hi) != 6:
        return None
    ax = {x for x in len2 if x[:2] in AXIS2}
    dg = len2 - ax
    g0 = {"L%d" % (i + idx) for i in (0, 4)}
    g1 = {"L%d" % (i + idx) for i in (8, 12)}
    l3 = {"L%d" % (16 + (idx + 2) % 4 + 4 * k) for k in (0, 1)}
    c0 = (dg | g0) if D in FLIP2 else (ax | g1)
    c1 = (ax | g1) if D in FLIP2 else (dg | g0)
    want = next((v for k, v in BUCKET_TBL.items() if D in k), set())
    return [c0, c1, (hi & want) | LONG_TBL[idx], (hi - want) | l3]


def split_sides(cells):
    """按两端点度数为 cell 分类：返回 (sideA, sideB)；A = 大度数一侧。"""
    deg = collections.Counter()
    for cs in cells.values():
        for c in cs:
            deg[c] += 1
    if len(deg) != 9:
        return None
    hi = max(deg.values())
    lo = min(deg.values())
    A = {n for n in deg if deg[n] == hi}
    B = {n for n in deg if deg[n] == lo}
    if len(A) * len(B) != 20 and len(A) * len(B) != 24:
        return None
    return A, B


def analyse(fam):
    """把每个族拆成 (方向令牌→组, 线类→列)，并统计规则一致性。"""
    mux, beg, other = {}, {}, {}
    for f, d in fam.items():
        cells = {s: sorted(cs) for s, cs in d.items()}
        n = len(cells)
        if n == 24:
            # mux 侧：用帧几何分解（行帧 16..21、码帧 22..25），不看度数
            try:
                import gen_mux
                dec = gen_mux.decompose({s: set(cs) for s, cs in cells.items()})
            except Exception:
                dec = None
            if dec is None:
                other[f] = "帧几何不符"
                continue
            slots, b0, p = dec
            rows = {16 + r for r in range(6)}
            codes = {25 - i for i in range(4)}
            mux[f] = {"cells": cells, "A": codes, "B": rows, "col": codes, "row": rows,
                      "slots": slots}
            continue
        if n == 20:
            sp = split_sides(cells)
            if sp is None:
                other[f] = "度数结构异常"
                continue
            A, B = sp
            if len(A) * len(B) != n:
                other[f] = f"{len(A)}x{len(B)}"
                continue
            rec = {"cells": cells, "A": A, "B": B}
            # 哪一侧是「列/码」：mux 侧码侧 4 个节点、行侧 6；BEG 侧 4×5
            if len(A) < len(B):
                rec["col"], rec["row"] = A, B
            else:
                rec["col"], rec["row"] = B, A
            (mux if n == 24 else beg)[f] = rec
        else:
            other[f] = f"{n} 源"
    return mux, beg, other


def check(recs, col_key, row_key, allow_col_merge=()):
    """返回 (纯定律族数, 需回落表族数, 明细)。"""
    pure, need, detail = 0, 0, []
    for f, r in recs.items():
        if "slots" in r:                       # 已反解出 (行, 列) 的族
            c2k, r2k = collections.defaultdict(set), collections.defaultdict(set)
            for s, (row_i, col_i) in r["slots"].items():
                c2k[col_key(s)].add(col_i)
                r2k[row_key(s)].add(row_i)
            bad = [k for k, v in c2k.items() if len(v) > 1]
            if bad and allow_col_merge:
                bad = [k for k in bad if k not in allow_col_merge]
            badr = [k for k, v in r2k.items() if len(v) > 1 and k not in ("LOGIC", "EXTRA")]
            if not bad and not badr:
                pure += 1
            else:
                need += 1
                detail.append((f, "列" if bad else "", "行" if badr else ""))
            continue
        cells, col, row = r["cells"], r["col"], r["row"]
        c2k, r2k = collections.defaultdict(set), collections.defaultdict(set)
        ok = True
        for s, cs in cells.items():
            c = [x for x in cs if x in col]
            w = [x for x in cs if x in row]
            if len(c) != 1 or len(w) != 1:
                ok = False
                break
            c2k[col_key(s)].add(c[0])
            r2k[row_key(s)].add(w[0])
        if not ok:
            detail.append((f, "端点不唯一"))
            need += 1
            continue
        bad = [k for k, v in c2k.items() if len(v) > 1]
        if bad and allow_col_merge:
            bad = [k for k in bad if k not in allow_col_merge]
        badr = [k for k, v in r2k.items() if len(v) > 1 and k not in ("LOGIC", "EXTRA")]
        if not bad and not badr:
            pure += 1
        else:
            need += 1
            detail.append((f, "列" if bad else "", "行" if badr else ""))
    return pure, need, detail


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--json")
    ap.add_argument("--tile", default="INT_L")
    a = ap.parse_args()
    fam = load(tile=a.tile)
    mux, beg, other = analyse(fam)

    # mux：线类 ↔ 列码 —— axis/diag 占 {1,2}、rlineL/rlineR 占 {7,11}，对内标签逐族互换
    mux_pure = mux_need = 0
    mux_det = []
    pairs = {"axis": {1, 2}, "diag": {1, 2}, "rlineL": {7, 11}, "rlineR": {7, 11}}
    for f, r in mux.items():
        c2k = collections.defaultdict(set)
        for s, (row_i, col_i) in r["slots"].items():
            k = line_class(s)
            if k in ("bounce", "logic", "other", "longL"):
                continue
            c2k[k].add(col_i)
        ok = True
        for k, v in c2k.items():
            if len(v) != 1 or not (v <= pairs[k]):
                ok = False
        if len(c2k.get("axis", ())) and len(c2k.get("diag", ())) and c2k["axis"] == c2k["diag"]:
            ok = False
        if len(c2k.get("rlineL", ())) and len(c2k.get("rlineR", ())) and c2k["rlineL"] == c2k["rlineR"]:
            ok = False
        if ok:
            mux_pure += 1
        else:
            mux_need += 1
            mux_det.append((f, "线类<->码不唯一"))
    beg_pure, beg_need, beg_det = check(beg, geo_class, dir_token,
                                       allow_col_merge=("line", "logic"))

    # BEG 变体 32 族：用「方向桶 + 长线表」重建 4 列归属
    var_ok, var_tot, var_bad = 0, 0, []
    for f, r in beg.items():
        pred = beg_variant_cols(f, r["cells"].keys())
        if pred is None:
            continue
        var_tot += 1
        act = [{short_wire(s) for s, cs in r["cells"].items() if c in cs} for c in sorted(r["col"])]
        if sorted(map(sorted, act)) == sorted(map(sorted, [p for p in pred if p])):
            var_ok += 1
        else:
            var_bad.append(f)
    if var_tot:
        beg_pure, beg_need = beg_pure + var_ok, beg_need - var_ok

    out = {
        "families": len(fam),
        "mux_24": {"families": len(mux), "pure_law": mux_pure, "need_table": mux_need,
                   "examples": mux_det[:5]},
        "beg_20": {"families": len(beg), "pure_law": beg_pure, "need_table": beg_need,
                   "variant_rule": {"tried": var_tot, "ok": var_ok, "bad": var_bad[:5]},
                   "examples": beg_det[:5]},
        "other": {"families": len(other), "detail": dict(list(other.items())[:8])},
        "rules": {
            "mux_col": "线类 → 码（4 类：axis/diag/rline/longL）",
            "mux_row": "方向令牌 → 行（每族置换，16 种配置）",
            "beg_col": "几何类别 → 列（line 与 logic 共列）",
            "beg_row": "方向令牌 → 组（96/96）",
        },
    }
    print(f"族数 {len(fam)}：24 源 {len(mux)} / 20 源 {len(beg)} / 其它 {len(other)}")
    print(f"[mux] 纯定律 {mux_pure}/{len(mux)}，需回落 {mux_need}")
    print(f"[BEG] 纯定律 {beg_pure}/{len(beg)}，需回落 {beg_need}"
          f"（其中变体规则 {var_ok}/{var_tot}）")
    print(f"[其它] {len(other)} 族：{dict(list(other.items())[:4])}")
    cells = sum(len({c for cs in d.values() for c in cs}) for d in fam.values())
    feats = sum(len(d) for d in fam.values())
    bits = sum(len(cs) for d in fam.values() for cs in d.values())
    print(f"规模：{feats} 个 feature、{cells} 个不同 cell、{bits} 条 (feature,cell) 记录")
    if a.json:
        io.open(a.json, "w", encoding="utf-8").write(json.dumps(out, ensure_ascii=False, indent=1))
        print("写出", a.json)


if __name__ == "__main__":
    main()
