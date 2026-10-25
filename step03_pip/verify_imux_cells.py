# -*- coding: utf-8 -*-
"""校验：segbits 的「置位位集合」是否与 485T 实测差分完全一致（不经过 row/col 抽象）。

segbits 行格式：INT_L.IMUX_L8.GFAN0 21_02 !22_02 !23_02 !24_02 25_02
  - 无 ! ：该位必须为 1
  - 有 ! ：该位必须为 0
坐标：segbits word 16..25 -> 我们的 frame 偏移 df = word-16；bit 取 %32（prjxray 用 0..63 打包）。
"""
import json
import re
import sqlite3

SEG = r"E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7\segbits_int_l.db"
TILEPIPE = r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json"
FIELD_WORD = 23  # INT_L/CLBLL_L 内 IMUX 字段所在 word


def parse(path):
    rx = re.compile(r"INT_L\.(IMUX_L\d+)\.(.+)$")
    out = {}
    for line in open(path, encoding="utf-8"):
        parts = line.split()
        if not parts:
            continue
        m = rx.match(parts[0])
        if not m:
            continue
        pos, neg = set(), set()
        for tok in parts[1:]:
            isneg = tok.startswith("!")
            w, b = (int(x) for x in tok.lstrip("!").split("_"))
            cell = (w - 16, b % 32)
            (neg if isneg else pos).add(cell)
        # 只保留 word 16..25 范围内的 IMUX 选择字段
        pos = {c for c in pos if 0 <= c[0] <= 9}
        neg = {c for c in neg if 0 <= c[0] <= 9}
        out.setdefault(m.group(1), {})[m.group(2)] = (pos, neg)
    return out


def main():
    seg = parse(SEG)
    data = json.load(open(TILEPIPE, encoding="utf-8-sig"))
    total = ok = 0
    bad = []
    for rec in data.values():
        mux = rec["sink"]
        table = seg.get(mux, {})
        sources = rec["sources"]
        frames = [c[0] for cells in sources.values() for c in cells]
        if not frames:
            continue
        f0 = min(frames)
        for wire, cells in sources.items():
            if wire not in table:
                continue
            total += 1
            obs = {(fr - f0, b) for fr, _w, b in cells}
            pos, neg = table[wire]
            if obs == pos:
                ok += 1
            else:
                bad.append((mux, wire, sorted(obs - pos), sorted(pos - obs)))
    print("positive-set match: %d/%d" % (ok, total))
    for b in bad[:8]:
        print("  ", b)


if __name__ == "__main__":
    main()
