"""hclk_observe.py — 用「观测法」（INT 那一套）汇总 HCLK_CMT 的选中源与簇内格。

用法：python v7re/scripts/hclk_observe.py [--dirs _h48 _ha2 _ccio_out _ck2 _ck3]
输出：每个 (CK_IN13 源, CLKIN1 源) 组合的设计数与归一化簇内格。
"""
import sys, os, io, re, glob, collections
import numpy as np
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))
from bitstream.parser import frames_from_bit

CLUSTERS = {"X88": 22144, "X305": 25090}
WORDS = (48, 49, 51)
SPAN = 14


def edges(p):
    t = io.open(p, encoding="utf-8", errors="replace").read()
    d = collections.defaultdict(list)
    for a, b in re.findall(r"(HCLK_CMT_\w+)->>(HCLK_CMT_\w+)", t):
        d[b].append(a)
    cols = set(re.findall(r"HCLK_CMT_[LR]_X(88|305)Y\d+", t))
    return d, cols


def cells(bit, base):
    a = np.array(frames_from_bit(bit), dtype=np.uint32)
    out = {}
    for fi in range(base, base + SPAN):
        for w in WORDS:
            v = int(a[fi][w])
            s = []
            while v:
                b = (v & -v).bit_length() - 1
                s.append(b)
                v &= v - 1
            if s:
                out[(fi - base, w)] = tuple(s)
    return out


def main(dirs):
    rows = []
    for d in dirs:
        for bp in sorted(glob.glob(d + "/*.bit")):
            pp = bp[:-4] + ".pips"
            if not os.path.exists(pp):
                continue
            e, cols = edges(pp)
            if not e:
                continue
            for c in cols:
                rows.append((bp, "X" + c,
                             tuple(sorted(e.get("HCLK_CMT_CK_IN13", []))),
                             tuple(sorted(e.get("HCLK_CMT_MUX_MMCM_CLKIN1", []))),
                             cells(bp, CLUSTERS["X" + c])))
    g = collections.defaultdict(list)
    for r in rows:
        g[(r[1], r[2], r[3])].append(r)
    print("designs=%d combos=%d" % (len(rows), len(g)))
    for k, v in sorted(g.items(), key=lambda x: -len(x[1])):
        print("\ncol=%s CK_IN13=%s CLKIN1=%s  设计数=%d  例=%s"
              % (k[0], k[1], k[2], len(v), os.path.basename(v[0][0])))
        print("  cells:", v[0][4])


if __name__ == "__main__":
    ds = sys.argv[2:] if len(sys.argv) > 2 and sys.argv[1] == "--dirs" else \
         ["_h48", "_ha2", "_ccio_out", "_ck2", "_ck3"]
    main(ds)
