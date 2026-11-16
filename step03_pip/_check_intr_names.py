# -*- coding: utf-8 -*-
import sqlite3
import collections
import re

con = sqlite3.connect(r"E:\v7work\model\v7_law.sqlite")
famL = {r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_L'")}
famR = {r[0] for r in con.execute("select distinct family from law_cells where tile_type='INT_R'")}
print("INT_L only:", sorted(famL - famR)[:12], len(famL - famR))
print("INT_R only:", sorted(famR - famL)[:12], len(famR - famL))
print("common:", len(famL & famR))


def norm(n):
    # 规范化：去掉方向后缀 _L/_R，mux 的 L/R 也归一
    n = re.sub(r"_L(?=\d|$)", "", n)
    n = re.sub(r"_R(?=\d|$)", "", n)
    n = n.replace("IMUX_L", "IMUX").replace("IMUX_R", "IMUX")
    return n


mL = collections.Counter(norm(x) for x in famL)
mR = collections.Counter(norm(x) for x in famR)
print("normalized equal sets:", set(mL) == set(mR))
diff = {k: (mL.get(k, 0), mR.get(k, 0)) for k in set(mL) | set(mR) if mL.get(k) != mR.get(k)}
print("still differ:", list(diff.items())[:10], len(diff))

# INT_R 的 family 名单样本
print("INT_R sample:", sorted(famR)[:8])
srcR = [r[0] for r in con.execute("select distinct src_wire from law_cells where tile_type='INT_R' and family='BYP_ALT0'")]
srcL = [r[0] for r in con.execute("select distinct src_wire from law_cells where tile_type='INT_L' and family='BYP_ALT0'")]
print("BYP_ALT0 src diff only-L:", sorted(set(srcL) - set(srcR)))
print("BYP_ALT0 src diff only-R:", sorted(set(srcR) - set(srcL)))
print("norm equal:", {norm(x) for x in srcL} == {norm(x) for x in srcR})
