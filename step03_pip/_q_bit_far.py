# -*- coding: utf-8 -*-
"""比特流里的 FAR：实际写了哪些、各字段取值范围、与帧号的关系。"""
from __future__ import annotations
import collections, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "v7re"))

from bitstream.parser import parse_bit, SYNC, FAR, FDRI, CMD
from bitstream.far import FarAddress

for name in ("tamper/ref/ref.bit", "_full8.bit"):
    p = ROOT / name
    if not p.exists():
        continue
    bs = parse_bit(p)
    print("=" * 70)
    print(name, "size", bs.file_size, "frames", bs.frame_count, "leftover", bs.leftover)
    print("sync offset", bs.sync_offset, "| FAR 出现次数", len(bs.far_starts))
    print("commands:", [hex(c) for c, _ in bs.commands][:8])

    # 每个 FAR 之后多少帧
    starts = [st for st, _ in bs.far_starts] + [len(bs.payload_words)]
    bursts = [(bs.far_starts[k][1], starts[k + 1] - starts[k]) for k in range(len(bs.far_starts))]
    print("每段 FAR -> 字数 / 帧数：")
    for far, nw in bursts[:12]:
        fa = FarAddress.decode(far)
        print(f"  FAR=0x{far:08X} {fa}  字数={nw}  帧数={nw/101 if nw % 101 == 0 else nw/101:.2f}")
    if len(bursts) > 12:
        print(f"  ... 共 {len(bursts)} 段")

    # 字段取值
    fars = [f for _, f in bs.far_starts]
    for field in ("block_type", "top_bottom", "row", "column", "minor", "reserved"):
        vals = collections.Counter(getattr(FarAddress.decode(f), field) for f in fars)
        print(f"{field}: 取值 {sorted(vals)}")
