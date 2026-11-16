#!/usr/bin/env python3
"""T56 判据工具：位级差分 + 归一化 + PASS/FAIL（复用 v7re/bitstream 解析器）。

两种模式（对应 SKILL 的 PURE / XOR 语义声明）：

  xor A.bit B.bit   对称差：A 与 B 不同的 (frame, word, bit)
  abs B.bit         B 在窗口内的绝对 1 位

输出一律归一化到 (off, word, bit)，off = frame - base；
word == 50 (ECC) 单独计数、不参与内容位比对；窗口外帧单独列出并判 FAIL。

用法：
  python3 t56_diff.py xor A/A.bit A2/A2.bit --base 26434 --off 16-25 --must-be-empty
  python3 t56_diff.py xor A/A.bit B/B.bit  --base 26434 --off 16-25 \
          --expect ../t56_switchbox_spec.json --key B_minus_A
  python3 t56_diff.py abs B/B.bit          --base 26434 --off 16-25 \
          --expect ../t56_switchbox_spec.json --key B_abs

--expect 里存的是**绝对** (frame, word, bit)；本工具用 --base 归一化后比较。
退出码：0 = PASS（或 --must-be-empty 且确实为空）；1 = FAIL；2 = 用法/输入错误。
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
if (ROOT / "bitstream").is_dir() and str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from bitstream.frames import diff_bits_in_frame, diff_frame_indices, load_frames  # noqa: E402

ECC_WORD = 50


def parse_offs(spec: str) -> list[int]:
    if "-" in spec:
        lo, hi = spec.split("-", 1)
        return list(range(int(lo), int(hi) + 1))
    return [int(x) for x in spec.split(",") if x]


def bits_of_frame(frame_words: list[int], word: int) -> list[int]:
    """返回 word 中置 1 的 bit 号。"""
    v = frame_words[word]
    return [b for b in range(32) if (v >> b) & 1]


def parse_expect(items) -> list[tuple[int, int, int]]:
    """expected[key] 支持两种写法：三元组 [frame, word, bit] 或字符串 "frame word bit"。

    设计单 t56_switchbox_spec.json 由 S5 生成，当前统一写成三元组（int 列表）；
    本函数同时接受字符串写法，避免手写期望集时把 "26453 22 3" 这样的行文本直接塞进去
    导致解包错误（字符串被逐字符解包 → ValueError: too many values to unpack）。
    """
    out: list[tuple[int, int, int]] = []
    for it in items:
        if isinstance(it, str):
            parts = it.split()
        else:
            parts = list(it)
        if len(parts) != 3:
            raise ValueError(f"expected 条目必须是 3 个整数: {it!r}")
        out.append((int(parts[0]), int(parts[1]), int(parts[2])))
    return out


def classify(items, base: int, offs: set[int]):
    """(frame, word, bit) -> (content, ecc, outside) 三桶。"""
    content, ecc, outside = [], [], []
    for frame, word, bit in items:
        off = frame - base
        if word == ECC_WORD:
            ecc.append((off, word, bit))
        elif off in offs:
            content.append((off, word, bit))
        else:
            outside.append((off, word, bit))
    return sorted(content), sorted(ecc), sorted(outside)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("mode", choices=["xor", "abs"])
    ap.add_argument("a", help="xor: 基线 .bit；abs: 待测 .bit")
    ap.add_argument("b", nargs="?", help="xor: 变体 .bit")
    ap.add_argument("--base", type=int, required=True, help="该 tile 的块基帧")
    ap.add_argument("--off", default="16-25", help="窗口 frame_off，形如 16-25")
    ap.add_argument("--expect", help="设计单 JSON（含 expected[key]）")
    ap.add_argument("--key", help="expected 里的键名")
    ap.add_argument("--must-be-empty", action="store_true",
                    help="负对照用：任何位变化（含 ECC）都算 FAIL")
    ap.add_argument("--word", type=int,
                    help="abs 模式只扫这一个 word（层内唯一标识：word=2*(y%%50)+parity）；"
                         "xor 模式忽略此参数，其它 word 的变化一律算 extra/FAIL")
    ap.add_argument("--json", dest="json_out", help="把结果写入 JSON 文件")
    args = ap.parse_args()

    offs = parse_offs(args.off)
    off_set = set(offs)
    base = args.base

    if args.mode == "xor":
        if not args.b:
            print("用法错误：xor 需要两个输入文件", file=sys.stderr)
            return 2
        fa, fb = load_frames(args.a), load_frames(args.b)
        print(f"frames A={len(fa)} B={len(fb)}")
        frames = diff_frame_indices(fa, fb)
        raw = []
        for f in frames:
            for word, bit in diff_bits_in_frame(fa, fb, f):
                raw.append((f, word, bit))
        label = f"XOR({Path(args.a).name}, {Path(args.b).name})"
    else:
        fb = load_frames(args.a)
        print(f"frames = {len(fb)}")
        raw = []
        for off in offs:
            f = base + off
            if f >= len(fb):
                print(f"错误：帧 {f} 超出范围（只有 {len(fb)} 帧）", file=sys.stderr)
                return 2
            words = range(len(fb[f])) if args.word is None else [args.word]
            for word in words:
                if word == ECC_WORD:
                    continue
                for bit in bits_of_frame(fb[f], word):
                    raw.append((f, word, bit))
        wtag = "" if args.word is None else f", word={args.word}"
        label = f"ABS({Path(args.a).name}{wtag})"

    content, ecc, outside = classify(raw, base, off_set)
    print(f"{label}: 内容位 {len(content)} / ECC 位 {len(ecc)} / 窗口外 {len(outside)}")
    if content:
        print("  内容位 (off, word, bit):", content)
    if ecc:
        print("  ECC  (off, word, bit):", ecc)
    if outside:
        print("  窗口外 (off, word, bit):", outside)

    verdict = "PASS"
    missing = extra = []
    if args.must_be_empty:
        bad = len(content) + len(ecc) + len(outside)
        if bad:
            verdict = "FAIL"
            print(f"  FAIL: --must-be-empty 但发现 {bad} 位变化")
        else:
            print("  PASS: 零位变化（负对照成立）")
    elif args.expect and args.key:
        spec = json.loads(Path(args.expect).read_text(encoding="utf-8-sig"))
        exp_abs = parse_expect(spec["expected"][args.key])
        exp = sorted((f - base, w, b) for f, w, b in exp_abs)
        got = content
        missing = [t for t in exp if t not in got]
        extra = [t for t in got if t not in exp]
        print(f"  预测集大小={len(exp)} 实测集大小={len(got)} "
              f"missing={len(missing)} extra={len(extra)}")
        if missing:
            print("  missing:", missing)
        if extra:
            print("  extra:", extra)
        if missing or extra or outside:
            verdict = "FAIL"
    else:
        print("  （未给 --expect/--key，仅输出集合，不判 PASS/FAIL）")
        verdict = "INFO"

    if args.json_out:
        Path(args.json_out).write_text(json.dumps({
            "label": label,
            "base": base,
            "window_offsets": offs,
            "content": content,
            "ecc": ecc,
            "outside": outside,
            "missing": missing,
            "extra": extra,
            "verdict": verdict,
        }, ensure_ascii=False, indent=1), encoding="utf-8")
        print(f"  -> {args.json_out}")

    print(f"  判定: {verdict}")
    if verdict == "FAIL":
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
