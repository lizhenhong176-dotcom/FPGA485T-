# -*- coding: utf-8 -*-
"""扫多个位流：FAR 写了哪些值、是不是都只写一次。"""
from __future__ import annotations
import collections, glob, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re"))

from bitstream.parser import parse_bit
from bitstream.far import FarAddress

files = sorted(glob.glob(str(ROOT / "*.bit"))) + sorted(glob.glob(str(ROOT / "*.bin")))
print("文件数:", len(files))
rows = []
for f in files:
    try:
        bs = parse_bit(f)
    except Exception as e:                                  # noqa: BLE001
        print("skip", Path(f).name, e)
        continue
    fars = [v for _, v in bs.far_starts]
    rows.append((Path(f).name, bs.frame_count, len(fars), sorted({hex(v) for v in fars})[:4]))

for name, nf, nfar, vals in rows:
    print(f"{name:34s} frames={nf:6d} FAR次数={nfar:3d} 值={vals}")
