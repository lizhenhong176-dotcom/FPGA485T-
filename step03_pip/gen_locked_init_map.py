#!/usr/bin/env python3
"""gen_locked_init_map.py —— 生成「INIT 索引 -> 位」实测权威表（按 slice 种类各一套）。

为什么按 slice 种类分两套：
  T19（2026-11-06）在 SLICE_X12Y20（tile_type CLBLM_L, inst 0 => SLICEM 切片）用
  LOCK_PINS {I0:A1..I5:A6} 逐位实测 64 条单最小项，得到一套索引顺序。
  T23（2026-11-07）在 SLICE_X11Y20（tile_type CLBLM_R, inst 1 => SLICEL 切片）用完全
  相同的 LOCK_PINS 与 INIT=0xDEADBEEFCAFEBABE 复测，46 个置位点与 law 的 SLICEL 顺序
  逐位全等，而与 T19 的 SLICEM 顺序不等。
  两套顺序之间是一个仿射输入置换 p（见 "permutation" 字段）：
      p(k) = k ^ (0x8 若 k 的 bit0^bit1^bit2^bit3 == 0 否则 0)，列向量
      [0x1,0x2,0x4,0x9,0x10,0x20]，常数项 0x8。
  结论（三色标注）：【数据事实】两套顺序不同且各自由实测确认；【推断】差异来自
  SLICEM/SLICEL 的 LUT6 输入-BEL 引脚对应不同，不是 law 表写错。

因此本表不改 law 的位池（64 个 (rel_off, bit) 对两种切片完全相同），只固定
「索引 -> 位池元素」的对应关系，并按 slice 种类分别给出。

用法：
  python step03_pip/gen_locked_init_map.py            # 生成/覆盖
  python step03_pip/gen_locked_init_map.py --check    # 校验现有文件与实测/law 一致
"""
import argparse
import json
import os
import sqlite3
import sys

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
T19 = os.path.join(ROOT, "v7re", "steps", "clb_init_locked_x12y20_a6lut.json")
T23 = os.path.join(ROOT, "step03_pip", "t23_diff_raw.json")
OUT = os.path.join(ROOT, "v7re", "steps", "clb_init_locked_map.json")
LAW = r"E:\v7work\model\v7_law.sqlite"

T19_ANCHOR = {"slice": "SLICE_X12Y20", "tile_type": "CLBLM_L", "grid_col": 20,
              "inst": 0, "slice_kind": "SLICEM", "base_frame": 31752,
              "group_off": 32, "word": 40, "part": "xc7vx485tffg1157-3"}
T23_ANCHOR = {"slice": "SLICE_X11Y20", "tile_type": "CLBLM_R", "grid_col": 19,
              "inst": 1, "slice_kind": "SLICEL", "base_frame": 31716,
              "group_off": 26, "word": 40, "part": "xc7vx485tffg1157-3",
              "init_value": "0xDEADBEEFCAFEBABE", "observed_bits": 46}
# T21 实测：bel -> [word 增量, bit 增量]；A/B 共 word0，C/D 共 word0+1；B/D 位在 16..31
BEL_RULE = {"A6LUT": [0, 0], "B6LUT": [0, 16], "C6LUT": [1, 0], "D6LUT": [1, 16]}
# law 的 bel 名
LUT_BEL = {"ALUT": "A6LUT", "BLUT": "B6LUT", "CLUT": "C6LUT", "DLUT": "D6LUT"}


def law_conn(law_db=LAW):
    return sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)


def order_from_law(con, tile_type, family):
    d = {int(s[5:-1]): (o, b) for s, o, b in con.execute(
        "SELECT src_wire, frame_off, bit FROM clb_cells "
        "WHERE tile_type=? AND family=? AND src_wire LIKE 'INIT%'", (tile_type, family))}
    if not d:
        return None
    base = min(o for o, _ in d.values())
    return {i: (o - base, b) for i, (o, b) in d.items()}, base


def slm_order_from_t19():
    t19 = json.load(open(T19, encoding="utf-8"))
    if sorted(t19, key=int) != [str(i) for i in range(64)]:
        raise SystemExit("T19 表不是 0..63 全覆盖")
    order = {}
    for i in range(64):
        frame, word, bit = t19[str(i)]
        rel = frame - T19_ANCHOR["base_frame"] - T19_ANCHOR["group_off"]
        if not (0 <= rel <= 3) or not (0 <= bit <= 15) or word != T19_ANCHOR["word"]:
            raise SystemExit("T19 索引 %d 越界: frame=%d word=%d bit=%d" % (i, frame, word, bit))
        order[i] = (rel, bit)
    if len({tuple(v) for v in order.values()}) != 64:
        raise SystemExit("T19 索引不是 64 个互异 (rel,bit)")
    return order


def affine_perm(order_m, order_l):
    """求 p 使 order_l[k] == order_m[p(k)]，并检查 p 是 GF(2) 仿射。"""
    inv = {v: k for k, v in order_m.items()}
    p = {k: inv[order_l[k]] for k in range(64)}
    if len(set(p.values())) != 64:
        return None, "p 不是双射"
    c = p[0]
    cols = [p[1 << b] ^ c for b in range(6)]
    for k in range(64):
        v = c
        for b in range(6):
            if (k >> b) & 1:
                v ^= cols[b]
        if v != p[k]:
            return None, "p 不是仿射（k=%d）" % k
    return {"cols": cols, "const": c,
            "formula": "p(k) = const ^ XOR(cols[b] for b in k 的置位)"}, ""


def build_map(law_db=LAW):
    con = law_conn(law_db)
    try:
        rows = con.execute("SELECT COALESCE(base_frame,0) FROM clb_blocks "
                           "WHERE grid_col=? AND band=0",
                           (T19_ANCHOR["grid_col"],)).fetchone()
    finally:
        pass
    order_m = slm_order_from_t19()
    # SLICEL 顺序：law 的 SLICEL 行（T23 已用实测集合级验证 46/46 全等）
    o_l, base_l = order_from_law(con, T23_ANCHOR["tile_type"], "SLICEL_X1.ALUT")
    if o_l is None:
        raise SystemExit("law 里找不到 SLICEL_X1.ALUT 的 INIT 行")
    if base_l != T23_ANCHOR["group_off"]:
        raise SystemExit("law 的 SLICEL 组基址 %d 与 T23 实测 %d 不符"
                         % (base_l, T23_ANCHOR["group_off"]))
    # 跨 tile_type / 同一 tile 内两个 inst 的一致性
    inconsistent = []
    for tt, fam in [("CLBLM_R", "SLICEL_X1.ALUT"), ("CLBLM_L", "SLICEL_X1.ALUT"),
                    ("CLBLL_L", "SLICEL_X0.ALUT"), ("CLBLL_L", "SLICEL_X1.ALUT"),
                    ("CLBLL_R", "SLICEL_X0.ALUT"), ("CLBLL_R", "SLICEL_X1.ALUT")]:
        got = order_from_law(con, tt, fam)
        if got and got[0] != o_l:
            inconsistent.append((tt, fam))
    for tt, fam in [("CLBLM_L", "SLICEM_X0.ALUT"), ("CLBLM_R", "SLICEM_X0.ALUT")]:
        got = order_from_law(con, tt, fam)
        if got and got[0] != order_m:
            inconsistent.append((tt, fam))
    perm, err = affine_perm(order_m, o_l)
    con.close()
    if inconsistent:
        raise SystemExit("law 的 INIT 索引顺序跨 tile_type 不一致：%s" % inconsistent)
    if perm is None:
        raise SystemExit("SLICEM/SLICEL 两套顺序不满足仿射关系：%s" % err)
    t23 = json.load(open(T23, encoding="utf-8"))[0] if os.path.exists(T23) else None
    t23_obs = None
    if t23:
        t23_obs = {(int(f), int(w), b) for f, per in t23["frames"].items()
                   for w, bits in per.items() if int(w) == T23_ANCHOR["word"] for b in bits}
    t23_pred = {(T23_ANCHOR["base_frame"] + T23_ANCHOR["group_off"] + o_l[k][0],
                 T23_ANCHOR["word"], o_l[k][1])
                for k in range(64) if (int(T23_ANCHOR["init_value"], 16) >> k) & 1}
    return {
        "_note": "由 step03_pip/gen_locked_init_map.py 生成，勿手改；索引顺序按 slice 种类来自实测",
        "kind_rule": "law 的 family 前缀 SLICEM_* => SLICEM 表；SLICEL_* => SLICEL 表",
        "bel_rule": BEL_RULE,
        "orders": {"SLICEM": {str(i): list(order_m[i]) for i in range(64)},
                   "SLICEL": {str(i): list(o_l[i]) for i in range(64)}},
        "group_off": {"SLICEM": T19_ANCHOR["group_off"],
                      "SLICEL": T23_ANCHOR["group_off"],
                      "note": "law 各 family 的 INIT 行最小 frame_off；构建时以 law 实测值为准并核对"},
        "permutation": perm,
        "measurements": {
            "SLICEM": {"evidence": "T19 单最小项逐位 64 条 + T21 bel/行不变性 + T22 行界 word 平移",
                       "anchor": T19_ANCHOR},
            "SLICEL": {"evidence": "T23 单构建集合级复测（46/46 全等）",
                       "anchor": T23_ANCHOR,
                       "observed_bits": len(t23_obs) if t23_obs else None,
                       "matched": (t23_obs == t23_pred) if t23_obs else None},
        },
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    fresh = build_map()
    if a.check:
        cur = json.load(open(OUT, encoding="utf-8"))
        same = all(cur.get(k) == fresh.get(k) for k in
                   ("orders", "bel_rule", "permutation", "group_off"))
        print("CHECK:", "PASS 现有 map 与实测/law 一致" if same
              else "FAIL map 已过期，请重跑生成")
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        json.dump(fresh, f, ensure_ascii=False, indent=2, sort_keys=True)
        f.write("\n")
    print("写入 %s" % OUT)
    print("  SLICEM 顺序 = T19 实测；SLICEL 顺序 = law SLICEL 行（T23 集合级复核 matched=%s）"
          % fresh["measurements"]["SLICEL"]["matched"])
    print("  两套顺序的仿射置换：cols=%s const=%d"
          % ([hex(c) for c in fresh["permutation"]["cols"]], fresh["permutation"]["const"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
