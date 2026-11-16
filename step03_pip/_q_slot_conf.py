# -*- coding: utf-8 -*-
"""G8：把每族的槽位表压成 16 种「配置」？配置是否由族名/序号决定？"""
import sqlite3, collections, re

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
DG = {"SE": "E", "SW": "S", "NE": "N", "NW": "W"}
LN = {"EL": "E", "WL": "W", "NL": "N", "SL": "S"}
RN = {"ER": "E", "WR": "W", "NR": "N", "SR": "S"}
def key(name):
    p = name[:2]
    for tab, tag in ((AX, "axis"), (DG, "diag"), (LN, "longL"), (RN, "rline")):
        if p in tab:
            return tag, tab[p]
    return ("other", name)

conf = {}
for f, d in fam.items():
    slots = {s: slot(c) for s, c in d.items()}
    if len(d) != 24 or any(v[0] is None or v[1] not in (1, 2, 7, 11) for v in slots.values()):
        continue
    cc, perm = {}, {}
    for s, (r, c) in slots.items():
        tag, dirn = key(s)
        if tag == "other":
            continue
        cc.setdefault(tag, set()).add(c)
        if tag != "diag":
            perm.setdefault(tag, {})[dirn] = r
    cc = {k: list(v)[0] for k, v in cc.items() if len(v) == 1}
    sig = (tuple(sorted(perm["axis"].items())), tuple(sorted(perm["longL"].items())),
           tuple(sorted(perm["rline"].items())), cc.get("axis"), cc.get("longL"))
    conf[f] = sig

print("族数：", len(conf), "| 不同配置：", len(set(conf.values())))
byn = collections.Counter(conf.values())
print("每种配置的族数：", sorted(byn.values(), reverse=True))

# 配置与族名的关系
def idx(f):
    m = re.search(r"(\d+)$", f)
    return int(m.group(1)) if m else -1
byidx = collections.defaultdict(set)
for f, s in conf.items():
    byidx[idx(f)].add(s)
print("\n族序号 -> 配置种类数（前 20）：", [(k, len(v)) for k, v in sorted(byidx.items())[:20]])

# 按前缀分组看配置
bypre = collections.defaultdict(set)
for f, s in conf.items():
    bypre[re.sub(r"\d+$", "", f)].add(s)
print("\n前缀 -> 配置种类数：")
for k, v in sorted(bypre.items()):
    print("  ", k.ljust(16), len(v))

# 族名 -> 配置，打印前 16
print("\n前 16 族：")
for f in sorted(conf)[:16]:
    a, l, r, ca, cl = conf[f]
    print("  ", f.ljust(14), "axis码", ca, "longL码", cl,
          "| axis", dict(a), "| longL", dict(l), "| rline", dict(r))
