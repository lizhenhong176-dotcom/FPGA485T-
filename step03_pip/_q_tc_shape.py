# -*- coding: utf-8 -*-
"""G3：tileconn 的连线是否决定槽位 (r,c)？先看结构与一个族的全部源的对外连接。"""
import json, collections, re, sqlite3

TC = r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json"
d = json.load(open(TC, encoding="utf-8"))
print("顶层类型:", type(d))
if isinstance(d, dict):
    ks = list(d)
    print("键数:", len(ks), "| 前 5:", ks[:5])
    v = d[ks[0]]
    print("样例值:", type(v), (v if not isinstance(v, (dict, list)) else str(v)[:400]))
elif isinstance(d, list):
    print("条目数:", len(d))
    print("样例:", json.dumps(d[0], ensure_ascii=False)[:500])
