# -*- coding: utf-8 -*-
"""G2：槽位 (r,c) 是否 = f(源线的「线类 + 方向」，跨族一致)？行/列各自归谁？"""
import sqlite3, collections, re, itertools

LAW = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(LAW)
rows = con.execute("select family, src_wire, frame_off from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo in rows:
    fam[f][s].add(fo)
cellcount = collections.Counter((f, fo) for f, d in fam.items()
                                for s, fos in d.items() for fo in fos)

def slot(fos):
    r, code = None, 0
    for fo in fos:
        if 16 <= fo <= 21:
            r = fo - 16
        elif 22 <= fo <= 25:
            code |= 1 << (25 - fo)
    return r, code

# 线类 + 方向
DIRS = {"N": "N", "S": "S", "E": "E", "W": "W"}
def parse(name):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|EL|WL|NL|SL|ER|WR|NR|SR)", name)
    if m:
        return m.group(1)
    if name.startswith("LOGIC_OUTS"):
        return "LOGIC_OUTS:" + name.split("_")[-1]
    if name.startswith("BYP_BOUNCE") or name.startswith("FAN_BOUNCE"):
        return "BOUNCE:" + name
    if name.startswith("GFAN"):
        return "GFAN:" + name
    return "OTHER:" + name

# 只取 24 源族（6 行 × 4 码）
fams24 = [f for f, d in fam.items() if len(d) == 24]
print("24 源族：", len(fams24))

# 统计：每个 (token) 落到的行
row_of = collections.defaultdict(collections.Counter)
code_of = collections.defaultdict(collections.Counter)
rowset_of = collections.defaultdict(collections.Counter)
for f in fams24:
    per_token_rows = collections.defaultdict(list)
    for s in fam[f]:
        r, c = slot(fam[f][s])
        t = parse(s)
        row_of[t][r] += 1
        code_of[t][c] += 1
        per_token_rows[t].append(r)
    for t, rs in per_token_rows.items():
        rowset_of[t][tuple(sorted(rs))] += 1

print("\n典型 token 的行分布（跨 64 族累计）：")
for t in ["EE", "WW", "NN", "SS", "NE", "NW", "SE", "SW", "EL", "WL", "NL", "SL",
          "ER", "WR", "NR", "SR"]:
    if t in row_of:
        print("  ", t.ljust(4), "行:", dict(sorted(row_of[t].items())),
              "| 码:", dict(sorted(code_of[t].items())))

print("\n非方位 token 的行集合（应集中在 4/5）：")
for t in sorted(rowset_of):
    if ":" in t:
        print("  ", t.ljust(28), dict(rowset_of[t].most_common(3)))
