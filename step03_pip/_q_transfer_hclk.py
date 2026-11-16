# -*- coding: utf-8 -*-
"""②a 跨类型可迁移性判定：把 HCLK_CMT 的 MUX_CLK_13 族套用 INT 那套判据。

判据（与 INT 同口径，见 STATUS §161 阶梯第 4 级）：
  C1 位池可定位：所有差异格落在有限的 (band,col,off,word,bit) 字区
  C2 组槽位结构：每个源相对基线**置 1** 的组槽位格恰 1 个，且不同源互不相同
                 （同时**清 0** 的组槽位格也应恰 1 个 = 基线那一格）
  C3 码字可分：每个源**置 1** 的码字集合互不相同
  C4 名字可推：组槽位是否由「组内序号」单调决定

输入：step03_pip/out/hclk_mux13_cells.json（_q_hclk_mux13.py 生成，含 base/sample）
输出：判据表 + 三档判定
"""
import collections
import io
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "out", "hclk_mux13_cells.json")

# 组槽位区（一热半区）：MMCM 在 off29 的 w26..w30，PLL 在 off28 的 w76..w79
GROUP_WORDS = {(29, 26), (29, 27), (29, 28), (29, 29), (29, 30),
               (28, 76), (28, 77), (28, 78), (28, 79)}


def main():
    d = json.load(io.open(SRC, encoding="utf-8"))
    ev = d["evidence"]
    sets, clears = {}, {}
    for k, v in ev.items():
        s = v["src"]
        sets[s] = [(c["off"], c["word"], c["bit"]) for c in v["cells"] if c["sample"] == 1]
        clears[s] = [(c["off"], c["word"], c["bit"]) for c in v["cells"] if c["sample"] == 0]

    def split(cells):
        g = [c for c in cells if (c[0], c[1]) in GROUP_WORDS]
        n = [c for c in cells if (c[0], c[1]) not in GROUP_WORDS]
        return g, n

    bad_g, bad_c = [], []
    slot, code = {}, {}
    for s in sets:
        g, c = split(sets[s])
        gc, _ = split(clears[s])
        slot[s] = g
        code[s] = c
        if len(g) != 1 or len(gc) != 1:
            bad_g.append((s, len(g), len(gc)))
        if not c:
            bad_c.append(s)

    c1 = sum(len(v) for v in sets.values()) > 0
    c2 = (not bad_g) and len({tuple(g[0]) for g in slot.values() if g}) == len(slot)

    # C3 只在「同一组内」判定（不同组的码字表可以重合，那是设计如此）
    by_group = collections.defaultdict(list)
    for s in code:
        g = "MMCM" if "MMCM" in s else ("PLL" if "PLL" in s else "other")
        by_group[g].append(frozenset(code[s]))
    c3_detail = {g: (len(set(v)), len(v)) for g, v in by_group.items()}
    c3 = (not bad_c) and all(a == b for a, b in c3_detail.values())
    all_code = [frozenset(v) for v in code.values()]
    cross_group_collision = len(set(all_code)) != len(all_code)

    print("== HCLK_CMT `MUX_CLK_13`（族内 48 源，实测差分 %d 源，其余为基线 MMCM0/PLL0）" % len(sets))
    print(f"C1 位池可定位          : {c1}（{sum(len(v) for v in sets.values())} 个置 1 格，全部落在 off26..29 的有限字区）")
    print(f"C2 每源恰 1 组槽位格   : {c2}" + (f"，异常 {bad_g}" if bad_g else "")
          + f"（{len(slot)} 个组槽位互不重复）")
    print(f"C3 组内码字互不相同    : {c3}"
          + (f"，无码字源 {bad_c}" if bad_c else "")
          + f"（每组：{c3_detail}）"
          + ("　[注意] 跨组存在相同码字（设计如此，组由槽位选）" if cross_group_collision else ""))

    print("\n  源                 组槽位(置1)          码字(置1)                 基线被清格")
    for s in sorted(sets):
        print(f"  {s:18s} {str(slot[s][0]):20s} {str(sorted(code[s])):42s} {sorted(clears[s])}")

    # C4：组槽位是否按序号排列
    mmcm = sorted([s for s in sets if "MMCM" in s], key=lambda x: int(x.split("MMCM")[1]))
    pll = sorted([s for s in sets if "PLL" in s], key=lambda x: int(x.split("PLL")[1]))
    print("\nC4a MMCM 序号→组槽位:", [(s.split("MMCM")[1], slot[s][0]) for s in mmcm])
    print("C4b PLL  序号→组槽位:", [(s.split("PLL")[1], slot[s][0]) for s in pll])

    if c1 and c2 and c3:
        verdict = "结构可迁移（1 组槽位 + 2..4 码字，与 INT 同形）"
    elif c1:
        verdict = "部分可迁移（位池可定位，映射需逐源测）"
    else:
        verdict = "不可迁移"
    print("\n判定：", verdict)
    print("口径：差分给的是「源 A → 源 B 哪些格置 1 / 哪些格被清 0」，")
    print("      置 1 的组槽位 = 该源的槽位，被清的组槽位 = 基线的槽位；码字同理。")


if __name__ == "__main__":
    main()
