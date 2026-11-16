"""生成「复用规律」图解三张图（真实数据，不手绘数字）。

图 1  law_1_reuse.png     一个 mux 族（IMUX_L40）：24 个源 → 10 个物理格
图 2  law_2_codes.png     64 个 mux 族 → 16 种行序码 + S4 生成链
图 3  law_3_coverage.png  覆盖分层 + 缺口

数据源：E:\\v7work\\model\\v7_law.sqlite 的 law_cells 表、step03_pip/_row_s4.py 的统计。
"""

from __future__ import annotations

import collections
import os
import sqlite3
import sys

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt  # noqa: E402
from matplotlib.patches import FancyArrowPatch, FancyBboxPatch, Rectangle  # noqa: E402

LAW = r"E:\v7work\model\v7_law.sqlite"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "steps", "figs_law")
FAMILY = "IMUX_L40"

plt.rcParams["font.family"] = ["Microsoft YaHei", "SimHei", "DejaVu Sans"]
plt.rcParams["axes.unicode_minus"] = False


def load_family(family: str):
    con = sqlite3.connect(LAW)
    rows = con.execute(
        "select src_wire, src_index, frame_off, bit, parity from law_cells"
        " where tile_type='INT_L' and family=?",
        (family,),
    ).fetchall()
    con.close()
    per_src: dict[str, set] = collections.OrderedDict()
    for src, idx, fo, bit, par in sorted(rows, key=lambda r: (r[1] if r[1] is not None else 999, r[2])):
        per_src.setdefault(src, set()).add((fo, bit, par))
    return per_src


def fig1():
    per_src = load_family(FAMILY)
    cells = sorted({c for v in per_src.values() for c in v})
    row_cells = [c for c in cells if c[0] <= 21]
    col_cells = [c for c in cells if c[0] >= 22]
    src_row = {s: [c for c in v if c[0] <= 21][0] for s, v in per_src.items()}

    fig, ax = plt.subplots(figsize=(13.4, 6.1))
    ax.set_xlim(0, 13.4)
    ax.set_ylim(3.05, 8.45)
    ax.axis("off")

    by_row: dict[int, list[str]] = collections.OrderedDict()
    for s, c in src_row.items():
        by_row.setdefault(c[0], []).append(s)

    rows_y = {}
    y0 = 7.60
    for fo in sorted(by_row):
        names = by_row[fo]
        for j, name in enumerate(names):
            x = 0.30 + j * 1.32
            ax.add_patch(Rectangle((x, y0 - 0.40), 1.20, 0.40, facecolor="#e8f0fb",
                                   edgecolor="#4a6fa5", lw=0.8))
            ax.text(x + 0.60, y0 - 0.20, name, ha="center", va="center", fontsize=6.4,
                    color="#1f3550")
        rows_y[fo] = y0 - 0.20
        y0 -= 0.62

    rc_y = {}
    y = 7.60
    for c in row_cells:
        ax.add_patch(Rectangle((6.30, y - 0.40), 1.70, 0.40, facecolor="#ffe9c7",
                               edgecolor="#b5761a", lw=0.9))
        ax.text(7.15, y - 0.20, f"帧 {c[0]} · bit {c[1]}", ha="center", va="center", fontsize=7.2)
        rc_y[c] = y - 0.20
        y -= 0.62

    # 每行 4 源合并成一条水平线接到行格
    for c, yy in rc_y.items():
        ax.plot([5.42, 6.30], [yy, yy], color="#4a6fa5", lw=1.2, alpha=0.8)
        ax.plot([5.30, 5.42], [yy, yy], color="#4a6fa5", lw=2.6, alpha=0.55)
    ax.text(5.85, 3.42, "4 源共用 1 格", fontsize=7.4, color="#4a6fa5", ha="center")

    bus_x = 8.75
    ys = [7.40, 6.78, 6.16, 5.54]
    ax.plot([bus_x, bus_x], [ys[0], ys[-1]], color="#2f7d4f", lw=1.8, alpha=0.85)
    for c, yy in zip(col_cells, ys):
        ax.add_patch(Rectangle((9.60, yy - 0.20), 3.0, 0.40, facecolor="#d9f2e0",
                               edgecolor="#2f7d4f", lw=0.9))
        ax.text(11.10, yy, f"帧 {c[0]} · bit {c[1]}　全族共用", ha="center", va="center", fontsize=7.2)
        ax.add_patch(FancyArrowPatch((bus_x, yy), (9.60, yy), arrowstyle="-|>",
                                     mutation_scale=10, lw=1.4, color="#2f7d4f", alpha=0.85))
    ax.text(bus_x, 3.42, "24 源共用 4 格", fontsize=7.4, color="#2f7d4f", ha="center")

    ax.text(0.30, 8.32, f"{FAMILY}：24 个源 → 只有 {len(cells)} 个物理格", fontsize=12.5, weight="bold")
    ax.text(0.30, 8.06, "6 个「行格」（帧 16–21，每格 4 源共用）× 4 个「列格」（帧 22–25，24 源共用）",
            fontsize=8.4, color="#444")
    ax.text(0.30, 3.72, "24 源 × 每源 5 个 (源,格) 引用 = 120 条记录 → 折叠成 10 个真实存储位",
            fontsize=8.8, color="#1f3550")
    ax.text(0.30, 3.40, "这就是「复用」：逻辑上 24 选 1，物理上只有 10 个配置位", fontsize=9.2,
            weight="bold", color="#1f3550")
    fig.tight_layout()
    p = os.path.join(OUT, "law_1_reuse.png")
    fig.savefig(p, dpi=170)
    plt.close(fig)
    return p, len(cells)


ORDER = [["NE", "NW", "SE", "SW"], ["NN", "EE", "WW", "SS"],
         ["NR", "ER", "WR", "SR"], ["NL", "EL", "WL", "SL"]]


def row_code(con, side, fam):
    """行序码：四个方向类各 4 个源，各自落在 row = frame_off-16 的哪一行。"""
    rows = con.execute(
        "select src_wire, frame_off from law_cells where tile_type=? and family=?", (side, fam)
    ).fetchall()
    on: dict[str, set] = collections.defaultdict(set)
    for src, fo in rows:
        if 16 <= fo <= 19:
            on[src[:2]].add(fo - 16)
    out = []
    for cls in ORDER:
        for name in cls:
            if len(on[name]) != 1:
                return None
        out.append("".join(str(next(iter(on[name]))) for name in cls))
    return " ".join(out)


def fig2():
    con = sqlite3.connect(LAW)
    all_fams = [r[0] for r in con.execute(
        "select distinct family from law_cells where tile_type='INT_L'")]
    fams = [f for f in all_fams if "IMUX" in f or f.startswith("BYP_ALT") or f.startswith("FAN_ALT")]
    codes = {}
    for f in fams:
        v = row_code(con, "INT_L", f)
        if v is not None:
            codes[f] = v
    con.close()
    hist = collections.Counter(codes.values())

    fig, axes = plt.subplots(1, 2, figsize=(14.2, 5.6), gridspec_kw={"width_ratios": [1.35, 1]})

    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.4)
    ax.axis("off")
    ax.text(0, 6.30, f"行序不是随机的：{len(codes)} 个族只出现 {len(hist)} 种码，每码 {list(hist.values())[0]} 族",
            fontsize=11, weight="bold", va="top")
    ax.text(0, 5.92, "把「哪个源放第几行」看成一个置换 p，它由固定字母表逐步生成：p_{j+1} = g_j ∘ p_j",
            fontsize=8.4, color="#444", va="top")

    def chain(y, title, gates, tail, tcolor):
        ax.text(0, y + 0.62, title, fontsize=9.2, weight="bold", color=tcolor)
        n = len(gates) + 1
        for i in range(n):
            x = 0.10 + i * 1.22
            lab = f"p{i}" + ("'" if i == len(gates) else "")
            ax.add_patch(FancyBboxPatch((x, y), 0.62, 0.40, boxstyle="round,pad=0.03",
                                        facecolor="#eef4fd", edgecolor="#4a6fa5", lw=0.9))
            ax.text(x + 0.31, y + 0.20, lab, ha="center", va="center", fontsize=8.6)
            if i < len(gates):
                ax.add_patch(FancyArrowPatch((x + 0.64, y + 0.20), (x + 1.20, y + 0.20),
                                             arrowstyle="-|>", mutation_scale=9, lw=1.0,
                                             color="#666"))
                ax.text(x + 0.92, y + 0.30, gates[i], ha="center", va="bottom", fontsize=8.4,
                        color=tcolor)
        ax.text(0, y - 0.42, tail, fontsize=8.0, color="#555")

    chain(4.35, "DIAG / ORTH 类（周期 8）", ["r³", "ρ", "r³", "e", "r³", "ρ", "r³"],
          "走满 7 步回到 p0：DIAG/ORTH 的 8 步是一条真正的闭环", "#1f3550")
    chain(2.55, "R / L 类（周期 4，不是 8）", ["r", "ρ", "r", "X2", "r", "ρ", "r"],
          "走满 7 步回到 p3：j=3 的 X2 是断裂点，用 ρ 共轭三种写法都闭合不了（已证伪）", "#7a4b12")

    ax.text(0, 1.72, "例（BYP_ALT0，每段 4 位 = 该类四根线各落在第几行，行号 0..5）", fontsize=8.2,
            weight="bold")
    ax.text(0, 1.40, "3120  3210  3102  2013", fontsize=11.5, color="#1f3550")
    ax.text(0, 1.06, "基置换 p0 只有 4 个，四类各一个；其余 7 步全部由字母表决定", fontsize=8.0,
            color="#555")

    ax = axes[1]
    ax.axis("off")
    ax.text(0.0, 1.0, "置换字母表只有 5 个元素", fontsize=11, weight="bold", va="top")
    ax.text(0.0, 0.905, "p_{j+1} = g_j ∘ p_j  —— 四类方向各有自己的 g 序列", fontsize=8.8, va="top")
    ax.text(0.0, 0.80, "DIAG / ORTH :  r³, ρ, r³, e,  r³, ρ, r³", fontsize=9.4, color="#1f3550")
    ax.text(0.0, 0.725, "R / L       :  r,  ρ, r,  X2, r,  ρ, r", fontsize=9.4, color="#1f3550")
    ax.text(0.0, 0.645, "DIAG/ORTH 走完 7 步回到 p0（周期 8）；R/L 回到 p3（j=3 的 X2 是断裂点）",
            fontsize=8.2, color="#555")
    ax.text(0.0, 0.53, "置换字母表（S4）：", fontsize=8.8, weight="bold")
    ax.text(0.0, 0.455, "r=(1,2,3,0)   ρ=(3,2,1,0)   e=(0,1,2,3)   r³=(3,0,1,2)   X2=(3,2,0,1)",
            fontsize=8.8)
    ax.text(0.0, 0.36, "基置换 p0：", fontsize=8.8, weight="bold")
    ax.text(0.0, 0.285, "DIAG (2,0,3,1) · ORTH (2,3,0,1) · R (2,0,1,3) · L (3,1,0,2)", fontsize=8.8)
    ax.text(0.0, 0.17, "重建 32/32 全对；描述量从 32×log₂24 ≈ 147 bit 压到 4×log₂24+1 ≈ 20 bit",
            fontsize=8.8, color="#2f7d4f")
    ax.text(0.0, 0.075, "（复查：INT_L 与 INT_R 逐族同码 64/64；16 码在 +2 mod 4 下成 8 对）",
            fontsize=8.2, color="#555")
    fig.tight_layout()
    p = os.path.join(OUT, "law_2_codes.png")
    fig.savefig(p, dpi=170)
    plt.close(fig)
    return p, len(hist)


def fig3():
    rows = [
        ("族 family（172 个）", 172, 172, "#2f5d8a"),
        ("feature（源→族对，3,634 条）", 3634, 3634, "#2f5d8a"),
        ("可由槽位表生成", 3552, 3634, "#3f7f5f"),
        ("INT 实例（实测覆盖的 tile）", 12565, 53100, "#8a6a2f"),
    ]
    fig, ax = plt.subplots(figsize=(11.6, 4.6))
    ys = list(range(len(rows)))[::-1]
    for y, (lab, v, tot, col) in zip(ys, rows):
        pct = 100.0 * v / tot
        ax.barh(y, 100, color="#ececec", height=0.52)
        ax.barh(y, pct, color=col, height=0.52)
        ax.text(pct + 1.2, y, f"{v:,} / {tot:,} = {pct:.2f}%", va="center", fontsize=9)
        ax.text(-1.2, y, lab, va="center", ha="right", fontsize=9)
    ax.set_xlim(0, 132)
    ax.set_ylim(-0.85, len(rows) - 0.45)
    ax.set_yticks([])
    ax.set_xlabel("覆盖率（%）", fontsize=9)
    ax.set_title("四档覆盖率：律能解释的部分 vs 只能当数据存的部分", fontsize=11.5)
    ax.spines[["top", "right", "left"]].set_visible(False)
    fig.subplots_adjust(left=0.34, right=0.985, top=0.88, bottom=0.24)
    fig.text(0.36, 0.115, "缺口 82 条 feature = 6 个长线族（LH0/LH12/LV_L0/LV_L18/LVB_L0/LVB_L12）",
             fontsize=8.2, color="#555")
    fig.text(0.36, 0.055, "实例档 23.66% 是「实测过的 tile 占比」，不是「律只在 23.66% 成立」",
             fontsize=8.2, color="#555")
    p = os.path.join(OUT, "law_3_coverage.png")
    fig.savefig(p, dpi=170)
    plt.close(fig)
    return p


def main() -> int:
    os.makedirs(OUT, exist_ok=True)
    p1, n1 = fig1()
    p2, n2 = fig2()
    p3 = fig3()
    print(f"fig1 {p1}  (10 cells, {n1})")
    print(f"fig2 {p2}  ({n2} codes)")
    print(f"fig3 {p3}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
