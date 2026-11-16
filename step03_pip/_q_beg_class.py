# -*- coding: utf-8 -*-
"""G18：20 源 K(5,4) 族里，B 位是否只由「源线的几何类别」决定、A 位是否只由方向决定。"""
import sqlite3, collections, re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))

def geo(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)", s)
    if m:
        return "len" + m.group(2)
    m = re.match(r"^(NL|SL|EL|WL|NR|SR|ER|WR)1", s)
    if m:
        return "line"
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"

def direc(s):
    m = re.match(r"^(EE|NE|SE|NN|SS|NL|SL|EL|WL|NR|SR|ER|WR)", s)
    if m:
        w = m.group(1)
        # 取首字母或第二字母：EE=east, NE=north-east 归 N? 先按两字母整体
        return w
    if s.startswith("LOGIC_OUTS"):
        return "logic"
    return "other"

stat = collections.Counter()
b_of_geo = collections.defaultdict(set)
a_of_dir = collections.defaultdict(set)
for f, d in fam.items():
    if len(d) != 20:
        continue
    cells = {s: sorted(cs) for s, cs in d.items()}
    if any(len(v) != 2 for v in cells.values()):
        continue
    A = {v[0] for v in cells.values()}
    B = {v[1] for v in cells.values()}
    if (len(A), len(B)) != (5, 4):
        stat["跳过"] += 1
        continue
    stat["K(5,4) 族"] += 1
    ok_geo = True
    for s, (a, b) in cells.items():
        b_of_geo[geo(s)].add(b[0])
        a_of_dir[direc(s)].add(a[0])
    # B 是否只由 geo 决定（族内）
    per_geo = collections.defaultdict(set)
    for s, (a, b) in cells.items():
        per_geo[geo(s)].add(b[0])
    if any(len(v) > 1 for v in per_geo.values()):
        ok_geo = False
    stat["B=f(几何类)" if ok_geo else "B 多值"] += 1

print(dict(stat))
print("\n几何类 -> B 帧集合（跨 64 族）：")
for k in sorted(b_of_geo):
    print("  ", k.ljust(8), sorted(b_of_geo[k]))
print("\n方向令牌 -> A 帧集合（跨 64 族）：")
for k in sorted(a_of_dir):
    print("  ", k.ljust(6), sorted(a_of_dir[k]))
