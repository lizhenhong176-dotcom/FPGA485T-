# -*- coding: utf-8 -*-
"""G4：槽位 (r,c) 的结构化程度量化。
假设：c = f(线类)（4 类），r = f(方向)（4 向）逐族置换，其余 8 个源占 row4/5 的 8 个格。"""
import sqlite3, collections, re, json

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

CLS = {"EE": ("axis", "E"), "WW": ("axis", "W"), "NN": ("axis", "N"), "SS": ("axis", "S"),
       "NE": ("diag", "NE"), "NW": ("diag", "NW"), "SE": ("diag", "SE"), "SW": ("diag", "SW"),
       "EL": ("longL", "E"), "WL": ("longL", "W"), "NL": ("longL", "N"), "SL": ("longL", "S"),
       "ER": ("rline", "E"), "WR": ("rline", "W"), "NR": ("rline", "N"), "SR": ("rline", "S")}

def parse(name):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|EL|WL|NL|SL|ER|WR|NR|SR)", name)
    if m:
        return CLS[m.group(1)]
    if name.startswith("LOGIC_OUTS"):
        return ("logic", name)
    if name.startswith(("BYP_BOUNCE", "FAN_BOUNCE")):
        return ("bounce", name)
    if name.startswith("GFAN"):
        return ("gfan", name)
    return ("other", name)

stat = collections.Counter()
code_of_class = collections.Counter()      # (family, class) -> set of codes
row_of_dir_by_class = collections.defaultdict(dict)
detail = []

for f, d in fam.items():
    if len(d) not in (20, 24):
        continue
    slots = {s: slot(c) for s, c in d.items()}
    if any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        stat["skip_non_grid"] += 1
        continue
    stat[f"{len(d)}源族"] += 1
    # 每个线类是否只落在一个 code
    per_cls = collections.defaultdict(set)
    for s, (r, c) in slots.items():
        k = parse(s)
        per_cls[k[0]].add(c)
    geo_ok = all(len(per_cls[k]) == 1 for k in ("axis", "diag", "longL", "rline") if k in per_cls)
    stat["类→code 唯一" if geo_ok else "类→code 多值"] += 1
    if not geo_ok:
        detail.append((f, {k: sorted(v) for k, v in per_cls.items() if len(v) > 1}))
        continue
    # 同族内方向→行 是否各线类一致
    perms = {}
    for cls, key in (("axis", None), ("diag", None), ("longL", None), ("rline", None)):
        m = {}
        for s, (r, c) in slots.items():
            k = parse(s)
            if k[0] == cls:
                m[k[1]] = r
        if m:
            perms[cls] = m
    same = len({tuple(sorted(v.items())) for v in perms.values()}) == 1
    stat["四类方向→行 相同" if same else "四类方向→行 不同"] += 1
    # 行是否被 4 个方向铺满 0..3
    full = all(sorted(v.values()) == [0, 1, 2, 3] for v in perms.values())
    stat["方向铺满 0..3" if full else "方向未铺满"] += 1
    # 非方位源是否集中在 row 4/5
    extra_rows = sorted({r for s, (r, c) in slots.items() if ":" in str(parse(s))})
    stat["非方位 row=" + ",".join(map(str, extra_rows))] += 1
    detail.append((f, perms))

print("统计：")
for k, v in sorted(stat.items()):
    print("  ", k, v)

print("\n样例：BYP_ALT0 的方向→行：")
for f, perms in detail:
    if f == "BYP_ALT0":
        print("  ", perms)
