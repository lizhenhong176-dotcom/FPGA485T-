# -*- coding: utf-8 -*-
"""写位验证（本地部分）：把 ref.bit 改写成另一个源，检查

1. 目标 mux 读回就是目标源（精确匹配）；
2. 其余 95 个 mux 的读值与改写前完全一致（无串扰）；
3. 改动只落在该 mux 的域内（别的位一个都没变）；
4. 往返：再写回原源，帧内容与原始 ref.bit 完全一致。

用法:: python write_test.py [ref.bit]
"""
import sys

sys.path.insert(0, r"E:\DEEPSEEK\FPGA比特流逆向\v7re")

from imux_codec import ImuxTable, load_frames, field_word  # noqa: E402
from bitstream.parser import frames_from_words  # noqa: E402
import copy  # noqa: E402

REF = sys.argv[1] if len(sys.argv) > 1 else r"ref_X8Y11_A6LUT_A1.bit"
BASE = 31696
CASES = [
    ("IMUX_L7", "BYP_BOUNCE3"),
    ("IMUX_L7", "ER1END3"),
    ("IMUX_L8", "NR1END0"),
    ("IMUX_L4", "SS2END1"),
]


def snapshot(t, frames):
    out = {}
    for ttype in ("INT_L", "INT_R"):
        for (tt, mux) in t.muxes:
            if tt != ttype:
                continue
            out[(tt, mux)] = t.read(frames, tt, mux)[0]
    return out


def main():
    t = ImuxTable()
    orig = load_frames(REF)
    before = snapshot(t, orig)
    print("baseline muxes with non-default source:")
    for k, v in sorted(before.items()):
        if v != "VCC_WIRE":
            print("  %-8s %-8s %s" % (k[0], k[1], v))

    ok = True
    for mux, src in CASES:
        frames = copy.deepcopy(orig)
        t.encode(frames, "INT_L", mux, src)
        got, exact = t.read(frames, "INT_L", mux)
        after = snapshot(t, frames)
        collateral = {k: (before[k], after[k]) for k in before if before[k] != after[k] and k != ("INT_L", mux)}
        # 只有该 mux 的域内位可变
        diffcells = set()
        for fi in range(BASE, BASE + 10):
            x, y = orig[fi], frames[fi]
            for w in range(101):
                d = x[w] ^ y[w]
                while d:
                    b = d & -d
                    diffcells.add((fi - BASE, (b.bit_length() - 1), w))
                    d ^= b
        allowed = {(df, bit, field_word(mux)) for df, bit in t.domain[("INT_L", mux)]}
        outside = diffcells - allowed
        # 往返：写回原源，帧内容应恢复成 ref.bit
        back = copy.deepcopy(frames)
        orig_src = before[("INT_L", mux)]
        if orig_src == "VCC_WIRE":
            for df, bit in t.domain[("INT_L", mux)]:
                t._set(back, df, bit, BASE, field_word(mux), 0)
        else:
            t.encode(back, "INT_L", mux, orig_src)
        same_as_orig = all(back[i] == orig[i] for i in range(len(orig)))
        good = exact and got == src and not collateral and not outside and same_as_orig
        ok &= good
        print("%-8s <- %-14s exact=%s read=%s collateral=%d outside=%d roundtrip=%s => %s"
              % (mux, src, exact, got, len(collateral), len(outside), same_as_orig,
                 "PASS" if good else "FAIL"))
        if outside:
            print("   outside:", sorted(outside)[:5])
        if collateral:
            print("   collateral:", list(collateral.items())[:3])
    print("ALL PASS" if ok else "SOME FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())

