# -*- coding: utf-8 -*-
"""G1：列码 c 是否由源线的「线类」决定？行号 r 是否是每族独立的排列？"""
import sqlite3, collections, re

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)

TT = "INT_L"
rows = con.execute(
    "select family, src_wire, frame_off, bit, parity from law_cells "
    "where tile_type=? and sense=1", (TT,)).fetchall()

fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
    # 同时记录位以便判断行列格
cellcount = collections.Counter(c for d in fam.values() for cells in d.values() for c in cells)

def slot(cells):
    r = None
    code = 0
    for (fo, p, b) in cells:
        if fo in (16, 17, 18, 19, 20, 21) and cellcount[(fo, p, b)] == 4:
            r = fo - 16
        elif fo in (22, 23, 24, 25):
            code |= 1 << (25 - fo)
    return (r, code)

CLASS = [
    ("axis", r"^(EE|WW|NN|SS)\d"),
    ("diag", r"^(NE|NW|SE|SW)\d"),
    ("longL", r"^(NL|SL|EL|WL)\d"),
    ("rline", r"^(NR|SR|ER|WR)\d"),
    ("logic", r"^LOGIC_OUTS"),
    ("bounce", r"^(BYP_BOUNCE|FAN_BOUNCE|FAN\d|BYP_ALT\d*$)"),
    ("gfan", r"^GFAN\d"),
    ("imux", r"^IMUX"),
    ("other", r"."),
]
def klass(s):
    for k, pat in CLASS:
        if re.match(pat, s):
            return k
    return "other"

# 只看能解出整数槽位的族（24/20/16 源，槽位 6x4 或 5x4）
ok_fam = 0
c_is_fn_of_class = 0
c_violations = []
r_perm_ok = 0
row_used = collections.Counter()
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None for v in slots.values()):
        continue
    codes = {v[1] for v in slots.values()}
    if codes - {1, 2, 7, 11}:
        continue
    ok_fam += 1
    # 每个线类是否只落在一个 code 上
    byc = collections.defaultdict(set)
    for s, (r, c) in slots.items():
        byc[klass(s)].add(c)
    bad = {k: v for k, v in byc.items() if len(v) > 1}
    if not bad:
        c_is_fn_of_class += 1
    else:
        c_violations.append((f, bad))
    # 行号：同一 code 内是否为 0..n-1 的排列
    per = collections.defaultdict(list)
    for s, (r, c) in slots.items():
        per[c].append(r)
    if all(sorted(v) == list(range(len(v))) for v in per.values()):
        r_perm_ok += 1
        for v in per.values():
            row_used[len(v)] += 1

print(f"可解槽位族：{ok_fam}")
print(f"c = f(线类) 成立：{c_is_fn_of_class}/{ok_fam} = {100.0*c_is_fn_of_class/ok_fam:.1f}%")
print(f"r 在每列内是 0..n-1 排列：{r_perm_ok}/{ok_fam} = {100.0*r_perm_ok/ok_fam:.1f}%")
print("每列行数分布：", dict(row_used))
print("\n反例（前 5 个）：")
for f, bad in c_violations[:5]:
    print(" ", f, {k: sorted(v) for k, v in bad.items()})

# 交叉表：线类 × code
tab = collections.Counter()
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None for v in slots.values()):
        continue
    for s, (r, c) in slots.items():
        if c in (1, 2, 7, 11):
            tab[(klass(s), c)] += 1
print("\n线类 × code 交叉表：")
print("class".ljust(8), *[str(c).rjust(6) for c in (1, 2, 7, 11)])
for k, _ in CLASS:
    print(k.ljust(8), *[str(tab[(k, c)]).rjust(6) for c in (1, 2, 7, 11)])
