# -*- coding: utf-8 -*-
"""独立复核 T88 的行序结构，并给出更紧的生成律。

口径（与 T88 一致）：
  方向线 16 条 = DIAG[NE,NW,SE,SW] ORTH[NN,EE,WW,SS] R[NR,ER,WR,SR] L[NL,EL,WL,SL]
  row = frame_off - 16（只取 frame_off ∈ 16..19 的 sense 单元）
  编码 = 四类各拼 4 位行号

本脚本做三件事，全部从 law_cells 原始单元重算，不读 T88 的表：
  1) 每侧 64 个 mux 族 → 有多少种不同编码、每组几个族；
  2) INT_L 与 INT_R 是否逐族同码；
  3) 16 种编码在「primary=S 时逐位 +2 mod 4」下是否两两成对（8 对）。

另外给出生成律的复核（读 T88 的 8 张 P 表，只作对拍）：
  以每类的 p0 为基，p_{j+1} = g_j ∘ p_j，且
  class ∈ {DIAG,ORTH}:  g = [r^3, rho, r^3, e,   r^3, rho, r^3]
  class ∈ {R,L}:        g = [r,   rho, r,   X2,  r,   rho, r  ]
  其中 r=(1,2,3,0) rho=(3,2,1,0) e=(0,1,2,3) X2=(3,2,0,1)
"""
import collections
import sqlite3
import sys

DB = r"E:\v7work\model\v7_law.sqlite"
ORDER = [["NE", "NW", "SE", "SW"], ["NN", "EE", "WW", "SS"],
         ["NR", "ER", "WR", "SR"], ["NL", "EL", "WL", "SL"]]

T88_P = {0: "2031 2301 2013 3102", 1: "1320 1230 3120 0213",
         2: "2013 2103 0213 3120", 3: "1302 1032 1320 0231",
         4: "1302 1032 2103 3012", 5: "0231 0321 3210 0123",
         6: "3102 3012 0123 3210", 7: "2031 2301 1230 0321"}


def comp(a, b):
    return tuple(a[b[k]] for k in range(4))


def inv(p):
    r = [0] * 4
    for k, v in enumerate(p):
        r[v] = k
    return tuple(r)


def enc(con, side, fam):
    rows = con.execute("select src_wire,frame_off from law_cells "
                       "where tile_type=? and family=?", (side, fam)).fetchall()
    on = collections.defaultdict(set)
    for s, fo in rows:
        if 16 <= fo <= 19:
            on[s[:2]].add(fo - 16)
    out = []
    for cls in ORDER:
        for p in cls:
            if len(on[p]) != 1:
                return None
        out.append("".join(str(next(iter(on[p]))) for p in cls))
    return " ".join(out)


def fams(con, side):
    F = [r[0] for r in con.execute(
        "select distinct family from law_cells where tile_type=?", (side,))]
    return [f for f in F if "IMUX" in f or f.startswith("BYP_ALT")
            or f.startswith("FAN_ALT")]


def main():
    con = sqlite3.connect(DB)
    encs = {}
    for side in ("INT_L", "INT_R"):
        E = {}
        for f in fams(con, side):
            v = enc(con, side, f)
            if v is not None:
                E[f] = v
        encs[side] = E
        cl = collections.defaultdict(list)
        for f, v in E.items():
            cl[v].append(f)
        hist = collections.Counter(len(v) for v in cl.values())
        print("%s families=%d distinct=%d size-hist=%s"
              % (side, len(E), len(cl), dict(hist)))
        print("   closed under +2 mod 4:", all(
            " ".join("".join(str((int(c) + 2) % 4) for c in part)
                     for part in e.split()) in cl for e in cl))

    A, B = encs["INT_L"], encs["INT_R"]
    same = sum(1 for f in A if B.get(f.replace("_L", "")) == A[f])
    print("L vs R identical: %d/%d" % (same, len(A)))

    S = set(A.values())
    print("distinct encodings (L):", len(S))
    pairs = {}
    for e in S:
        p2 = " ".join("".join(str((int(c) + 2) % 4) for c in part)
                      for part in e.split())
        pairs.setdefault(min(e, p2), set()).add(e)
    print("involutive P/S pairs:", len(pairs),
          "sizes:", sorted({len(v) for v in pairs.values()}))

    # ---- 生成律复核（对 T88 的 8 张 P 表）----
    P = {j: [tuple(int(c) for c in part) for part in T88_P[j].split()]
         for j in T88_P}
    r = (1, 2, 3, 0)
    rho = (3, 2, 1, 0)
    e_ = (0, 1, 2, 3)
    r3 = comp(comp(r, r), r)
    X2 = (3, 2, 0, 1)
    ok = True
    for cls in range(4):
        A_ = r3 if cls in (0, 1) else r
        X_ = e_ if cls in (0, 1) else X2
        steps = [A_, rho, A_, X_, A_, rho, A_]
        seq = [P[0][cls]]
        for g in steps:
            seq.append(comp(g, seq[-1]))
        good = all(seq[j] == P[j][cls] for j in range(8))
        ok &= good
        print("  class %d reconstruct 8/8: %s   p7==p0: %s"
              % (cls, good, seq[7] == seq[0]))
    print("generator rule: 32/32 =", ok)
    print("base p0:", [P[0][c] for c in range(4)])
    print("r=%s rho=%s e=%s r3=%s X2=%s" % (r, rho, e_, r3, X2))
    return 0 if ok and same == len(A) and len(S) == 16 else 1


if __name__ == "__main__":
    sys.exit(main())
