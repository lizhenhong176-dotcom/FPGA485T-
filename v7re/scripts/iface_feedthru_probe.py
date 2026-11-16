#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""T90 —— 按 tile_type 统计 PIP 的 fan-in 形状（回答「24 源 6×4 是否只属于 INT」）。

输入：路由模板目录（每个 tile_type 一个 json，字段 pip_defs 为 (src, dst) 二元组）。
输出：终端表格 + --json 指定的数据文件。

用法：
    python v7re/scripts/iface_feedthru_probe.py --dir _tif
    python v7re/scripts/iface_feedthru_probe.py --dir /path/templates --json out.json

判据说明：
  - 按 dst（目的 wire）分组，组内 src 数 = 该目的的选择器宽度（fan-in）。
  - n==1 表示 1:1 直通（不需要配置位，等价于 ppip / always-on 连线）。
  - n>=2 才可能需要配置位；所需位数：one-hot = n，二进制 = ceil(log2 n)。
"""
import argparse
import collections
import glob
import io
import json
import math
import os
import sys


def load(path):
    d = json.load(io.open(path, encoding="utf-8"))
    pips = d.get("pip_defs") or []
    by = collections.defaultdict(list)
    for p in pips:
        if len(p) < 2:
            continue
        by[p[1]].append(p[0])
    return pips, by


def profile(path):
    pips, by = load(path)
    dist = collections.Counter(len(v) for v in by.values())
    multis = {n: c for n, c in dist.items() if n >= 2}
    bits_onehot = sum(n * c for n, c in multis.items())
    bits_binary = sum(int(math.ceil(math.log(n, 2))) * c for n, c in multis.items())
    return {
        "file": os.path.basename(path),
        "tile_type": os.path.basename(path).replace(".json", ""),
        "pips": len(pips),
        "dsts": len(by),
        "fanin_hist": dict(sorted(dist.items())),
        "multi_dsts": multis,
        "max_fanin": max(dist) if dist else 0,
        "passthru_dsts": dist.get(1, 0),
        "bits_if_onehot": bits_onehot,
        "bits_if_binary": bits_binary,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True, help="模板目录")
    ap.add_argument("--json", default=None, help="数据输出文件")
    args = ap.parse_args()

    files = sorted(glob.glob(os.path.join(args.dir, "*.json")))
    if not files:
        print("no json under %s" % args.dir)
        return 2

    rows = [profile(f) for f in files]
    rows.sort(key=lambda r: (-r["pips"], r["tile_type"]))

    print("%-26s %7s %7s %6s %8s  %s" % ("tile_type", "pips", "dsts", "maxFan", "pass1to1", "fanin_hist"))
    for r in rows:
        hist = ",".join("%d:%d" % (k, v) for k, v in r["fanin_hist"].items())
        print("%-26s %7d %7d %6d %8d  %s" % (r["tile_type"], r["pips"], r["dsts"], r["max_fanin"],
                                              r["passthru_dsts"], hist))

    print()
    print("== 24 源目的 wire 的 tile 类型 ==")
    hit = [r["tile_type"] for r in rows if r["fanin_hist"].get(24)]
    print(hit if hit else "(none)")

    print()
    print("== 完全无 PIP 的 tile 类型（该类型不承载 PIP 配置）==")
    print([r["tile_type"] for r in rows if r["pips"] == 0] or "(none)")

    print()
    print("== 全部目的都是 1:1 直通的 tile 类型（无 mux，无需配置位）==")
    print([r["tile_type"] for r in rows if r["dsts"] > 0 and r["passthru_dsts"] == r["dsts"]] or "(none)")

    if args.json:
        io.open(args.json, "w", encoding="utf-8").write(
            json.dumps({"dir": args.dir, "tiles": rows}, ensure_ascii=False, indent=1))
        print("\nwrote %s" % args.json)
    return 0


if __name__ == "__main__":
    sys.exit(main())
