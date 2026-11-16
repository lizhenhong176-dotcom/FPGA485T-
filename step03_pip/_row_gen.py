# -*- coding: utf-8 -*-
"""_row_gen.py —— 行序生成律（T89 选项 3 收尾）

口径（与 T88 / §167 一致，不可换序）：
  方向线 16 条 = DIAG[NE,NW,SE,SW] ORTH[NN,EE,WW,SS] R[NR,ER,WR,SR] L[NL,EL,WL,SL]
  row = frame_off - 16（只取 frame_off ∈ 16..19 的 sense 单元）
  编码 = 四类各拼 4 位行号，唯一键 j = (pair//2) % 8 与 primary ∈ {P,S}
  primary=S 的编码 = primary=P 的编码逐位 +2 mod 4

生成模型（只存 4 个基置换 + 5 个步进置换 + 1 个类别对比特，不存 8 张表）：
  p0: DIAG (2,0,3,1)  ORTH (2,3,0,1)  R (2,0,1,3)  L (3,1,0,2)
  p_{j+1} = g_j ∘ p_j,  (a∘b)(k) = a[b[k]]
  class ∈ {DIAG,ORTH}: g = [r3, rho, r3, e,   r3, rho, r3]
  class ∈ {R,L}:        g = [r,  rho, r,  X2,  r,  rho, r ]
  r=(1,2,3,0) rho=(3,2,1,0) e=(0,1,2,3) r3=(3,0,1,2) X2=(3,2,0,1)

数据（只读）：E:\\v7work\\model\\v7_law.sqlite  law_cells
判据：与 law_cells 全量对拍 2,048 条方向线 feature（64 族 × 16 条 × 2 侧），
      missing=0 且 extra=0；另报 p7 vs p0、类别对与线长类别的对应。

用法：python step03_pip/_row_gen.py
"""
import collections
import sqlite3
import sys

DB = r"E:\v7work\model\v7_law.sqlite"
ORDER = [("DIAG", ["NE", "NW", "SE", "SW"]), ("ORTH", ["NN", "EE", "WW", "SS"]),
         ("R", ["NR", "ER", "WR", "SR"]), ("L", ["NL", "EL", "WL", "SL"])]

P0 = {"DIAG": (2, 0, 3, 1), "ORTH": (2, 3, 0, 1), "R": (2, 0, 1, 3), "L": (3, 1, 0, 2)}
R = (1, 2, 3, 0)
RHO = (3, 2, 1, 0)
E = (0, 1, 2, 3)
X2 = (3, 2, 0, 1)


def comp(a, b):
    """(a∘b)(k) = a[b[k]]"""
    return tuple(a[b[k]] for k in range(4))


R3 = comp(comp(R, R), R)
STEPS = {"DIAG_ORTH": [R3, RHO, R3, E, R3, RHO, R3],
         "R_L": [R, RHO, R, X2, R, RHO, R]}


def gen_perms():
    """class -> [p_0 .. p_7]"""
    out = {}
    for cls, p0 in P0.items():
        key = "DIAG_ORTH" if cls in ("DIAG", "ORTH") else "R_L"
        seq = [p0]
        for g in STEPS[key]:
            seq.append(comp(g, seq[-1]))
        out[cls] = seq
    return out


def shift2(p):
    """primary=S：行号逐位 +2 mod 4"""
    return tuple((v + 2) % 4 for v in p)


def family_params(f):
    """族名 -> (j, primary, 全局 mux 序号 g)；H4 闭式，不查表。"""
    if f.startswith("IMUX"):
        i = int("".join(ch for ch in f if ch.isdigit()))
        gg = i // 8
        pair = [0, 2, 2, 4, 4, 6][gg] + 8 * (i % 4)
        prim = "S" if gg % 2 == 0 else "P"
        gidx = i
    elif f.startswith("BYP_ALT"):
        k = int("".join(ch for ch in f if ch.isdigit()))
        pair = [6, 14, 6, 14, 22, 30, 22, 30][k]
        prim = "S"
        gidx = 48 + k
    else:
        k = int("".join(ch for ch in f if ch.isdigit()))
        pair = [0, 16, 16, 24, 8, 8, 24, 0][k]
        prim = "P"
        gidx = 56 + k
    return (pair // 2) % 8, prim, gidx // 8


def main():
    con = sqlite3.connect("file:%s?mode=ro" % DB, uri=True)
    perms = gen_perms()

    # ---- 1. 32 个置换与 p7 判据 ----
    print("j  DIAG ORTH R  L")
    for j in range(8):
        print("%d  %-4s %-4s %-4s %-4s" % (
            j, *["".join(map(str, perms[c][j])) for c, _ in ORDER]))
    p7 = {c: perms[c][7] == perms[c][0] for c, _ in ORDER}
    print("p7 == p0:", p7, "=> 周期 8 成立？", all(p7.values()))

    # ---- 2. 全量对拍 ----
    miss = extra = total = 0
    examples = []
    collen = collections.Counter()
    for side in ("INT_L", "INT_R"):
        rows = con.execute("select family,src_wire,frame_off,parity from law_cells "
                           "where tile_type=? and sense=1", (side,)).fetchall()
        cells = collections.defaultdict(lambda: collections.defaultdict(set))
        for fam, src, fo, par in rows:
            if 16 <= fo <= 21:
                cells[fam][src].add((fo, par))
        for fam, smap in cells.items():
            j, prim, g = family_params(fam)
            col_of = {"DIAG": 1 if g % 2 == 0 else 2, "ORTH": 2 if g % 2 == 0 else 1,
                      "R": 7 if g % 2 == 0 else 11, "L": 11 if g % 2 == 0 else 7}
            for cls, members in ORDER:
                p = perms[cls][j]
                if prim == "S":
                    p = shift2(p)
                for pos, pre in enumerate(members):
                    srcs = [s for s in smap if s[:2] == pre]
                    if len(srcs) != 1:
                        continue
                    s = srcs[0]
                    want_row = p[pos]
                    got = {fo - 16 for fo, par in smap[s]}
                    total += 1
                    if len(got) != 1 or want_row not in got:
                        miss += 1
                        if len(examples) < 8:
                            examples.append((side, fam, s, want_row, sorted(got)))
                    collen[cls] += 1
    print("全量对拍：%d 条方向线 feature，不符 %d" % (total, miss))
    for e in examples:
        print("   ", e)

    # ---- 3. 类别对 vs 线长类别（列码实测）----
    cc = collections.defaultdict(set)
    for side in ("INT_L", "INT_R"):
        rows = con.execute("select family,src_wire,frame_off from law_cells "
                           "where tile_type=? and sense=1 and frame_off between 22 and 25",
                           (side,)).fetchall()
        per_src = collections.defaultdict(int)
        for fam, src, fo in rows:
            per_src[(fam, src)] |= 1 << {25: 0, 24: 1, 23: 2, 22: 3}[fo]
        for (fam, src), code in per_src.items():
            cls = {"NE": "DIAG", "NW": "DIAG", "SE": "DIAG", "SW": "DIAG",
                   "NN": "ORTH", "SS": "ORTH", "EE": "ORTH", "WW": "ORTH",
                   "NR": "R", "SR": "R", "ER": "R", "WR": "R",
                   "NL": "L", "SL": "L", "EL": "L", "WL": "L"}.get(src[:2])
            if cls:
                cc[cls].add(code)
    print("实测列码集合（按类）：", {k: sorted(v) for k, v in cc.items()})
    double_ok = cc["DIAG"] <= {1, 2} and cc["ORTH"] <= {1, 2}
    single_ok = cc["R"] <= {7, 11} and cc["L"] <= {7, 11}
    print("DIAG/ORTH ⊂ {1,2}(DOUBLE):", double_ok, " R/L ⊂ {7,11}(SINGLE):", single_ok)

    ok = (total == 2048 and miss == 0 and double_ok and single_ok)
    print("RESULT:", "PASS" if ok else "FAIL", "(%d/%d)" % (total - miss, total))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
