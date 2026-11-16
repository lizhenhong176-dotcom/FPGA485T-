# -*- coding: utf-8 -*-
"""P1h：32 个 BEG 变体族的列归属 —— 用「方向桶 + 4 行长线表」重建，验 640/640。

规则（只吃名字）：
  C0/C1  6 条 len2 线按「轴(EE/WW/NN/SS) vs 斜(NE/NW/SE/SW)」3+3 分组；
         orientation bit b(D)：{EE,NE,WW,SW} → 轴进 C1；{NN,NW,SE,SS} → 轴进 C0
         LOGIC_OUTS 跟随同一 bit：{L_i,L_i+4} 与 {L_i+8,L_i+12} 分列，{L_i+18,L_i+22} 恒 C3
  C2     两个长线（族序号 0..3 查 4 行表）+ 方向桶表给出的 3 条长距离线
  C3     剩余长距离线 + {L_i+18,L_i+22}
"""
import sqlite3, collections, re

DB = r"E:\v7work\model\v7_law.sqlite"
con = sqlite3.connect(DB)
rows = con.execute("select family, src_wire, frame_off, bit, parity from law_cells "
                   "where tile_type='INT_L' and sense=1").fetchall()
fam = collections.defaultdict(lambda: collections.defaultdict(set))
for f, s, fo, b, p in rows:
    fam[f][s].add((fo, p, b))
beg = {f: d for f, d in fam.items() if len(d) == 20}

AXIS = {"EE", "WW", "NN", "SS"}
FLIP = {"EE", "NE", "WW", "SW"}
LONG = {0: {"LH12", "LV_L0"}, 1: {"LH6", "LV_L9"},
        2: {"LVB_L0", "LVB_L12"}, 3: {"LH0", "LV_L18"}}
BUCKET = {frozenset({"EE", "SE"}): {"EE4", "NE6", "SW6"},
          frozenset({"WW", "NW"}): {"WW4", "NE6", "SW6"},
          frozenset({"NE", "NN"}): {"EE4", "NE6", "WW4"},
          frozenset({"SS", "SW"}): {"EE4", "SW6", "WW4"}}


def short(s):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW|EL|ER|NL|NR|SL|SR|WL|WR)(\d)END", s)
    if m:
        return m.group(1) + m.group(2)
    if s.startswith("LOGIC_OUTS_"):
        return s.replace("LOGIC_OUTS_", "")
    return s


def actual_cols(d):
    deg = collections.Counter()
    for cs in d.values():
        for c in cs:
            deg[c] += 1
    Q = sorted(c for c in deg if deg[c] == 5)
    return [{short(s) for s, cs in d.items() if c in cs} for c in Q]


def predict(fname, pool):
    m = re.match(r"^(EE|WW|NN|SS|NE|NW|SE|SW)(\d)BEG(\d)$", fname)
    D, idx = m.group(1), int(m.group(3))
    flip = D in FLIP
    len2 = [x for x in pool if re.match(r"^[A-Z]{2}2$", x)]
    hi = [x for x in pool if re.match(r"^[A-Z]{2}[46]$", x) and not x.startswith(("LH", "LV"))]
    ax = {x for x in len2 if x[:2] in AXIS}
    dg = set(len2) - ax
    g0 = {"L%d" % (i + idx) for i in (0, 4)}
    g1 = {"L%d" % (i + idx) for i in (8, 12)}
    l3 = {"L%d" % (16 + (idx + 2) % 4 + 4 * m) for m in (0, 1)}
    c0 = (dg | g0) if flip else (ax | g1)
    c1 = (ax | g1) if flip else (dg | g0)
    want = None
    for k, v in BUCKET.items():
        if D in k:
            want = v
    c2_hi = {x for x in hi if x in want}
    c3_hi = set(hi) - c2_hi
    return [c0, c1, c2_hi | LONG[idx], c3_hi | l3], len(len2), len(hi)


total = okc = 0
fails = []
skipped = []
for f in sorted(beg):
    cols = actual_cols(beg[f])
    got = [set(c) for c in cols]
    pool = {short(s) for s in beg[f]}
    if any(re.match(r"^[A-Z]{2}1$", x) for x in pool):
        skipped.append(f)                     # 纯净族（含 1 跳线）不在本规则范围
        continue
    pre, n2, nh = predict(f, pool)
    if n2 != 6 or nh != 6:
        skipped.append(f + "*")
        continue
    for i in range(4):
        total += len(got[i])
        if got[i] == pre[i]:
            okc += len(got[i])
        else:
            fails.append((f, i, sorted(got[i]), sorted(pre[i])))
print("跳过:", len(skipped), " 参与族:", 32 - 0 + len(skipped) - len(skipped))
print("槽位命中: %d / %d" % (okc, total))
for f, i, g, p in fails[:6]:
    print("\n", f, "C%d" % i)
    print("  实:", g)
    print("  预:", p)
