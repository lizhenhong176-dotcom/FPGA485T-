# -*- coding: utf-8 -*-
"""row_law.py —— mux 区行序生成律（T89 选项 1 的模型实现）

本模块只存「4 个基置换 + 5 个步进置换 + 1 个类别对比特」，不存 8/16 张表。
口径与 T88 / §167 一致：
  方向线 16 条 = DIAG[NE,NW,SE,SW] ORTH[NN,EE,WW,SS] R[NR,ER,WR,SR] L[NL,EL,WL,SL]
  row = frame_off - 16（0..3）
  primary=S 的置换 = primary=P 的置换逐位 +2 mod 4
  键 j = (pair // 2) % 8；pair 由族名闭式给出（见 family_key）

族名 -> (pair, parity, primary)：
  IMUX：pair = [0,2,2,4,4,6][i//8] + 8*(i%4)；parity=(i//4)%2；primary=S iff (i//8) 偶
  BYP_ALT<k>：pair = [6,14,6,14,22,30,22,30][k]；parity=(k//2)%2；primary=S
  FAN_ALT<k>：pair = [0,16,16,24,8,8,24,0][k]；parity=k%2；primary=P
  全局 mux 序号 gidx：IMUX=i，BYP=48+k，FAN=56+k；列码由 gidx//8 的奇偶决定

行 4/5（LOGIC/GFAN、BOUNCE）不在本律内：它们落哪一行由 gidx//8 奇偶决定，
但「哪条 LOGIC 线进哪一列」仍是逐族 residue（512 个槽位），由调用方从旧模型带入。
"""
import re

ORDER = [("DIAG", ["NE", "NW", "SE", "SW"]), ("ORTH", ["NN", "EE", "WW", "SS"]),
         ("R", ["NR", "ER", "WR", "SR"]), ("L", ["NL", "EL", "WL", "SL"])]
CLASS_OF = {p: c for c, ms in ORDER for p in ms}

# ---- 唯一的数据：4 个基置换 + 5 个步进置换 ----
P0 = {"DIAG": (2, 0, 3, 1), "ORTH": (2, 3, 0, 1), "R": (2, 0, 1, 3), "L": (3, 1, 0, 2)}
R = (1, 2, 3, 0)
RHO = (3, 2, 1, 0)
E = (0, 1, 2, 3)
X2 = (3, 2, 0, 1)


def _comp(a, b):
    """(a∘b)(k) = a[b[k]]"""
    return tuple(a[b[k]] for k in range(4))


R3 = _comp(_comp(R, R), R)
STEPS = {"A": [R3, RHO, R3, E, R3, RHO, R3],     # DIAG/ORTH
         "B": [R, RHO, R, X2, R, RHO, R]}          # R/L


def perms():
    """class -> [p_0 .. p_7]（p_j 为「成员位序 -> 行号」）"""
    out = {}
    for cls, p0 in P0.items():
        seq = [p0]
        for g in STEPS["A" if cls in ("DIAG", "ORTH") else "B"]:
            seq.append(_comp(g, seq[-1]))
        out[cls] = seq
    return out


def _num(f):
    m = re.search(r"(\d+)$", f)
    return int(m.group(1))


def family_key(family):
    """族名 -> (j, primary, gidx//8)；纯闭式，无表。"""
    k = _num(family)
    if family.startswith("IMUX"):
        g = k // 8
        pair = [0, 2, 2, 4, 4, 6][g] + 8 * (k % 4)
        prim = "S" if g % 2 == 0 else "P"
        gidx = k
    elif family.startswith("BYP_ALT"):
        pair = [6, 14, 6, 14, 22, 30, 22, 30][k]
        prim = "S"
        gidx = 48 + k
    elif family.startswith("FAN_ALT"):
        pair = [0, 16, 16, 24, 8, 8, 24, 0][k]
        prim = "P"
        gidx = 56 + k
    else:
        raise KeyError(family)
    return (pair // 2) % 8, prim, gidx // 8


def params(family):
    """族名 -> (pair, parity, primary)，供 predict 使用。"""
    k = _num(family)
    if family.startswith("IMUX"):
        g = k // 8
        return [0, 2, 2, 4, 4, 6][g] + 8 * (k % 4), (k // 4) % 2, ("S" if g % 2 == 0 else "P")
    if family.startswith("BYP_ALT"):
        return [6, 14, 6, 14, 22, 30, 22, 30][k], (k // 2) % 2, "S"
    if family.startswith("FAN_ALT"):
        return [0, 16, 16, 24, 8, 8, 24, 0][k], k % 2, "P"
    raise KeyError(family)


def col_of(family):
    """类 -> 列码（1/2/7/11）"""
    g = family_key(family)[2]
    return {"DIAG": 1 if g % 2 == 0 else 2, "ORTH": 2 if g % 2 == 0 else 1,
            "R": 7 if g % 2 == 0 else 11, "L": 11 if g % 2 == 0 else 7}


def direction_slots(family):
    """16 条方向线 -> (row, colcode)；纯律。"""
    j, prim, _ = family_key(family)
    P = perms()
    col = col_of(family)
    out = {}
    for cls, members in ORDER:
        p = P[cls][j]
        if prim == "S":
            p = tuple((v + 2) % 4 for v in p)
        for pos, pre in enumerate(members):
            out[pre] = (p[pos], col[cls])
    return out


def full_slots(family, residue):
    """24 源族 -> {src: (row, col)}：方向线用律，其余（行 4/5）沿用 residue。"""
    out = dict(residue)
    d = direction_slots(family)
    for src in out:
        pre = src[:2]
        if pre in d:
            out[src] = d[pre]
    return out
