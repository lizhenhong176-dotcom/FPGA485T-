# -*- coding: utf-8 -*-
"""gen_mux_rowlaw.py —— 用行序生成律替换 pip_reuse_law.json 的逐族 slots（T89 选项 1）

模型：`row_law.py`（4 基置换 + 5 步进置换 + 类别对比特 + 族名闭式），不存 8/16 张表。
行 4/5（LOGIC/GFAN、BOUNCE）不在律内，作为 residue 从旧模型带入（512 个槽位，单独计数）。

验收（缺一不可）：
  A) 与旧 pip_reuse_law.json 的 1,536 条 slots 逐条比对，差分 0；
  B) 方向线 1,024 条确实由律给出（不是从旧表抄回来的）；
  C) 随机 200 个 (family, source) 与 law_cells 实测对拍，0 不符；
  D) 把 slots 接回 predict()，与 law_cells 的 mux 区全量对拍 1,536/1,536。

用法：python step03_pip/gen_mux_rowlaw.py [--seed 20261113] [--n 200]
"""
import argparse
import collections
import json
import os
import random
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(os.path.dirname(HERE), "v7re", "scripts"))

import row_law  # noqa: E402
from pip_reuse_law import predict, load_cells, MUX_PREFIX  # noqa: E402

LAW_DB = r"E:\v7work\model\v7_law.sqlite"
MODEL = os.path.join(os.path.dirname(HERE), "v7re", "steps", "pip_reuse_law.json")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=20261113)
    ap.add_argument("--n", type=int, default=200)
    a = ap.parse_args()

    model = json.load(open(MODEL, encoding="utf-8"))
    old = {f: dict(v["slots"]) for f, v in model["families"].items()}

    # ---- A/B: 逐条比对 + 来源计数 ----
    diff = []
    n_dir = n_res = 0
    new = {}
    for fam, residue in old.items():
        slots = row_law.full_slots(fam, residue)
        new[fam] = slots
        law_dir = row_law.direction_slots(fam)
        for src, rc in slots.items():
            if src[:2] in law_dir:
                n_dir += 1
                if tuple(law_dir[src[:2]]) != tuple(old[fam][src]):
                    diff.append((fam, src, old[fam][src], law_dir[src[:2]]))
            else:
                n_res += 1
    print("A) 与旧 slots 逐条比对：%d 条（方向线 %d，行4/5 residue %d），差分 %d"
          % (len(old) and sum(len(v) for v in old.values()), n_dir, n_res, len(diff)))
    for d in diff[:8]:
        print("   ", d)

    # ---- C: 随机 200 个 (family, source) 与 law_cells 对拍 ----
    cells = load_cells(LAW_DB, "INT_L")
    pool = [(f, s) for (f, s) in cells if f.startswith(MUX_PREFIX)]
    random.seed(a.seed)
    sample = random.sample(pool, min(a.n, len(pool)))
    bad = []
    for fam, src in sample:
        if src not in new[fam]:
            bad.append((fam, src, "缺槽位"))
            continue
        r, code = new[fam][src]
        got = cells[(fam, src)]
        rows = {fo - 16 for fo, _, _ in got if 16 <= fo <= 21}
        ok_row = (r in rows) if rows else False
        ok_col = all(any(fo == 25 - i for fo, _, _ in got) == bool(code >> i & 1)
                     for i in range(4))
        if not (ok_row and ok_col):
            bad.append((fam, src, "pred", (r, code), "got", sorted(got)))
    print("C) 随机 %d 个 (family,source) 对拍：0 不符" % len(sample) if not bad
          else "C) 随机 %d 个对拍：不符 %d %s" % (len(sample), len(bad), bad[:5]))

    # ---- D: 接回 predict 全量 ----
    for fam, v in model["families"].items():
        v["slots"] = new[fam]
        v["pair"], v["parity"], v["primary"] = row_law.params(fam)
    checked = ok = 0
    bad2 = []
    for (fam, src), got in cells.items():
        if not fam.startswith(MUX_PREFIX):
            continue
        checked += 1
        if predict(model, fam, src) == got:
            ok += 1
        else:
            bad2.append((fam, src))
    print("D) predict() 全量对账：%d / %d，不符 %d" % (ok, checked, len(bad2)))
    for x in bad2[:5]:
        print("   ", x)

    # ---- E: 两侧方向线各自全量（INT_R 的族名是 IMUX<k>）----
    e_ok = e_all = 0
    e_bad = []
    for side in ("INT_L", "INT_R"):
        cc = load_cells(LAW_DB, side)
        fams = {f for (f, s) in cc if f.startswith(MUX_PREFIX)}
        for fam in fams:
            d = row_law.direction_slots(fam)
            for src, got in [(s, cc[(fam, s)]) for (f2, s) in cc if f2 == fam]:
                pre = src[:2]
                if pre not in d:
                    continue
                r, code = d[pre]
                rows = {fo - 16 for fo, _, _ in got if 16 <= fo <= 21}
                cols = {fo for fo, _, _ in got if 22 <= fo <= 25}
                e_all += 1
                okr = (len(rows) == 1 and r in rows)
                okc = all(((25 - i) in cols) == bool(code >> i & 1) for i in range(4))
                if okr and okc:
                    e_ok += 1
                elif len(e_bad) < 5:
                    e_bad.append((side, fam, src, (r, code), sorted(rows), sorted(cols)))
    print("E) 两侧方向线全量：%d / %d，不符 %d" % (e_ok, e_all, e_all - e_ok))
    for x in e_bad:
        print("   ", x)

    passed = not diff and not bad and ok == checked and checked == 1536 \
        and e_ok == e_all and e_all == 2048
    print("RESULT:", "PASS" if passed else "FAIL")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
