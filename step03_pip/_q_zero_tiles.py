import collections
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
W = tl.World()
for name in ("d5_srl", "d3_carry"):
    truth_raw = g.load_truth(str(D / (name + ".pips")))
    cm, pool, cells_of, idx = p1.build_pool(W, truth_raw)
    truth = {t: {(cm[d], cm[s]) for d, s in v} for t, v in truth_raw.items()}
    obs = pc.obs_from_cells(W, D / (name + ".cells.txt"))
    n = 0
    for ti, o in obs.items():
        target = set(o) - g.WHITELIST
        if not target:
            continue
        cand = [i for i, c in enumerate(cells_of) if c <= o]
        sols, trunc, orphan, _ = g.enumerate_exact(cand, cells_of, target, 200, 400_000)
        if sols:
            continue
        cover = set()
        for i in cand:
            cover |= cells_of[i]
        miss = target - cover
        tn = W.tiles[ti][0]
        print("%s %s target=%d miss=%d obs=%s" % (name, tn, len(target), len(miss), sorted(target)))
        print("   truth:", sorted(truth.get(tn, ())))
        n += 1
        if n >= 3:
            break
