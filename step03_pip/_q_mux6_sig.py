# -*- coding: utf-8 -*-
import sqlite3, collections, re
con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite"); cur = con.cursor()
cur.execute("SELECT family, src_wire, frame_off, bit FROM law_cells WHERE tile_type='INT_L' AND sense=1")
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b in cur.fetchall(): fam[f][s].add((fo, b))
mux = {f: v for f, v in fam.items() if len(v) == 24}

def cls_of(s):
    s = re.sub(r"_?N\d+_\d+$", "", s)          # 去掉 _N3_2 这类后缀
    s = re.sub(r"_S\d+$", "", s)
    m = re.match(r"^(LOGIC_OUTS|GFAN|BYP_BOUNCE|BYP_ALT|FAN_BOUNCE|FAN_ALT|BYP|FAN)", s)
    if m: return m.group(1)
    m = re.match(r"^([NSEW]{1,2}|[LR])", s)
    return m.group(1) if m else s[:3]

# 每族：row -> 该类集合
sigs = collections.Counter(); detail = {}
for f, srcs in mux.items():
    row2cls = collections.defaultdict(list)
    for s, cells in srcs.items():
        grp = [fo for fo, b in cells if 16 <= fo <= 21]
        if len(grp) != 1: row2cls["?"].append(s); continue
        row2cls[grp[0]].append(cls_of(s))
    sig = tuple((r, tuple(sorted(set(v)))) for r, v in sorted(row2cls.items(), key=lambda x: str(x[0])))
    sigs[sig] += 1
    detail[f] = row2cls
print("不同签名数:", len(sigs))
for sig, c in sigs.most_common(6):
    print(" --", c, "族:", sig)
print()
ex = detail["IMUX_L40"]
for r in sorted(ex): print("  row %s: %s" % (r, sorted(ex[r])))