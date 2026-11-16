# -*- coding: utf-8 -*-
"""G13：把命中率拆成「16 个几何源」与「8 个旁路源」，并给出旁路源的准确规则。"""
import sqlite3, collections, re, json

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
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
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}
def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return "extra", name

truth = {}
for f, d in fam.items():
    if len(d) != 24:
        continue
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    truth[f] = slots

def num(f): return int(re.search(r"(\d+)$", f).group(1))
def prefix(f): return re.sub(r"\d+$", "", f)
def block_of(f):
    n, p = num(f), prefix(f)
    if p == "FAN_ALT":
        return 0 if n in (0, 1, 2, 7) else 1
    return n // 8

def cfg_sig(slots):
    perm, cc = {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "extra":
            continue
        cc.setdefault(tag, set()).add(c)
        if tag != "diag":
            perm.setdefault(tag, {})[dirn] = r
    cc1 = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    return (tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
            tuple(sorted(perm["rline"].items())), cc1["axis"], cc1["longL"])

CFG = {}
for f, slots in truth.items():
    CFG.setdefault((prefix(f), block_of(f), num(f) % 2), cfg_sig(slots))

geo_hit = geo_tot = ext_hit = ext_tot = 0
ext_miss = collections.Counter()
for f, slots in truth.items():
    pax, pln, prl, ca, cl = CFG[(prefix(f), block_of(f), num(f) % 2)]
    pax, pln, prl = dict(pax), dict(pln), dict(prl)
    code_of = {"axis": ca, "longL": cl, "diag": 1 if ca == 2 else 2,
               "rline": 7 if cl == 11 else 11}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "extra":
            ext_tot += 1
            continue
        pred = ((pax[dirn] if tag in ("axis", "diag") else
                 pln[dirn] if tag == "longL" else prl[dirn]), code_of[tag])
        geo_tot += 1
        if pred == (r, c):
            geo_hit += 1

# 旁路源：用「行 = 4/5 由线种定 + 码 = 该族某个线类的码」的规则，逐条找最佳配对
pair_hit = 0
for f, slots in truth.items():
    pax, pln, prl, ca, cl = CFG[(prefix(f), block_of(f), num(f) % 2)]
    code_of = {"axis": ca, "longL": cl, "diag": 1 if ca == 2 else 2, "rline": 7 if cl == 11 else 11}
    codes = {c for s, (r, c) in slots.items()}
    for s, (r, c) in slots.items():
        if key(s)[0] != "extra":
            continue
        want_row = 4 if re.match(r"^(LOGIC_OUTS|GFAN)", s) else 5
        # 该族里 4 个码是否各有 2 个旁路源（row4/row5）
        same = [(ss, rr, cc) for ss, (rr, cc) in slots.items()
                if key(ss)[0] == "extra" and cc == c]
        rows_here = sorted(rr for _, rr, _ in same)
        if r == want_row and rows_here == [4, 5]:
            pair_hit += 1
        ext_tot += 0

print(f"16 个几何源：{geo_hit}/{geo_tot} = {100.0*geo_hit/geo_tot:.2f}%")
print(f"8 个旁路源：行号由线种（LOGIC/GFAN→4，BOUNCE→5）决定的条数 = {pair_hit}/512")
print("旁路源的码：每族每个码下恰有一个 row4 与一个 row5 旁路源 —— 见上条判据")

# 统计：每族每个码下旁路源的行集合
dist = collections.Counter()
for f, slots in truth.items():
    per = collections.defaultdict(list)
    for s, (r, c) in slots.items():
        if key(s)[0] == "extra":
            per[c].append(r)
    for c, rs in per.items():
        dist[tuple(sorted(rs))] += 1
print("\n每 (族, 码) 的旁路源行集合分布：", dict(dist))
