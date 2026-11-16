"""核对七个 clock region 的行带实验：观测位是否落在 pip_law 预测的格子里。"""
import glob
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pip_law import predict_family  # noqa: E402

ALL = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                  "all_cells.json"), encoding="utf-8"))
FAMILIES = sorted({r["family"] for r in ALL}, key=len, reverse=True)


def main():
    rows = []
    for path in sorted(glob.glob(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                              "bands2", "y*", "diff.json"))):
        y = int(os.path.basename(os.path.dirname(path))[1:])
        tile = f"INT_L_X6Y{y}"
        obs = json.load(open(path, encoding="utf-8"))
        for name, cells in sorted(obs.items()):
            stem = name[2:] if name.startswith("v_") else name
            family = next(f for f in FAMILIES if stem.startswith(f + "_"))
            src = stem[len(family) + 1:]
            ones = {(f, w, b) for f, w, b in cells if w != 50}
            exp = {(f, w, b) for f, w, b, s in predict_family(tile, family, src) if s == 1}
            tag = "EXACT" if ones == exp else ("SUB" if ones and ones <= exp else "FAIL")
            rows.append((y, y // 50, family, len(ones), len(exp), tag,
                         sorted({f for f, _, _ in ones})[:1]))
    for y, r, family, n, m, tag, fr in rows:
        print(f"Y={y:3d} region{r} {family:9s} 观测{n:2d} 预测{m:2d} {tag:5s} 帧{fr}")
    good = sum(1 for r in rows if r[5] in ("EXACT", "SUB"))
    print(f"\n合计 OK {good} / {len(rows)}")


if __name__ == "__main__":
    main()
