import collections
import io
import json
import sys
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
sys.path.insert(0, str(ROOT / "v7re" / "scripts"))
sys.path.insert(0, str(ROOT / "v7re"))
sys.path.insert(0, str(ROOT / "step03_pip"))

import tamper_localize as tl
import g2_exact_cover as g
import p1_replication as p1
import p1_replication_cells as pc

D = ROOT / "tamper" / "ref" / "p1" / "remote" / "out"
TPL = Path(r"E:/v7work/_curated_20261021/routing/out_routing/templates")

W = tl.World()
fan = collections.Counter()
try:
    t = json.load(io.open(TPL / "INT_R.json", encoding="utf-8"))
    for src, dst, _d, _i in t["pip_defs"]:
        fan[dst] += 1
except Exception as e:
    print("template warn", e)

poolset = None
tot = collections.Counter()
per = {}
for cf in sorted(D.glob("*.cells.txt")):
    name = cf.name[:-len(".cells.txt")]
    truth_raw = g.load_truth(str(D / (name + ".pips")))
    cm, pool, cells_of, idx = p1.build_pool(W, truth_raw)
    poolset = {(s, d) for d, s in pool}
    truth = {t2: {(cm[d], cm[s]) for d, s in v} for t2, v in truth_raw.items()}
    obs = pc.obs_from_cells(W, cf)
    c = collections.Counter()
    drift = []
    for ti, o in obs.items():
        tn = W.tiles[ti][0]
        target = set(o) - g.WHITELIST
        if not target:
            continue
        cand = [i for i, x in enumerate(cells_of) if x <= o]
        cover = set()
        for i in cand:
            cover |= cells_of[i]
        target = target & cover
        sols, trunc, orphan, _ = g.enumerate_exact(cand, cells_of, target, 200, 400_000)
        if not sols:
            c["不再有解"] += 1
            continue
        got = {pool[i] for i in next(iter(sols))}
        T = truth.get(tn, set())
        for dst, src in T - got:
            if src in ("GND_WIRE", "VCC_WIRE"):
                c["常量源(无位,结构上不可检出)"] += 1
            elif fan.get(dst, 1) <= 1:
                c["扇入=1(无位,结构上不可检出)"] += 1
            elif src.startswith("GCLK") or dst in ("CLK0", "CLK1", "GFAN0", "GFAN1"):
                c["时钟/全局缓冲族(不在 172 族模型内)"] += 1
            else:
                c["真漏(有位未解出)"] += 1
                drift.append((tn, dst, src))
    per[name] = {"fn": dict(c), "misses": drift[:20]}
    tot.update(c)
    print("%-12s %s" % (name, dict(c)))
print("\n合计：", dict(tot))
p = ROOT / "step03_pip" / "out" / "p1_residual.json"
io.open(p, "w", encoding="utf-8", newline="\n").write(
    json.dumps({"per_design": per, "total": dict(tot)}, ensure_ascii=False, indent=1))
print("→", p)
