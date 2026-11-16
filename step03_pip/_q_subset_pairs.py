# -*- coding: utf-8 -*-
"""辨析：哪些 feature 的位集被别的 feature 完全包含（= 观测上与后者无法区分的候选）。

判定：若 features[A] ⊂ features[B]（严格子集），则当 B 被布线时，A 的格子全为 1，
仅凭 A 自己的格子无法判断 A 是否也被布线 —— 这就是「被包含候选」。
分三类统计：同族内、跨族、以及 2 格 feature 中有多少属于此类。
"""
import collections
import itertools
import sqlite3

con = sqlite3.connect(r"file:E:\v7work\model\v7_law.sqlite?mode=ro", uri=True)
feat = collections.defaultdict(set)   # (family, src) -> cells
for fam, src, fo, bit, par in con.execute(
        "select family,src_wire,frame_off,bit,parity from law_cells "
        "where tile_type='INT_L' and sense=1"):
    feat[(fam, src)].add((fo, par, bit))

print("feature 总数:", len(feat))
by_fam = collections.defaultdict(list)
for (fam, src), cells in feat.items():
    by_fam[fam].append((src, frozenset(cells)))

# 同族内严格子集对数
same_fam_pairs = 0
for fam, items in by_fam.items():
    for (sa, ca), (sb, cb) in itertools.combinations(items, 2):
        if ca < cb or cb < ca:
            same_fam_pairs += 1
print("同族内严格子集对:", same_fam_pairs)

# 跨族包含：用倒排索引，只查 2 格 feature（成本可控）
idx = collections.defaultdict(set)
for key, cells in feat.items():
    for c in cells:
        idx[c].add(key)

n2 = [(k, v) for k, v in feat.items() if len(v) == 2]
print("2 格 feature 数:", len(n2))
contained_cross = 0
contained_any = 0
examples = []
for key, cells in n2:
    cands = None
    for c in cells:
        s = idx[c]
        cands = set(s) if cands is None else (cands & s)
    for other in cands:
        if other == key:
            continue
        if cells < feat[other]:
            contained_any += 1
            if other[0] != key[0]:
                contained_cross += 1
                if len(examples) < 5:
                    examples.append((key, other, sorted(cells), sorted(feat[other])))
            break
print("2 格 feature 中：被别的 feature 严格包含 =", contained_any,
      "（其中跨族 =", contained_cross, "）")
for e in examples:
    print("   例:", e[0], "⊂", e[1], e[2], "⊂", e[3])
