#!/usr/bin/env python3
"""§5.6-followup2 绝对值探针：把 SUBSET 的 missing_from_diff 位坐实。

对每个"预测有、diff 没见到"的缺失位（带 sense s），读它在 ref.bit 里的绝对值：
  ref==s   → 该位在 ref 里已是激活值，加 PIP 不翻转 → 差分盲区，V7 确实用它，形状保留 (H1)
  ref==1-s → PIP 没把它置成激活值 → V7 真不用该位，可从该 src 形状精修掉 (H2)

坐标约定与 famdiff 驱动 (famr_run.diffs) 完全一致：
  frames_from_bit 的 payload 帧索引 == diff 的 frame == predict_family 的绝对 frame；
  位值 = (frames[frame][word] >> bit) & 1（大端字，bit 0 = LSB）。
overlay 的 cell 是 (df=frame_off, word, bit) 相对帧；绝对帧 = block_start(col,y)+df。
"""
import json
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "v7re"))
import pip_law  # noqa: E402
from bitstream.parser import frames_from_bit  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
OVERLAY = json.load(open(os.path.join(HERE, "v7_overlay.json"), encoding="utf-8"))
REFS = {
    "INT_R": os.path.join(os.environ.get("TEMP", "/tmp"), "ref_r.bit"),
    "INT_L": os.path.join(os.environ.get("TEMP", "/tmp"), "ref_l.bit"),
}


def base_of(tile):
    _t, col, y = pip_law.parse_tile(tile)
    return pip_law.block_start(col, y)


def main():
    frames = {}
    for side, path in REFS.items():
        if not os.path.exists(path):
            print(f"[abort] 缺 ref: {path}")
            return 2
        frames[side] = frames_from_bit(path)
        print(f"[load] {side} ref {os.path.basename(path)} -> {len(frames[side])} frames")

    # 每个 (probe_tile) 的 base 缓存
    basecache = {}
    # 分类计数：按 side 与 status
    tally = defaultdict(lambda: {"H1_diffblind": 0, "H2_real": 0, "notfound": 0})
    rec_class = defaultdict(lambda: {"H1": 0, "H2": 0, "n": 0})
    h2_examples = []
    total_missing = 0

    for rec in OVERLAY:
        if rec["status"] not in ("SUBSET", "SUBSET_ACT"):
            continue
        side = rec["tile_type"]  # INT_L / INT_R
        tile = rec["probe_tile"]
        if tile not in basecache:
            basecache[tile] = base_of(tile)
        base = basecache[tile]
        # 重算带 sense 的预测：dict (df,w,b)->sense
        rows = pip_law.predict_family(tile, rec["family"], rec["src_wire"])
        sense = {}
        for af, w, b, s in rows:
            sense[(af - base, w, b)] = s
        fr = frames[side]
        for (df, w, b) in rec["missing_from_diff"]:
            total_missing += 1
            if (df, w, b) not in sense:
                tally[side]["notfound"] += 1
                continue
            s = sense[(df, w, b)]
            af = base + df
            ref_val = (fr[af][w] >> b) & 1
            if ref_val == s:
                tally[side]["H1_diffblind"] += 1
                rec_class[(side, "H1")]["n"] += 1
            else:
                tally[side]["H2_real"] += 1
                rec_class[(side, "H2")]["n"] += 1
                if len(h2_examples) < 20:
                    h2_examples.append((side, rec["family"], rec["src_wire"], df, w, b, s, ref_val))

    print("\n=== §5.6-followup2 绝对值探针结果 ===")
    print(f"SUBSET/SUBSET_ACT 缺失位总数: {total_missing}")
    for side in ("INT_L", "INT_R"):
        t = tally[side]
        print(f"  {side}: 差分盲区(H1,保留)={t['H1_diffblind']}  "
              f"真不用(H2,可精修)={t['H2_real']}  未匹配={t['notfound']}")
    if h2_examples:
        print("\nH2 样本 (side, family, src, df, word, bit, sense, ref):")
        for e in h2_examples:
            print("  ", e)
    else:
        print("\n无 H2：所有 SUBSET 缺失位都是差分盲区 → 形状完全成立，无需精修。")

    # 落盘
    out = {
        "total_missing": total_missing,
        "by_side": {s: dict(tally[s]) for s in tally},
        "h2_examples": h2_examples,
        "verdict": ("ALL_DIFF_BLIND" if not h2_examples else "HAS_REAL_OVERPREDICTION"),
    }
    json.dump(out, open(os.path.join(HERE, "followup2_absprobe.json"), "w"),
              ensure_ascii=False, indent=1)
    print("\nWROTE followup2_absprobe.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
