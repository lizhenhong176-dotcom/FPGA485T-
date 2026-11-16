# -*- coding: utf-8 -*-
"""看 tileconn.json 结构：INT_L 的线对与偏移。"""
import json, collections

P = r"E:\v7work\db\prjxray\xc7vx485t\tileconn.json"
d = json.load(open(P, encoding="utf-8"))
print(type(d), (list(d)[:6] if isinstance(d, dict) else len(d)))
if isinstance(d, list):
    print(json.dumps(d[0], ensure_ascii=False)[:600])
