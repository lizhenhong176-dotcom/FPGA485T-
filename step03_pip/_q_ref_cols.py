# -*- coding: utf-8 -*-
"""ref 设计里出现了哪些 INT tile 列？高列有没有？"""
from __future__ import annotations
import collections, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re"))

txt = (ROOT / "tamper/ref/pips_all.txt").read_text(encoding="utf-8", errors="replace")
tiles = collections.Counter()
for line in txt.splitlines():
    m = re.match(r"\s*(INT_[LR]_X\d+Y\d+)[/.\s]", line)
    if not m:
        m = re.match(r"\s*(INT_[LR]_X\d+Y\d+)", line)
    if m:
        tiles[m.group(1)] += 1
cols = collections.Counter(int(t.split("_X")[1].split("Y")[0]) for t in tiles.elements())
print("PIP 行数:", len(txt.splitlines()), "| INT tile 数:", len(tiles))
print("列范围:", min(cols), max(cols), "| 涉及的列数:", len(cols))
print("高列(>=120):", sorted(c for c in cols if c >= 120))
print("每列 tile 数(前 5 / 后 5):", sorted(cols.items())[:5], sorted(cols.items())[-5:])
