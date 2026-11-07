#!/usr/bin/env python3
"""t21_crosscheck.py — T21 交叉自证：用 T19 的单比特锁引脚表逐 bel/行平移，与 T21 实测差分比对。

用法:
  python step03_pip/t21_crosscheck.py [step03_pip/t21_diff_raw.txt] [v7re/steps/clb_init_locked_x12y20_a6lut.json]

判据: 每个 pair 必须 printed 四个数 (pred / act / missing / extra)，且 missing=0 且 extra=0。
不是抽样校验：集合级比对全部预测位。
"""
import json, sys, os

BASE = 31716
VAL = 0xDEADBEEFCAFEBABE

def main(raw_path, t19_path):
    t19 = json.load(open(t19_path, encoding="utf-8"))
    raw = open(raw_path, encoding="utf-8", errors="replace").read()
    i, j = raw.find("JSON_BEGIN"), raw.find("JSON_END")
    if i < 0 or j < 0:
        raise SystemExit("找不到 JSON_BEGIN/JSON_END 包裹的差分结果")
    data = json.loads(raw[i + len("JSON_BEGIN"):j].strip())

    # T19 表: index -> [绝对 frame, word(40), bit(0..15)]，索引 i 对应 INIT 的第 i 位。
    pred_a = {(f, w, b) for i in range(64) if (VAL >> i) & 1
              for (f, w, b) in [tuple(t19[str(i)])]}
    if len(pred_a) != bin(VAL).count("1"):
        print("WARN T19 表内 (frame,word,bit) 有重复，去重后 %d != popcount %d"
              % (len(pred_a), bin(VAL).count("1")))

    # pair -> (数据字相对 w0(y=20) 的偏移, 位块偏移)
    cfg = {
        "A_y20": (0, 0),
        "B_y20": (0, 16),
        "C_y20": (1, 0),
        "D_y20": (1, 16),
        "A_y21": (2, 0),   # y=21 -> w0 = 2*21 = 42 = 40 + 2
    }
    bad = 0
    print("pair      pred  act  missing  extra")
    for name, (dw, db) in cfg.items():
        pred = {(f, w + dw, b + db) for (f, w, b) in pred_a}
        word = 40 + dw
        act = {(f + BASE, w, b) for (f, w, b) in data[name]["cells"] if w == word}
        miss, extra = pred - act, act - pred
        print("%-8s  %4d  %3d  %7d  %5d" % (name, len(pred), len(act), len(miss), len(extra)))
        if miss or extra:
            bad += 1
            print("   missing:", sorted(miss)[:8])
            print("   extra  :", sorted(extra)[:8])
    print("RESULT %s" % ("PASS" if not bad else "FAIL (%d pair 不一致)" % bad))
    return 0 if not bad else 1

if __name__ == "__main__":
    here = os.path.dirname(os.path.abspath(__file__))
    raw = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "t21_diff_raw.txt")
    t19 = sys.argv[2] if len(sys.argv) > 2 else os.path.join(here, "..", "v7re", "steps", "clb_init_locked_x12y20_a6lut.json")
    sys.exit(main(raw, t19))
