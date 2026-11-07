#!/usr/bin/env python3
"""test_locked_init_map.py —— 实测 INIT 索引表接入 build_site_frames 的无写库回归测试。

四条：
  T1 映射文件与 T19/T23/law 一致（gen_locked_init_map.py --check）
  T2 负对照：把 SLICEM/SLICEL 两套表互换后，自检必须 FAIL（证明校验器不是橡皮章）
  T3 等价性：接入实测表前后，四个观测点的 (frame, word, bit) 集合完全相同
     —— 这说明 law 的 INIT 索引表本来就是对的，本次接入的价值是把实测变成
     权威来源 + 自校验，而不是改变输出
  T4 交叉佐证：X12Y26 word=53（T22）、X12Y21 word=42、X12Y20 word=40（T21）

用法：python step03_pip/test_locked_init_map.py
"""
import copy
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "v7re", "scripts"))
sys.path.insert(0, os.path.join(ROOT, "step03_pip"))

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

import build_site_frames as B           # noqa: E402
import gen_locked_init_map as G         # noqa: E402

SITES = ["SLICE_X11Y20", "SLICE_X12Y20", "SLICE_X12Y21", "SLICE_X12Y26"]
V = 0xDEADBEEFCAFEBABE
fails = []


def check(name, cond, detail=""):
    print("  %s  %s%s" % ("PASS" if cond else "FAIL", name, ("  " + detail) if detail else ""))
    if not cond:
        fails.append(name)


def main():
    print("T1 映射文件与实测/law 一致")
    fresh = G.build_map()
    cur = json.load(open(B.DEFAULT_LOCKED_INIT, encoding="utf-8"))
    check("map 内容一致", all(cur.get(k) == fresh.get(k) for k in
                              ("orders", "bel_rule", "permutation", "group_off")),
          "T23 复核 matched=%s" % fresh["measurements"]["SLICEL"]["matched"])

    tiles, blocks, cells = B.load_law(B.DEFAULT_LAW)
    addr, _ = B.build_site_addr(tiles, blocks)
    sub = [a for a in addr if a[1] in SITES]
    locked = B.load_locked_init()
    rows, _ = B.emit_site_frames(sub, cells, locked=locked)

    print("T2 负对照：两套表互换后自检必须 FAIL")
    swapped = {"orders": {"SLICEM": locked["orders"]["SLICEL"],
                          "SLICEL": locked["orders"]["SLICEM"]},
               "bel_rule": locked["bel_rule"], "measurements": {}, "path": "swapped"}
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        ok_swapped = B.validate_locked_init(addr, cells, swapped)
    check("互换表被自检拒绝", ok_swapped is False, buf.getvalue().strip().splitlines()[0][:90])

    print("T3 等价性：接入实测表前后输出完全相同")
    rows_old, _ = B.emit_site_frames(sub, cells, locked=None)
    s_new = {(r[1], r[2], r[3], r[4], r[5], r[6]) for r in rows}
    s_old = {(r[1], r[2], r[3], r[4], r[5], r[6]) for r in rows_old}
    check("(site,bel,feature,frame,word,bit) 集合相同", s_new == s_old,
          "差异 %d 条" % len(s_new ^ s_old))
    n_locked = sum(1 for r in rows if r[7] == B.SOURCE_LOCKED)
    check("实测表路径确实被走到", n_locked > 0, "锁定 INIT 行 %d" % n_locked)

    print("T4 交叉佐证（T21/T22 独立实测）")
    for site in ("SLICE_X12Y20", "SLICE_X12Y21", "SLICE_X12Y26"):
        rs = [r for r in rows if r[1] == site and r[2] == "ALUT" and r[3].startswith("INIT[")]
        exp = {"SLICE_X12Y20": 40, "SLICE_X12Y21": 42, "SLICE_X12Y26": 53}[site]
        check("%s word=%d" % (site, exp), {r[5] for r in rs} == {exp},
              "实际 %s" % sorted({r[5] for r in rs}))
    rs = [r for r in rows if r[1] == "SLICE_X12Y20"]
    frames_of = {bel: sorted({r[4] for r in rs if r[2] == bel and r[3].startswith("INIT[")})
                 for bel in B.LUT_BEL}
    check("四个 bel 同帧组 base+32..35", len(set(map(tuple, frames_of.values()))) == 1,
          str(frames_of["ALUT"]))

    print("RESULT:", "PASS" if not fails else "FAIL %s" % fails)
    return 0 if not fails else 1


if __name__ == "__main__":
    sys.exit(main())
