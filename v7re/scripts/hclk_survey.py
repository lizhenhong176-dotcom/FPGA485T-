#!/usr/bin/env python3
"""hclk_survey.py —— HCLK_CMT 的 PIP 结构离线摸底（阶段一，0 个构建）。

输入：routing 模板 `HCLK_CMT.json`（982 条 PIP）
输出：`v7re/steps/hclk_sources.json` + 控制台摘要

做四件事：
  1. 每个目的 wire 的完整源列表与源数；
  2. 源名分类（CCIO / CK_BUFHCLK / CK_IN / MUX_CLK_MMCM / MUX_CLK_PLL / 其它）；
  3. 同构判定：同一目的内源索引是否呈「分组 × 组内序号」结构；
  4. 编码候选：按源数与分组能力，列出 one-hot / 二进制 / 两级 三种候选的位宽需求。
"""
import collections
import json
import os
import re
import sys

TPL = os.environ.get(
    "HCLK_TPL",
    r"E:\v7work\_curated_20261021\routing\out_routing\templates\HCLK_CMT.json")
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "steps", "hclk_sources.json")
PREFIX = "HCLK_CMT_"

GROUPS = [
    ("CCIO", re.compile(r"^CCIO(\d+)$")),
    ("CK_BUFHCLK", re.compile(r"^CK_BUFHCLK(\d+)$")),
    ("CK_BUFRCLK", re.compile(r"^CK_BUFRCLK(\d+)$")),
    ("CK_IN", re.compile(r"^CK_IN(\d+)$")),
    ("MUX_CLK_MMCM", re.compile(r"^MUX_CLK_MMCM(\d+)$")),
    ("MUX_CLK_PLL", re.compile(r"^MUX_CLK_PLL(\d+)$")),
    ("PHASERIN", re.compile(r"^PHASERIN_RCLK(\d+)$")),
    ("MUX_MMCM_MUXED", re.compile(r"^MUX_MMCM_MUXED(\d+)$")),
]


def classify(src):
    for name, rx in GROUPS:
        m = rx.match(src)
        if m:
            return name, int(m.group(1))
    return "OTHER", None


def load_pips(path):
    t = json.load(open(path, encoding="utf-8"))
    return [(p[0].replace(PREFIX, ""), p[1].replace(PREFIX, "")) for p in t["pip_defs"]]


def width_needed(n):
    """n 个互斥源要区分，需要的位数下界（二进制编码）。"""
    k = 0
    while (1 << k) < n:
        k += 1
    return k


def main():
    pips = load_pips(TPL)
    by_dst = collections.defaultdict(list)
    for s, d in pips:
        by_dst[d].append(s)

    out = {"template": os.path.basename(TPL), "n_pips": len(pips), "n_dst": len(by_dst),
           "dst": {}}
    print("PIP 总数 %d，目的 wire %d 个\n" % (len(pips), len(by_dst)))
    for dst in sorted(by_dst, key=lambda x: (-len(by_dst[x]), x)):
        srcs = by_dst[dst]
        cls = collections.Counter(classify(s)[0] for s in srcs)
        groups = {}
        for s in srcs:
            g, idx = classify(s)
            groups.setdefault(g, []).append(idx)
        out["dst"][dst] = {
            "n_src": len(srcs),
            "srcs": srcs,
            "groups": {g: sorted(v, key=lambda x: (x is None, x)) for g, v in groups.items()},
            "bin_bits": width_needed(len(srcs)),
            "onehot_bits": len(srcs),
        }
        print("%-34s 源 %2d  二进制≥%d 位  one-hot=%d 位  分组=%s"
              % (dst, len(srcs), width_needed(len(srcs)), len(srcs),
                 dict(cls)))

    # 同构判定：14 个 MUX_CLK 是否共享同一源集合
    muxclk = [d for d in by_dst if re.match(r"^MUX_CLK_\d+$", d)]
    same = len({tuple(sorted(by_dst[d])) for d in muxclk}) == 1
    print("\n14 个 MUX_CLK_k 的源集合完全相同：%s" % same)
    out["mux_clk_identical"] = same
    out["mux_clk_instances"] = sorted(muxclk, key=lambda x: int(x.rsplit("_", 1)[1]))

    # 组内连续性检查：源索引是否在每组内连续
    cont = {}
    for dst, info in out["dst"].items():
        for g, idxs in info["groups"].items():
            real = [i for i in idxs if i is not None]
            if len(real) > 1:
                cont.setdefault(g, set()).add(tuple(real) == tuple(range(min(real), max(real) + 1)))
    print("\n各前缀的组内索引是否连续：")
    for g, v in sorted(cont.items()):
        print("   %-14s %s" % (g, "连续" if v == {True} else "不连续 %s" % v))
    out["group_contiguous"] = {g: (v == {True}) for g, v in cont.items()}

    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1, ensure_ascii=False)
    print("\n写出 %s" % OUT)


if __name__ == "__main__":
    sys.exit(main())
