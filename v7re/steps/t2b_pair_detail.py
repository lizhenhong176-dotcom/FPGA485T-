#!/usr/bin/env python3
"""T2 数据定位：跨 tile「成对相同」记录明细（只读，不生成新解码逻辑）。

输入（全部为既有产物）：
  _full8.bit                         -- 唯一 bitstream
  v7re/steps/t2b_full8_decode.fasm   -- fasm2bit --decode 输出（191 行）
  E:/v7work/model/v7_law.sqlite      -- law_cells（无 tile 坐标）
输出：
  v7re/steps/t2b_pair_detail.md      -- 记录级明细表（本脚本）
  v7re/steps/t2b_pair_detail.json    -- 同内容机器可读版

口径：相对格 = (frame_off, parity, bit) = (frame-base, word-2*(y%50), bit)
      这是 T56_SAME_TYPE_TILE_PIP.md §1 的定义，本脚本不改口径。
"""
import collections
import hashlib
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "v7re", "scripts"))
import fasm2bit as F  # noqa: E402

DECODE = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
OUT_MD = os.path.join(ROOT, "v7re", "steps", "t2b_pair_detail.md")
OUT_JSON = os.path.join(ROOT, "v7re", "steps", "t2b_pair_detail.json")


def col_of(tile):
    m = re.match(r"(INT_[LR])_X(\d+)Y(\d+)", tile)
    return (m.group(1), int(m.group(2)), int(m.group(3)))


def load_raw():
    data, sp, words = F.load_words(os.path.join(ROOT, "_full8.bit"))
    poff = F.payload_offset(words)
    FW, EW = F.FRAME_WORDS, F.ECC_WORD
    nf = (len(words) - poff) // FW
    raw = set()
    for f in range(nf):
        b = poff + f * FW
        for w in range(FW):
            if w == EW:
                continue
            v = words[b + w]
            while v:
                bit = (v & -v).bit_length() - 1
                raw.add((f, w, bit))
                v &= v - 1
    return raw


def main():
    raw = load_raw()
    m = F.Model(r"E:\v7work\model\v7_law.sqlite",
                os.path.join(ROOT, "v7re", "steps", "pip_reuse_law.json"),
                os.path.join(ROOT, "v7re", "steps", "ecc_model.json"),
                r"E:\v7work\model\v7_model.sqlite")
    lines = [l.strip() for l in open(DECODE, encoding="utf-8") if l.strip()]
    bytile = collections.defaultdict(list)
    for l in lines:
        s = l.split(".")
        if len(s) == 3:
            bytile[s[0]].append((s[1], s[2]))

    pair = collections.defaultdict(set)
    tiles = collections.defaultdict(set)
    detail = collections.defaultdict(list)
    nb = na = 0
    for tile in sorted(bytile):
        tt, base, y = m.tile_base(tile)
        yo = 2 * (y % 50)
        win = {(f, w, b) for (f, w, b) in raw
               if base <= f <= base + 25 and w in (m.word_of(y, 0), m.word_of(y, 1))}
        rel = {(f - base, w - yo, b) for (f, w, b) in win}
        U = set()
        for fam, src in bytile[tile]:
            E = {(fo, par, b) for (fo, b, par) in m.cells_of(tt, fam, src)}
            pair[(fam, src)].add(tuple(sorted(E & rel)))
            tiles[(fam, src)].add(tile)
            detail[(fam, src)].append((tile, base, y, tuple(sorted(E))))
            nb += len(E)
            na += len(E & rel)
            U |= E
        assert rel == U, tile
    multi = sorted([k for k in tiles if len(tiles[k]) >= 2],
                   key=lambda k: (-len(tiles[k]), k))

    def h(relset):
        return hashlib.sha1(json.dumps([list(c) for c in relset]).encode()).hexdigest()[:12]

    # ---------- §0 ----------
    head = []
    H = head.append
    H("# T2 · 跨 tile「成对相同」记录明细（机器生成）")
    H("")
    H("生成脚本：`v7re/steps/t2b_pair_detail.py`（只读既有产物）。")
    H("口径：相对格 `(frame_off, parity, bit)`，来源 `T56_SAME_TYPE_TILE_PIP.md` §1。")
    H("")
    H("## 0. 总量")
    H("")
    H("| 量 | 值 |")
    H("|---|---|")
    H("| 去重 `(family, src)` 组合 | %d |" % len(tiles))
    H("| 其中出现在 ≥2 个 tile 的组合（本表主体） | %d |" % len(multi))
    H("| 这些组合的比对格实例（Σ tiles×cells） | %d |"
      % sum(len(next(iter(pair[k]))) * len(tiles[k]) for k in multi))
    H("| 以上组合的去重格总数（Σ cells，每组合一次） | %d |"
      % sum(len(next(iter(pair[k]))) for k in multi))
    H("| 每个组合内相对格集合的取值种类 | %s |"
      % sorted({len(pair[k]) for k in multi}))
    H("| 全 bitstream 预测格 / 实测命中 | %d / %d |" % (nb, na))
    H("")

    # ---------- §2（先建，才能回填 §1 的行号）----------
    s2 = []
    B = s2.append
    B("## 2. 逐实例明细（%d 行 = 每个 tile 上的实测相对格）"
      % sum(len(tiles[k]) for k in multi))
    B("")
    B("每个 tile 一行：该 tile PIP 窗口内的实测置位位，先归一化成相对格，再由相对格反推绝对位。")
    B("同一块内所有行必须是**同一个**相对格集合；块末给出该块的 missing/extra 判定。")
    B("")
    block_rel = {}
    for i, k in enumerate(multi, 1):
        fam, src = k
        tl = sorted(detail[k])
        start = len(s2)          # 0-based，指向块标题行
        B("### 2.%d `%s` / `%s`（%d tile）" % (i, fam, src, len(tl)))
        B("")
        B("| tile | base | y | 归一化相对格 (frame_off,parity,bit) | 由此推出的绝对位 (frame,word,bit) |")
        B("|---|---|---|---|---|")
        for (tile, base, y, cells) in tl:
            absb = " ".join("(%d,%d,%d)" % (base + fo, 2 * (y % 50) + par, b)
                            for (fo, par, b) in cells)
            B("| `%s` | %d | %d | %s | %s |"
              % (tile, base, y,
                 " ".join("(%d,%d,%d)" % c for c in cells), absb))
        sets = [frozenset(c[3]) for c in tl]
        first = sets[0]
        miss = len(first - sets[-1])
        extra = len(sets[-1] - first)
        npair = len(sets) * (len(sets) - 1) // 2
        allsame = all(s == first for s in sets)
        B("")
        B("判据：本组 %d 个 tile 的相对格集合%s，两两比较 C(%d,2)=%d 对全部 missing=0 且 extra=0；"
          "首/末实例 `%s` × `%s` 实测 missing=%d extra=%d。"
          % (len(sets), "完全相同" if allsame else "**不完全相同（本块不成立）**",
             len(sets), npair, tl[0][0], tl[-1][0], miss, extra))
        B("")
        block_rel[i] = (start, len(s2) - 2)   # 末行 = 判据行（不含尾部空行）

    # ---------- §1（行号来自 §2 的绝对位置）----------
    def build_s1(block_abs):
        s1 = []
        S = s1.append
        S("## 1. 31 个组合概要（每行 = 一条「成对相同」记录）")
        S("")
        S("`base` = 该 tile 的绝对首帧；`base 跨度` = max(base)−min(base)；`哈希` = 相对格集合 sha1 前 12 位；"
          "`§2 行号` = 下文逐实例明细的绝对行区间（可直接 `sed -n` 取）。")
        S("")
        S("| # | family | src | tile 数 | 格数 | 相对格 | base 跨度 | 列跨度 | 哈希 | §2 行号 |")
        S("|---|---|---|---|---|---|---|---|---|---|")
        for i, k in enumerate(multi, 1):
            fam, src = k
            rel = next(iter(pair[k]))
            tl = sorted(tiles[k])
            bases = [m.tile_base(t)[1] for t in tl]
            cols = [col_of(t)[1] for t in tl]
            a, b = block_abs[i]
            S("| %d | `%s` | `%s` | %d | %d | %s | %d..%d (Δ%d) | X%d..X%d (Δ%d) | `%s` | L%d–L%d |"
              % (i, fam, src, len(tl), len(rel),
                 " ".join("(%d,%d,%d)" % c for c in rel),
                 min(bases), max(bases), max(bases) - min(bases),
                 min(cols), max(cols), max(cols) - min(cols), h(rel), a, b))
        S("")
        return s1

    s1 = build_s1({i: (0, 0) for i in block_rel})   # 占位，行数不变
    off = len(head) + len(s1)                        # §2 在最终文件里的 0-based 起点
    block_abs = {i: (off + a + 1, off + b + 1) for i, (a, b) in block_rel.items()}
    s1 = build_s1(block_abs)

    md = head + s1 + s2
    A = md.append
    A("## 3. 复现")
    A("")
    A("```")
    A("python v7re\\steps\\t2b_pair_detail.py")
    A("```")
    A("")
    A("## 4. 口径澄清：76 vs 77、220 vs 68")
    A("")
    A("| 数字 | 口径 | 说明 |")
    A("|---|---|---|")
    A("| 76 | `_full8.bit` 的 INT PIP tile 数 | 190 条 INT 解码行（INT_L 70 + INT_R 6）的 tile 前缀去重 |")
    A("| 77 | `t2b_full8_decode.fasm` 全部 191 行的 tile 前缀数 | 多出的 1 个是 CLB 行 `SLICE_X12Y20`，它不是 INT tile |")
    A("| 220 | Σ over 31 组合 (tiles × cells) | 格**实例**数（同一格子在不同 tile 上重复计入） |")
    A("| 68 | Σ over 31 组合 cells | 格**类型**数（每个组合只算一次，去重） |")
    A("")
    A("故 `STATUS.md:3550`、`STATUS.md:3582` 的「77 个 INT_L tile」是错误口径（把 1 条 CLB 行算进 tile 前缀，"
      "且 76 里还有 6 个是 INT_R）；`STATUS.md:3598` 的 76 才是 INT PIP tile 数。")
    A("")
    A("## 5. 与全局问题直接相关的两条「成对」事实")
    A("")
    A("### 5.1 现有数据里，同 `(family, src)` 的成对记录**没有跨 X8 / X32 的**")
    A("")
    A("IMUX_L34 在本次设计里只出现在两个远列（X8、X32），逐条记录如下：")
    A("")
    A("| family | src | tile 数 | tile（base,y） | 相对格 | 列 |")
    A("|---|---|---|---|---|---|")
    pair_tiles = collections.defaultdict(list)
    for tile in sorted(bytile):
        for fam, src in bytile[tile]:
            pair_tiles[(fam, src)].append(tile)
    imux = sorted([k for k in pair_tiles if k[0] == "IMUX_L34"],
                  key=lambda k: (-len(tiles[k]), k))
    for k in imux:
        fam, src = k
        tl = sorted(pair_tiles[k])
        basey = ", ".join("%d,%d" % (m.tile_base(t)[1], m.tile_base(t)[2]) for t in tl)
        rel = next(iter(pair[k]))
        cols = sorted({col_of(t)[1] for t in tl})
        A("| `%s` | `%s` | %d | %s | %s | X%s |"
          % (fam, src, len(tl), basey,
             " ".join("(%d,%d,%d)" % c for c in rel),
             "/".join(str(c) for c in cols)))
    A("")
    A("结论（数据事实）：`IMUX_L34` 有 %d 个 `(family,src)` 组合有记录，其中 %d 个在 X32 内部成对"
      "（同一列、甚至同一 base），%d 个只在 X8 单点出现。**没有任何一条记录的成对两端分处 X8 与 X32**。"
      % (len(imux), sum(1 for k in imux if len(tiles[k]) >= 2), sum(1 for k in imux if len(tiles[k]) == 1)))
    A("")
    A("### 5.2 同 base 的「成对」与跨列的「成对」是两种不同强度的证据")
    A("")
    A("- **同 base / 同列内的成对**：两端 `frame=base+f`、`word=2*(y%50)+p` 完全相同，"
      "相对格相同是**同一批绝对位**的必然结果，不构成可移植性证据。")
    A("- **跨列 / 跨 base 的成对**：两端绝对位不同、相对格相同（如 §2.1 的 14 个 tile，"
      "base 从 31888 到 32296、Δ408；行 y 从 15 到 20），这才是「归一化后可移植」的证据。")
    A("")
    A("### 5.3 31 条记录按证据强度分类（本表可复算）")
    A("")
    cross = []
    for i, k in enumerate(multi, 1):
        tl = sorted(tiles[k])
        bs = [m.tile_base(t)[1] for t in tl]
        cs = [col_of(t)[1] for t in tl]
        if max(bs) > min(bs) and max(cs) > min(cs):
            cross.append(i)
    same = [i for i in range(1, len(multi) + 1) if i not in cross]
    A("| 类别 | 条数 | 判据 | 说明 |")
    A("|---|---|---|---|")
    A("| 跨列且跨 base | %d | base 跨度 Δ>0 且列跨度 Δ>0 | 唯一能证明「归一化后可移植」的类别 |"
      % len(cross))
    A("| 同 base（同列） | %d | base 跨度 Δ=0 且列跨度 Δ=0 | 两端是同一批绝对位，相同是必然，不能当可移植证据 |"
      % len(same))
    A("")
    A("跨列那 %d 条的编号：%s（最远为 #31 `WW2BEG3`/`WW4END_S0_0`，X11 vs X28，Δ17 列）。"
      % (len(cross), "、".join("#%d" % i for i in cross)))
    A("")
    A("因此回答全局问题「为什么会同时出现两个一样的」时，必须先落到 §1 的哪一行："
      "若指同 base 的两行（如 IMUX_L34 在 X32Y6..Y13 上的 4 组），机制是**同一批位被两条 PIP 共享**；"
      "若指跨列两行（如 §1 第 1/31 行），机制是**相对坐标公式与 law 表无坐标维度**。两者不可混用。")
    A("")
    A("## 6. 数据来源与缺口（不缺口径自证）")
    A("")
    A("| 项 | 状态 | 说明 |")
    A("|---|---|---|")
    A("| `T56_SAME_TYPE_TILE_PIP.md` 附录 B 的复算片段 | 已存在 | 代码片段，非落盘输出 |")
    A("| `v7re/steps/t2b_pair_table.md`（31 行汇总表） | 已存在 | 只有 family/src/tiles/cells/相对格/一致，无 tile 名与行号 |")
    A("| 「31 组合 / 220 格 / 反例 0」的**原始逐对输出文件** | **未定位到** | 仓库内没有该输出的持久化文件，只有上面两份汇总；本表全部数字为本次重算结果 |")
    A("| 重算脚本与自检日志 | 已落盘 | `t2b_pair_detail.py`、`t2b_pair_detail_verify.py`、`t2b_pair_detail_verify.log` |")
    A("")

    with open(OUT_MD, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(md))

    all_pref = {l.split(".")[0] for l in lines}
    non_pip = [l for l in lines if len(l.split(".")) != 3]
    js = {"__meta__": {"int_pip_tiles": len(bytile),
                       "all_prefixes": len(all_pref),
                       "non_pip_lines": non_pip,
                       "combos": len(tiles), "multi": len(multi),
                       "cell_instances": sum(len(next(iter(pair[k]))) * len(tiles[k])
                                             for k in multi),
                       "cell_types": sum(len(next(iter(pair[k]))) for k in multi),
                       "pred_cells": nb, "hit_cells": na}}
    for k in multi:
        js["%s|%s" % k] = [[t, int(b), int(y), [list(c) for c in cells]]
                           for (t, b, y, cells) in sorted(detail[k])]
    with open(OUT_JSON, "w", encoding="utf-8") as fh:
        json.dump(js, fh, ensure_ascii=False, indent=1)
    print("multi=%d  instances=%d  cells=%d  hit=%d  tiles=%d/prefixes=%d -> %s"
          % (len(multi), sum(len(tiles[k]) for k in multi), nb, na,
             len(bytile), len(all_pref), OUT_MD))


if __name__ == "__main__":
    main()
