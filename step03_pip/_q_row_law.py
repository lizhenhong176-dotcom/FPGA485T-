#!/usr/bin/env python3
"""_q_row_law.py —— mux 区「行序」的结构归属复核（P1）

背景（STATUS.md §161 / PIP_ADDRESS_ENCODING_LAW §5.1）：
    类内成员序（每族 16 条方向线落哪一行）原判为「数据」，48 族 36 种映射。

本脚本用 law_cells 实测数据检验三个新命题：
    H1  「(类, 方向) -> 行」的映射只取决于 (位对序号在 16 位半区内的位置 j, primary)，
        与族名、parity、所在半区无关。
    H2  映射表是 16 个键 -> 16 个编码的双射；INT_L 与 INT_R 逐项相同。
    H3  primary=S 的行号 = primary=P 的行号 XOR 2（即行号 +2 mod 4）。

判据：逐 (family, source) 重新生成 (row, colcode)，与 law_cells 实测比对，
      missing=0 且 extra=0 才算成立（集合级，不抽样）。

用法：
    python step03_pip/_q_row_law.py            # 复核 + 打印表
"""
import collections
import os
import sqlite3
import re
import sys

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")

CLASS = {"NE": "DIAG", "NW": "DIAG", "SE": "DIAG", "SW": "DIAG",
         "NN": "ORTH", "SS": "ORTH", "EE": "ORTH", "WW": "ORTH",
         "NR": "R", "SR": "R", "ER": "R", "WR": "R",
         "NL": "L", "SL": "L", "EL": "L", "WL": "L"}
CANON = {"DIAG": ["NE", "NW", "SE", "SW"], "ORTH": ["NN", "EE", "WW", "SS"],
         "R": ["NR", "ER", "WR", "SR"], "L": ["NL", "EL", "WL", "SL"]}
MUX_PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")
COL_FRAMES = (25, 24, 23, 22)


def load(tt):
    con = sqlite3.connect("file:%s?mode=ro" % LAW_DB, uri=True)
    cells = collections.defaultdict(lambda: collections.defaultdict(set))
    for fam, src, fo, bit, par in con.execute(
            "select family,src_wire,frame_off,bit,parity from law_cells "
            "where tile_type=? and sense=1", (tt,)):
        cells[fam][src].add((fo, bit, par))
    con.close()
    return cells


def fam_index(f):
    return int(re.search(r"(\d+)$", f).group(1))


def params(cs):
    """从一族的全部 cell 反推 (pair, parity, primary)。"""
    allc = set().union(*cs.values())
    parities = {p for _, _, p in allc}
    bset = sorted({b for _, b, _ in allc})
    colbits = {b for fo, b, _ in allc if 22 <= fo <= 25}
    return bset[0], parities.pop(), ("P" if colbits == {bset[0]} else "S")


def slots(cs):
    """source -> (row, colcode)；只取 mux 区结构完整的族。"""
    out = {}
    for src, cells in cs.items():
        rows = {fo for fo, b, p in cells if 16 <= fo <= 21}
        if len(rows) != 1:
            return None
        cc = 0
        for i, f in enumerate(COL_FRAMES):
            if any(fo == f for fo, b, p in cells):
                cc |= 1 << i
        out[src] = (rows.pop() - 16, cc)
    return out


def encoding(sl):
    pref = {s[:2]: v for s, v in sl.items()}
    return " ".join("".join(str(pref[k][0]) for k in CANON[cl])
                    for cl in ("DIAG", "ORTH", "R", "L"))


def main():
    data = {tt: load(tt) for tt in ("INT_L", "INT_R")}
    fams = {tt: [f for f in data[tt] if f.startswith(MUX_PREFIX)] for tt in data}

    # ---- 1. 每族的 (pair, parity, primary, encoding) ----
    info = {}
    for tt in data:
        for f in fams[tt]:
            sl = slots(data[tt][f])
            if sl is None:
                sys.exit("族 %s/%s 不符合 mux 区结构" % (tt, f))
            pair, par, prim = params(data[tt][f])
            info[(tt, f)] = (pair, par, prim, encoding(sl), sl)

    # ---- 1b. H4: 族名 -> (pair, parity, primary) 的分配公式 ----
    base_imux = [0, 2, 2, 4, 4, 6]
    base_byp = [6, 14, 6, 14, 22, 30, 22, 30]
    base_fan = [0, 16, 16, 24, 8, 8, 24, 0]
    bad4 = []
    n4 = 0
    for tt in data:
        for f in fams[tt]:
            k = fam_index(f)
            if f.startswith("IMUX"):
                g = k // 8
                pred = (base_imux[g] + 8 * (k % 4), (k // 4) % 2, "S" if g % 2 == 0 else "P")
            elif f.startswith("BYP_ALT"):
                pred = (base_byp[k], (k // 2) % 2, "S")
            else:
                pred = (base_fan[k], k % 2, "P")
            got = info[(tt, f)][:3]
            n4 += 1
            if pred != got:
                bad4.append((tt, f, pred, got))
    print("H4     族名 -> (pair,parity,primary)：%d 族，不符 %d %s"
          % (n4, len(bad4), bad4[:3]))
    ok4 = not bad4

    # ---- 2. H1/H2: key -> encoding ----
    table = collections.defaultdict(set)
    for (tt, f), (pair, par, prim, enc, sl) in info.items():
        table[((pair // 2) % 8, prim)].add(enc)
    conflicts = {k: v for k, v in table.items() if len(v) > 1}
    print("H1/H2  键数 %d，编码数 %d，冲突 %d"
          % (len(table), len({v for s in table.values() for v in s}), len(conflicts)))
    for k in sorted(table):
        print("   j=%d %s  %s" % (k[0], k[1], sorted(table[k])[0]))
    if conflicts:
        print("   CONFLICT:", conflicts)
    ok12 = not conflicts and len(table) == 16 and \
        len({v for s in table.values() for v in s}) == 16

    # ---- 3. H2b: INT_L vs INT_R 同键同编码 ----
    side = collections.defaultdict(dict)
    for (tt, f), (pair, par, prim, enc, sl) in info.items():
        side[tt][((pair // 2) % 8, prim)] = enc
    diff = [k for k in side["INT_L"] if side["INT_L"][k] != side["INT_R"].get(k)]
    print("H2b    INT_L vs INT_R 同键不同编码：%d 个键 %s" % (len(diff), diff))
    ok2b = not diff

    # ---- 4. H3: S = P XOR 2 ----
    bad3 = []
    for k in sorted(table):
        j, prim = k
        if prim != "S":
            continue
        p_enc = side["INT_L"].get((j, "P"))
        s_enc = sorted(table[k])[0]
        if p_enc is None:
            continue
        want = " ".join("".join(str((int(c) + 2) % 4) for c in part)
                        for part in p_enc.split(" "))
        if want != s_enc:
            bad3.append((j, p_enc, s_enc, want))
    print("H3     primary S = P ⊕ 2：%s（反例 %d）" % ("成立" if not bad3 else "不成立", len(bad3)))
    for x in bad3:
        print("   ", x)
    ok3 = not bad3

    # ---- 5. 全量再生：16 方向线 (row, colcode) vs law_cells ----
    miss = extra = total = 0
    misses = []
    for tt in data:
        for f in fams[tt]:
            pair, par, prim, enc, sl = info[(tt, f)]
            j = (pair // 2) % 8
            base = sorted(table[(j, prim)])[0].split(" ")
            # 列码：DIAG/ORTH 由全局 mux 序号 g=i//8 的奇偶二选一，R/L 同理。
            # 全局序号：IMUX 0..47、BYP_ALT 48..55、FAN_ALT 56..63
            i = fam_index(f)
            if f.startswith("BYP_ALT"):
                i += 48
            elif f.startswith("FAN_ALT"):
                i += 56
            g = i // 8
            col_of = {"DIAG": 1 if g % 2 == 0 else 2,
                      "ORTH": 2 if g % 2 == 0 else 1,
                      "R": 7 if g % 2 == 0 else 11,
                      "L": 11 if g % 2 == 0 else 7}
            for ci, cl in enumerate(("DIAG", "ORTH", "R", "L")):
                for mi, pre in enumerate(CANON[cl]):
                    srcs = [s for s in sl if s[:2] == pre]
                    if len(srcs) != 1:
                        continue
                    s = srcs[0]
                    total += 1
                    pred = (int(base[ci][mi]), col_of[cl])
                    if pred != sl[s]:
                        miss += 1
                        if len(misses) < 10:
                            misses.append((tt, f, s, pred, sl[s]))
    print("R1     16 方向线全量再生：%d 条，不符 %d" % (total, miss))
    for m in misses:
        print("   ", m)

    # ---- 6. R2 跨侧留出：只用 INT_L 建表，预测 INT_R ----
    train = collections.defaultdict(set)
    for tt in ("INT_L",):
        for f in fams[tt]:
            pair, par, prim, enc, sl = info[(tt, f)]
            train[((pair // 2) % 8, prim)].add(enc)
    train_tab = {k: sorted(v)[0].split(" ") for k, v in train.items() if len(v) == 1}
    miss2 = total2 = 0
    ex2 = []
    for f in fams["INT_R"]:
        pair, par, prim, enc, sl = info[("INT_R", f)]
        base = train_tab[((pair // 2) % 8, prim)]
        i = fam_index(f)
        if f.startswith("BYP_ALT"):
            i += 48
        elif f.startswith("FAN_ALT"):
            i += 56
        g = i // 8
        col_of = {"DIAG": 1 if g % 2 == 0 else 2, "ORTH": 2 if g % 2 == 0 else 1,
                  "R": 7 if g % 2 == 0 else 11, "L": 11 if g % 2 == 0 else 7}
        for ci, cl in enumerate(("DIAG", "ORTH", "R", "L")):
            for mi, pre in enumerate(CANON[cl]):
                srcs = [s for s in sl if s[:2] == pre]
                if len(srcs) != 1:
                    continue
                total2 += 1
                if (int(base[ci][mi]), col_of[cl]) != sl[srcs[0]]:
                    miss2 += 1
                    if len(ex2) < 5:
                        ex2.append((f, srcs[0], (int(base[ci][mi]), col_of[cl]), sl[srcs[0]]))
    print("R2     INT_L 建表 -> 预测 INT_R：%d 条，不符 %d" % (total2, miss2))
    for m in ex2:
        print("   ", m)

    print("\n判定：H4=%s  H1/H2=%s  H2b=%s  H3=%s  R1=%s  R2=%s"
          % ("PASS" if ok4 else "FAIL",
             "PASS" if ok12 else "FAIL", "PASS" if ok2b else "FAIL",
             "PASS" if ok3 else "FAIL", "PASS" if miss == 0 else "FAIL",
             "PASS" if miss2 == 0 else "FAIL"))
    return 0 if (ok4 and ok12 and ok2b and ok3 and miss == 0 and miss2 == 0) else 1


if __name__ == "__main__":
    sys.exit(main())
