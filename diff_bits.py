#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
diff_bits.py —— 两个 .bit 的位级差分（帧 → 字 → 位）

复用 parse_bit_v2 的解析逻辑，不重复实现第 5 遍。

输出示例：
  frame 21350  word[ 20] bit 15     0x00008000 -> 0x00004000
  frame 21350  word[ 20] bit 14     0x00008000 -> 0x00004000
  frame 21350  word[ 50] bits [0,12] (ECC) 0x000015CF -> 0x000005CE

用法：
  python diff_bits.py a.bit b.bit
  python diff_bits.py a.bit b.bit --json out.json
"""

import argparse
import json
import sys
from pathlib import Path

from parse_bit_v2 import SYNC, parse_words, parse_packets, build_frames

# 7 系列 101 字帧中，word[50] 的低 13 位是 ECC。
# 这是经验值，用 --ecc-word 可改；用 --no-ecc 关闭标注。
ECC_WORD = 50


def load_frames(path: Path):
    data = path.read_bytes()
    pos = data.find(SYNC)
    if pos < 0:
        raise SystemExit(f"{path}: 找不到同步字")
    words = parse_words(data, pos)
    segments, _info = parse_packets(words, strict=False)
    frames, _ = build_frames(segments)
    return frames


def diff(a_frames, b_frames, ecc_word):
    n = min(len(a_frames), len(b_frames))
    out = []
    for k in range(n):
        x, y = a_frames[k], b_frames[k]
        if x == y:
            continue
        words = []
        for wi, (xw, yw) in enumerate(zip(x, y)):
            if xw == yw:
                continue
            xor = xw ^ yw
            bits = [bi for bi in range(32) if (xor >> bi) & 1]
            words.append({
                "word": wi,
                "bits": bits,
                "from": f"0x{xw:08X}",
                "to": f"0x{yw:08X}",
                "ecc": (wi == ecc_word),
            })
        out.append({"frame": k, "words": words})
    return n, out


def main():
    ap = argparse.ArgumentParser(description="两个 .bit 的位级差分")
    ap.add_argument("a")
    ap.add_argument("b")
    ap.add_argument("--json")
    ap.add_argument("--ecc-word", type=int, default=ECC_WORD)
    ap.add_argument("--no-ecc", action="store_true")
    args = ap.parse_args()

    fa = load_frames(Path(args.a))
    fb = load_frames(Path(args.b))

    print(f"A: {args.a}  {len(fa)} frames")
    print(f"B: {args.b}  {len(fb)} frames")
    if len(fa) != len(fb):
        print(f"[warn] 帧数不同，只比较前 {min(len(fa), len(fb))} 帧", file=sys.stderr)

    n, diffs = diff(fa, fb, args.ecc_word)
    total_bits = sum(len(w["bits"]) for d in diffs for w in d["words"])
    data_bits = sum(len(w["bits"]) for d in diffs for w in d["words"]
                    if not (w["ecc"] and not args.no_ecc))

    print(f"比较 {n} 帧，差异 {len(diffs)} 帧，{total_bits} 个 bit"
          f"（其中数据位 {data_bits}，ECC 位 {total_bits - data_bits}）\n")

    for d in diffs:
        print(f"frame {d['frame']}:")
        for w in d["words"]:
            tag = "  (ECC)" if (w["ecc"] and not args.no_ecc) else ""
            print(f"  word[{w['word']:3d}] bits={w['bits']}{tag}  "
                  f"{w['from']} -> {w['to']}")

    if len(diffs) > 0:
        # 帧号间隔能看出是“内容变化”还是“位置迁移”
        nums = [d["frame"] for d in diffs]
        if len(nums) > 1:
            print(f"\n差异帧号: {nums}")
            print(f"帧号跨度: {max(nums) - min(nums)}")

    if args.json:
        Path(args.json).write_text(json.dumps({
            "a": args.a, "b": args.b,
            "frames_a": len(fa), "frames_b": len(fb),
            "compared": n, "diff_frames": diffs,
            "total_bits": total_bits, "data_bits": data_bits,
        }, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"已写入 {args.json}")


if __name__ == "__main__":
    main()
