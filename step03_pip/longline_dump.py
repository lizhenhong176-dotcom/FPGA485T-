#!/usr/bin/env python3
"""longline_dump.py —— P0b 第一步：把 24 个 sweep 设计里「落在预测之外的位」
（= 长线族的真实落点）连同该设计经过的长线 PIP 一起导出。

用法：python3 longline_dump.py --dir /opt/lzh/step03/sweep1 --out /tmp/longline.json
"""
import argparse
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, "/opt/lzh/v7re")

import pip_law
from v_bits import diff_dir, cells_of
from bitstream.parser import frames_from_bit

# 长线/六方向线家族的 sink 或 src 特征
LL = re.compile(r"^(?:[NS]S6|[NS]W6|[NS]E6|N[NS]6|LV|LH)")


def is_long(p):
    return bool(LL.match(p["sink"]) or LL.match(p["src"]))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    R = a.dir
    tags = sorted(re.match(r"pips_(.+)\.json$", f).group(1)
                  for f in os.listdir(R) if f.startswith("pips_"))
    out = {}
    for tag in tags:
        refp = os.path.join(R, "ref_%s.bit" % tag)
        varp = os.path.join(R, "%s.bit" % tag)
        if not (os.path.exists(refp) and os.path.exists(varp)):
            print("[skip]", tag)
            continue
        ref = frames_from_bit(refp)
        var = frames_from_bit(varp)
        obs = {(x[0], x[1], x[2]) for x in diff_dir(ref, var)}
        pips = json.load(open(os.path.join(R, "pips_%s.json" % tag)))
        pred1, pred0 = set(), set()
        long_pips, other_int = [], 0
        for p in pips:
            t = p["tile"]
            if not (t.startswith("INT_L_X") or t.startswith("INT_R_X")):
                continue
            if is_long(p):
                long_pips.append([t, p["src"], p["sink"]])
            else:
                other_int += 1
            pr = pip_law.predict_family(t, p["sink"], p["src"])
            if pr:
                pred1 |= cells_of(pr, 1)
                pred0 |= cells_of(pr, 0)
        extra = sorted(obs - pred1 - pred0)
        out[tag] = {
            "extra": extra,               # [[f,w,b],...] 预测之外的观测位
            "n_obs": len(obs),
            "long_pips": long_pips,        # [tile, src, sink]
            "n_other_int": other_int,
        }
        print("%-12s obs=%-4d extra=%-4d long_pips=%-2d other_int=%d"
              % (tag, len(obs), len(extra), len(long_pips), other_int))
    with open(a.out, "w") as fh:
        json.dump(out, fh, indent=1, sort_keys=True)
    print("写出", a.out)


if __name__ == "__main__":
    main()
