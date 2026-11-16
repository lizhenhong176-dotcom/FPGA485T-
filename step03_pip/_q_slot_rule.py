# -*- coding: utf-8 -*-
"""G6：验两条从数据里冒出来的规律，并算「生成一条族表」需要多少自由比特。
R1: 斜线 NE/NW/SE/SW 的行号 = 同名主轴方向 N/W/E/S 的行号（族内一致）。
R2: 非方位源（LOGIC_OUTS/BOUNCE/GFAN）只占 row 4/5，且每行每码恰一个。
"""
import sqlite3, collections, re, itertools, math

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
rows = con.execute("select family, src_wire, frame_off from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in rows:
    fam[f][s].add(fo)

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

AX = {"EE": "E", "WW": "W", "NN": "N", "SS": "S"}
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}   # 斜线归属的主轴方向
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}

def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return None, None

grids = []
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if len(d) != 24 or any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    grids.append((f, slots))
print("可纳入的 24 源族：", len(grids))

r1_ok = 0
r1_bad = []
r2_ok = 0
axes = collections.Counter()
lines = collections.Counter()
for f, slots in grids:
    bycls = collections.defaultdict(dict)
    extra = []
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag:
            bycls[tag][dirn] = (r, c)
        else:
            extra.append((s, r, c))
    # R1
    ok = True
    for dirn, (r, c) in bycls.get("diag", {}).items():
        if dirn not in bycls.get("axis", {}) or bycls["axis"][dirn][0] != r:
            ok = False
    if ok:
        r1_ok += 1
    else:
        r1_bad.append(f)
    # 记录自由度
    for tag, cnt in (("axis", axes), ("longL", lines), ("rline", lines)):
        m = bycls.get(tag, {})
        if len(m) == 4:
            cnt[(tag, tuple(sorted((k, v[0]) for k, v in m.items())))] += 1
    # R2
    cells = [(r, c) for _, r, c in extra]
    if len(extra) == 8 and len(set(cells)) == 8 and {r for r, _ in cells} <= {4, 5}:
        r2_ok += 1

print(f"R1（斜线行 = 主轴行）：{r1_ok}/{len(grids)} 成立；反例 {r1_bad[:3]}")
print(f"R2（8 个非方位源占满 row4/5 × 4 码）：{r2_ok}/{len(grids)}")

kinds = {(tag, perm) for (tag, perm) in axes} | {(tag, perm) for (tag, perm) in lines}
per_kind = collections.Counter(tag for tag, _ in kinds)
print("\n各类方向→行 的排列种类：", dict(per_kind),
      "| 理论值 4!=24")

# 自由比特估算
bits_axis = math.log2(max(1, per_kind["axis"]))
bits_long = math.log2(max(1, per_kind["longL"]))
bits_rline = math.log2(max(1, per_kind["rline"]))
bits = 2 + bits_axis + bits_long + bits_rline
print(f"每族自由比特 ≈ 2(码归属) + {bits_axis:.2f}(axis) + {bits_long:.2f}(longL) + {bits_rline:.2f}(rline) = {bits:.2f} bit")
print(f"24 源族总数 64 → 全表自由比特 ≈ {64*bits:.0f} bit；原始表规模 24×64 = 1,536 条")
