# -*- coding: utf-8 -*-
"""6 个长线族（82 条 feature）的结构与「能否由名字推出」的判据。

用法：python step03_pip\\_q_longline_struct.py
输出：每族的源/格/二分性/是否完全二分/跨族共享格；H1（几何类别→格对）与
      H2（方向类→二分 A 侧）两条候选规则的命中率。
数据：E:\\v7work\\model\\v7_law.sqlite 表 law_cells（tile_type='INT_L', sense=1）。
结论（2026-11-11 实测）：H1 6/22 唯一、H2 非函数 → 82 条属逐族表数据。
"""
import collections
import io
import re
import sqlite3

DB = r"E:\v7work\model\v7_law.sqlite"
FAMS = ["LH0", "LH12", "LVB_L0", "LVB_L12", "LV_L0", "LV_L18"]


def fam_cells(con, fam, tile="INT_L"):
    d = collections.defaultdict(set)
    for s, fo, b, p in con.execute(
            "select src_wire,frame_off,bit,parity from law_cells "
            "where tile_type=? and sense=1 and family=?", (tile, fam)):
        d[s].add((fo, b, p))
    return d


def two_color(edges):
    """源=边、格=点：返回 2-着色（点→0/1），非二分返回 None。"""
    g = collections.defaultdict(set)
    for cs in edges.values():
        a, b = sorted(cs)
        g[a].add(b)
        g[b].add(a)
    color = {}
    for n in sorted(g):
        if n in color:
            continue
        color[n] = 0
        st = [n]
        while st:
            u = st.pop()
            for v in g[u]:
                if v not in color:
                    color[v] = 1 - color[u]
                    st.append(v)
                elif color[v] == color[u]:
                    return None
    return color


def geo(s):
    s2 = s.replace("LOGIC_OUTS_L", "LOGIC_OUTS").replace("_L", "")
    m = re.match(r"^([NSEW]{1,2})(\d)", s2)
    if m:
        return "dir" + m.group(1)
    if s2.startswith(("LVB", "LV", "LH", "ER", "WR", "NR", "SR")):
        return "long"
    return "other"


def main():
    con = sqlite3.connect(DB)
    cell_owner = collections.defaultdict(set)
    h1_tot = h1_uniq = 0
    for fam in FAMS:
        d = fam_cells(con, fam)
        cells = {c for cs in d.values() for c in cs}
        sizes = collections.Counter(len(cs) for cs in d.values())
        col = two_color(d)
        by_geo = collections.defaultdict(set)
        for s, cs in d.items():
            by_geo[geo(s)].add(frozenset(cs))
        for g, v in by_geo.items():
            h1_tot += 1
            h1_uniq += 1 if len(v) == 1 else 0
        complete = False
        if col:
            a_side = {k for k, v in col.items() if v == 0}
            b_side = set(col) - a_side
            complete = len(d) == len(a_side) * len(b_side)
        for c in cells:
            cell_owner[c].add(fam)
        print(f"== {fam}: 源 {len(d)} / 格 {len(cells)} / 每源格数 {dict(sizes)} "
              f"/ 二分 {col is not None} / 完全二分 {complete}")
        if col:
            print("   A 侧", sorted(k for k, v in col.items() if v == 0))
            print("   B 侧", sorted(k for k, v in col.items() if v == 1))
    shared = {c: sorted(f) for c, f in cell_owner.items() if len(f) > 1}
    print("跨族共享格:", shared)
    print(f"H1 方向类→格对唯一：{h1_uniq}/{h1_tot}")

    # H2：同一族内「方向类 → 二分 A 侧格」是否唯一（是则 A 侧由方向决定）
    h2_tot = h2_uniq = 0
    for fam in FAMS:
        d = fam_cells(con, fam)
        col = two_color(d)
        if not col:
            continue
        by_dir = collections.defaultdict(set)
        for s, cs in d.items():
            a, b = sorted(cs)
            by_dir[geo(s)].add(a if col[a] == 0 else b)
        for g, v in by_dir.items():
            h2_tot += 1
            h2_uniq += 1 if len(v) == 1 else 0
    print(f"H2 方向类→A 侧格唯一：{h2_uniq}/{h2_tot}")


if __name__ == "__main__":
    main()
