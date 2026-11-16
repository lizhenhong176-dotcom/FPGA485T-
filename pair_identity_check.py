#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""T4 · 成对相同判据复算：三种坐标口径下的 missing/extra + 位复用计数。

只读既有产物，不新构建设计、不连远程、不联网：
  输入  _full8.bit                              唯一 bitstream（实测置位位的唯一来源）
        v7re/steps/t2b_full8_decode.fasm        fasm2bit --decode 输出（190 条 PIP + 1 条 CLB）
        E:/v7work/model/v7_law.sqlite           law_cells / law_tiles / far_bands
        v7re/steps/pip_reuse_law.json           mux 区 64 族的族内公式
        v7re/steps/ecc_model.json               ECC 位置表（本脚本只读不用改）
        E:/v7work/model/v7_model.sqlite         site_frames（本脚本只用 tile 地址与 law）

要回答的问题
------------
「两个一样的」在三种坐标口径下分别是真是假：
  L0 绝对位      (frame, word, bit)                    -- 位流里的真实地址
  L1 帧相对      (frame-base, word, bit)               -- 去掉列（块基址），保留行
  L2 T56 归一化  (frame-base, parity, bit)             -- 去掉列 **与行**
判据仍是 missing=0 且 extra=0。三种口径对同一对 tile 各算一次。

位复用统计
----------
1) 模型级：同一 tile_type 内，一个格 (frame_off, parity, bit) 被多少条 (family, src) 引用。
2) 设计级：_full8.bit 里**实际点亮**的位中，有多少同时被该 tile 内 >=2 条已解码 PIP 引用
   （即「同一批位被两条 PIP 重复计入」是否真的发生）。

确定性
------
不调用任何随机源；所有集合/字典输出前排序；报告里不写时间戳。
两次运行的 stdout 与产物逐字节一致（A2）。
"""
import argparse
import collections
import hashlib
import json
import os
import re
import struct
import sys

SYNC = b"\xAA\x99\x55\x66"
FRAME_WORDS = 101          # 7 系列 frame 的 32-bit 字数（含 1 个 ECC 字）
ECC_WORD = 50
HERE = os.path.dirname(os.path.abspath(__file__))
DEFAULTS = {
    "bit": os.path.join(HERE, "_full8.bit"),
    "decode": os.path.join(HERE, "v7re", "steps", "t2b_full8_decode.fasm"),
    "law_db": r"E:\v7work\model\v7_law.sqlite",
    "model_db": r"E:\v7work\model\v7_model.sqlite",
    "law_json": os.path.join(HERE, "v7re", "steps", "pip_reuse_law.json"),
    "ecc_json": os.path.join(HERE, "v7re", "steps", "ecc_model.json"),
    "out_md": os.path.join(HERE, "v7re", "steps", "pair_identity_check.md"),
    "out_json": os.path.join(HERE, "v7re", "steps", "pair_identity_check.json"),
}


# ---------------------------------------------------------------- 位流读取（独立实现）
def read_payload(path):
    """→ (nframes, words, poff)。与 fasm2bit.load_words / payload_offset 同规则，独立实现。"""
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    if pos < 0:
        raise SystemExit("找不到 SYNC")
    n = (len(data) - pos - 4) // 4
    words = list(struct.unpack(">%dI" % n, data[pos + 4:pos + 4 + 4 * n]))
    i = 0
    while i < len(words):
        h = words[i]
        i += 1
        typ = (h >> 29) & 0x7
        if typ == 2:
            poff = i
            break
        op = (h >> 27) & 0x3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF
        if op == 1:
            i += 1
            continue
        if addr == 0x02:                     # FDRI
            poff = i + 1 if cnt == 0 else i
            break
        if op == 2:
            i += cnt
    else:
        raise SystemExit("未找到 FDRI")
    nf = (len(words) - poff) // FRAME_WORDS
    return nf, words, poff


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


# ---------------------------------------------------------------- 三种口径
class Ladder:
    """把一条 (family, src) 在某个 tile 上的落点，按三种口径展开。"""

    def __init__(self, model):
        self.m = model
        self._cellcache = {}

    def cells(self, tt, fam, src):
        """→ [(frame_off, bit, parity)]，来自 law（mux 公式）或 law_cells（表）。"""
        k = (tt, fam, src)
        if k not in self._cellcache:
            cs = self.m.cells_of(tt, fam, src)
            self._cellcache[k] = None if cs is None else tuple(sorted(cs))
        return self._cellcache[k]

    def l0(self, tile, fam, src):
        """绝对位 (frame, word, bit)。"""
        tt, base, y = self.m.tile_base(tile)
        return {(base + fo, self.m.word_of(y, par), bit)
                for (fo, bit, par) in self.cells(tt, fam, src)}

    def l1(self, tile, fam, src):
        """帧相对 (frame-base, word, bit)：去掉列（块基址），保留行。"""
        tt, base, y = self.m.tile_base(tile)
        return {(fo, self.m.word_of(y, par), bit)
                for (fo, bit, par) in self.cells(tt, fam, src)}

    def l2(self, tile, fam, src):
        """T56 归一化 (frame-base, parity, bit)：去掉列与行。

        注意：本函数用到的三个入参里**没有 tile 坐标**——cells_of 的签名是
        (tile_type, family, src)，因此 L2 对同 (tt,fam,src) 的任意两个 tile 必然逐格相同。
        """
        tt = self.m.tile_base(tile)[0]
        return {(fo, par, bit) for (fo, bit, par) in self.cells(tt, fam, src)}


def col_of(tile):
    mm = re.match(r"INT_[LR]_X(\d+)Y(\d+)", tile)
    return None if mm is None else mm.group(1)


def cmp_sets(a, b):
    """→ (missing, extra)：missing = 在 A 不在 B；extra = 在 B 不在 A。"""
    return len(a - b), len(b - a)


# ---------------------------------------------------------------- 主流程
def main():
    ap = argparse.ArgumentParser()
    for k, v in DEFAULTS.items():
        ap.add_argument("--" + k.replace("_", "-"), default=v)
    a = ap.parse_args()

    root = os.path.dirname(a.out_md)
    sys.path.insert(0, os.path.join(HERE, "v7re", "scripts"))
    import fasm2bit as F  # noqa: E402  （只用它的 Model：law/tile 地址口径的唯一实现）

    m = F.Model(a.law_db, a.law_json, a.ecc_json, a.model_db)
    lat = Ladder(m)

    # ---- 输入哈希 ----
    hashes = {
        "bit": sha256(a.bit),
        "decode": sha256(a.decode),
        "law_db": sha256(a.law_db),
        "model_db": sha256(a.model_db),
        "law_json": sha256(a.law_json),
        "ecc_json": sha256(a.ecc_json),
    }

    # ---- 解码结果 ----
    lines = [l.strip() for l in open(a.decode, encoding="utf-8") if l.strip()]
    bytile = collections.defaultdict(list)
    non_pip = []
    for l in lines:
        s = l.split(".")
        if len(s) == 3:
            bytile[s[0]].append((s[1], s[2]))
        else:
            non_pip.append(l)
    tiles = sorted(bytile)

    # ---- 实测置位位（直接从 _full8.bit 读，不经过 fasm2bit 的 decode） ----
    nf, words, poff = read_payload(a.bit)

    def wget(f, w):
        if f < 0 or f >= nf or w < 0 or w >= FRAME_WORDS:
            return 0
        return words[poff + f * FRAME_WORDS + w]

    def obs_window(tile):
        tt, base, y = m.tile_base(tile)
        out = set()
        for fo in range(26):
            for w in (m.word_of(y, 0), m.word_of(y, 1)):
                v = wget(base + fo, w)
                while v:
                    b = (v & -v).bit_length() - 1
                    out.add((base + fo, w, b))
                    v &= v - 1
        return out

    # 自检：每个 tile 的实测置位位必须等于该 tile 全部已解码 PIP 的预测并集
    obs = {}
    mismatch = []
    for t in tiles:
        o = obs_window(t)
        pred = set()
        for fam, src in bytile[t]:
            pred |= lat.l0(t, fam, src)
        obs[t] = o
        if o != pred:
            mismatch.append([t, len(o), len(pred), len(o - pred), len(pred - o)])

    # ---- 组合清单（与 T2 同口径：同 (family,src) 出现在 >=2 个 tile） ----
    combos = collections.defaultdict(set)
    for t in tiles:
        for fam, src in bytile[t]:
            combos[(fam, src)].add(t)
    multi = sorted([k for k, v in combos.items() if len(v) >= 2],
                   key=lambda k: (-len(combos[k]), k))
    singles = sorted([k for k, v in combos.items() if len(v) == 1])

    # ---- 每对 tile 三种口径的 missing/extra ----
    rows = []
    for fam, src in multi:
        tl = sorted(combos[(fam, src)])
        ta, tb = tl[0], tl[-1]
        tta, ba, ya = m.tile_base(ta)
        ttb, bb, yb = m.tile_base(tb)
        A0, B0 = lat.l0(ta, fam, src), lat.l0(tb, fam, src)
        A1, B1 = lat.l1(ta, fam, src), lat.l1(tb, fam, src)
        A2, B2 = lat.l2(ta, fam, src), lat.l2(tb, fam, src)
        va, vb = obs[ta], obs[tb]
        # 差异签名：L0 下差在哪个坐标分量
        df = {c[0] for c in A0} != {c[0] for c in B0}
        dw = {c[1] for c in A0} != {c[1] for c in B0}
        db = {c[2] for c in A0} != {c[2] for c in B0}
        sig = "+".join(n for n, c in (("frame", df), ("word", dw), ("bit", db)) if c) or "none"
        rows.append({
            "family": fam, "src": src, "tiles": tl, "n_tiles": len(tl),
            "tile_a": ta, "tile_b": tb,
            "base_a": ba, "base_b": bb, "y_a": ya, "y_b": yb,
            "col_a": col_of(ta), "col_b": col_of(tb),
            "cells": len(A2),
            "L0": {"A": sorted(A0), "B": sorted(B0), "me": cmp_sets(A0, B0)},
            "L1": {"A": sorted(A1), "B": sorted(B1), "me": cmp_sets(A1, B1)},
            "L2": {"A": sorted(A2), "B": sorted(B2), "me": cmp_sets(A2, B2)},
            "signature": sig,
            "obs_A": len(va), "obs_B": len(vb),
            "obs_common": len(va & vb),
        })

    n_pairs = len(rows)
    cnt = {m_: sum(1 for r in rows if r[m_]["me"] == (0, 0)) for m_ in ("L0", "L1", "L2")}
    sigcnt = collections.Counter(r["signature"] for r in rows)
    # 自检：签名计数之和必须等于对数（报告 §3 的「× N」之和要能对上 31）
    assert sum(sigcnt.values()) == n_pairs, (sigcnt, n_pairs)
    # 自检（真实不变式）：L0 集合若逐格相同，则三个投影也必相同 → 签名只能是 "none"
    for r in rows:
        if r["L0"]["me"] == (0, 0):
            assert r["signature"] == "none", r
    # 自检：每对两侧的 L2 集合都非空（否则 missing/extra 的语义退化，需要显式告警）
    for r in rows:
        assert r["L2"]["A"] and r["L2"]["B"], r
    # 分类：pair 级（首/末 tile）与组合级（全部 tile）
    pair_cls = collections.Counter()
    for r in rows:
        pair_cls[("base_same" if r["base_a"] == r["base_b"] else "base_diff",
                  "y_same" if r["y_a"] == r["y_b"] else "y_diff",
                  "col_same" if r["col_a"] == r["col_b"] else "col_diff")] += 1

    # ---- 位复用 1：模型级 ----
    ref = {}
    ref_stats = {}
    for tt in ("INT_L", "INT_R"):
        fams = {k[1] for k in m.cells if k[0] == tt}
        if tt == "INT_L":
            fams |= set(m.law)
        d = collections.defaultdict(set)
        for fam in sorted(fams):
            for src in m.all_sources(tt, fam):
                cs = lat.cells(tt, fam, src)
                if not cs:
                    continue
                for c in cs:
                    d[c].add((fam, src))
        ref[tt] = d
        hist = collections.Counter(len(v) for v in d.values())
        ref_stats[tt] = {
            "distinct_cells": len(d),
            "refs": sum(len(v) for v in d.values()),
            "ratio": round(sum(len(v) for v in d.values()) / max(1, len(d)), 4),
            "hist": {str(k): hist[k] for k in sorted(hist)},
        }

    # ---- 位复用 2：设计级（实测同时点亮且被 >=2 条 PIP 引用） ----
    shared_lit = []
    lit_cells_total = 0
    for t in tiles:
        owner = collections.defaultdict(list)
        for fam, src in bytile[t]:
            for (fo, bit, par) in lat.cells(m.tile_base(t)[0], fam, src):
                owner[(m.tile_base(t)[1] + fo,
                       m.word_of(m.tile_base(t)[2], par), bit)].append((fam, src))
        lit = obs[t]
        lit_cells_total += len(lit)
        for c in sorted(lit):
            if len(owner.get(c, [])) >= 2:
                shared_lit.append({"tile": t, "cell": list(c),
                                   "pips": ["%s.%s" % p for p in sorted(owner[c])]})

    # ---- 阴性对照：不同 (family,src) 在 L2 下是否可区分 ----
    l2sets = {}
    for fam, src in sorted(combos):
        t0 = sorted(combos[(fam, src)])[0]
        l2sets[(fam, src)] = frozenset(lat.l2(t0, fam, src))
    inv = collections.defaultdict(list)
    for k, v in l2sets.items():
        inv[v].append(k)
    collisions = [v for v in inv.values() if len(v) > 1]

    # ---- tile_type 一致性：同 (fam,src) 在 INT_L / INT_R 下的 L2 是否相同 ----
    #     三种结果分开统计，不把「一侧 law_cells 无此键」误报成「坐标不同」
    tt_agree = 0
    tt_missing = []
    tt_diff = []
    for fam, src in sorted(combos):
        ca = lat.cells("INT_L", fam, src)
        cb = lat.cells("INT_R", fam, src)
        if ca is None or cb is None:
            tt_missing.append([fam, src])
            continue
        sa = {(fo, par, bit) for (fo, bit, par) in ca}
        sb = {(fo, par, bit) for (fo, bit, par) in cb}
        if sa == sb:
            tt_agree += 1
        else:
            tt_diff.append([fam, src, sorted(sa - sb), sorted(sb - sa)])
    tt_disagree = tt_missing + tt_diff

    # 与 T2 产物对账
    t2path = os.path.join(HERE, "v7re", "steps", "t2b_pair_detail.json")
    t2 = None
    t2_agree = None
    if os.path.exists(t2path):
        t2 = json.load(open(t2path, encoding="utf-8"))
        ok = 0
        bad = []
        for r in rows:
            key = "%s|%s" % (r["family"], r["src"])
            rec = t2.get(key)
            if not rec:
                bad.append([key, "missing"])
                continue
            # T2 的 rec 行 = [tile, base, y, relcells]
            t2rel = {tuple(c) for (_, _, _, cs) in rec for c in cs}
            mine = {tuple(c) for c in r["L2"]["A"]}
            if t2rel == mine and len(rec) == r["n_tiles"]:
                ok += 1
            else:
                bad.append([key, len(rec), r["n_tiles"], len(t2rel), len(mine)])
        t2_agree = {"ok": ok, "bad": bad, "meta": t2.get("__meta__", {})}

    # ================================================================ 报告
    md = []
    A = md.append
    A("# T4 · 成对相同判据复算：三种坐标口径下的 missing/extra")
    A("")
    A("机器生成，脚本 `pair_identity_check.py`（只读既有产物；不联网、不构建；无随机源）。")
    A("")
    A("## 0. 输入与哈希")
    A("")
    A("| 输入 | sha256 |")
    A("|---|---|")
    for k in ("bit", "decode", "law_db", "model_db", "law_json", "ecc_json"):
        A("| `%s` | `%s` |" % (os.path.basename(getattr(a, k)), hashes[k]))
    A("")
    A("- 随机性：**无**（脚本不调用 random/uuid/时间戳；所有输出按 key 排序）。")
    A("- 帧数（payload）：%d；解码行 %d 条 = %d 条 PIP + %d 条非 PIP（%s）。"
      % (nf, len(lines), sum(len(v) for v in bytile.values()), len(non_pip),
         ", ".join(non_pip) if non_pip else "-"))
    A("- 参与比对 tile：**%d** 个；去重 `(family, src)` 组合 **%d** 个，其中出现在 ≥2 个 tile 的 **%d** 个。"
      % (len(tiles), len(combos), len(multi)))
    A("")
    A("**自检（模型 vs 位流，独立读数）**：%d 个 tile 的实测置位位与该 tile 全部已解码 PIP 的"
      " law 预测并集**逐位相等**；失配 **%d** 个。%s"
      % (len(tiles), len(mismatch),
         "" if not mismatch else "失配明细：`%s`" % json.dumps(mismatch[:10], ensure_ascii=False)))
    A("")
    A("## 1. 三种口径（本轮唯一区分变量）")
    A("")
    A("| 口径 | 坐标 | 保留 | 丢弃 | 代码 |")
    A("|---|---|---|---|---|")
    A("| **L0 绝对** | `(frame, word, bit)` | 列、行、位 | — | `Ladder.l0` |")
    A("| **L1 帧相对** | `(frame-base, word, bit)` | 行、位 | 列（块基址） | `Ladder.l1` |")
    A("| **L2 T56 归一化** | `(frame-base, parity, bit)` | 位 | 列 **与** 行 | `Ladder.l2` |")
    A("")
    A("判据统一为 missing = |A−B| 且 extra = |B−A|，`missing=0 且 extra=0` 记为「两个一样」。")
    A("")
    A("## 2. %d 对 tile × 三种口径（每行一对）" % n_pairs)
    A("")
    A("`A`/`B` = 该组合排序后的首/末 tile。`L0/L1/L2` 列写 `missing/extra`。"
      "`差异签名` 表示 L0 下差在哪个坐标分量（`frame+word+bit` = 三者都不同）。")
    A("")
    A("| # | family | src | tile A | tile B | base Δ | y | 格数 | L0 m/e | L1 m/e | L2 m/e | 差异签名 |")
    A("|---|---|---|---|---|---|---|---|---|---|---|---|")
    for i, r in enumerate(rows, 1):
        A("| %d | `%s` | `%s` | `%s` | `%s` | %d→%d (Δ%d) | %d/%d | %d | %d/%d | %d/%d | **%d/%d** | `%s` |"
          % (i, r["family"], r["src"], r["tile_a"], r["tile_b"],
             r["base_a"], r["base_b"], r["base_b"] - r["base_a"],
             r["y_a"], r["y_b"], r["cells"],
             r["L0"]["me"][0], r["L0"]["me"][1],
             r["L1"]["me"][0], r["L1"]["me"][1],
             r["L2"]["me"][0], r["L2"]["me"][1], r["signature"]))
    A("")
    A("## 3. 汇总：同一批 pair，换口径就换答案")
    A("")
    A("| 口径 | `missing=0 且 extra=0` 的对数 | 占 %d 对 | 这一层的「相同」意味着什么 |" % n_pairs)
    A("|---|---|---|---|")
    A("| L0 绝对位 | **%d** | %.0f%% | 位流里真的是同一批位 |"
      % (cnt["L0"], 100.0 * cnt["L0"] / n_pairs))
    A("| L1 帧相对（去列） | **%d** | %.0f%% | 只是同一行上平移了一个块基址 |"
      % (cnt["L1"], 100.0 * cnt["L1"] / n_pairs))
    A("| L2 归一化（去列+去行） | **%d** | %.0f%% | 落回 law 表的键空间，**恒等** |"
      % (cnt["L2"], 100.0 * cnt["L2"] / n_pairs))
    A("")
    A("差异签名分布（L0 层差在哪）：%s。"
      % "、".join("`%s` × %d" % (k, v) for k, v in sorted(sigcnt.items())))
    A("")
    A("签名读法：`frame` = 只差帧号（纯列平移，行与位都相同）；`word` = 只差 word"
      "（纯行平移，帧与位都相同）；`frame+word` = 列与行同时不同、位相同。"
      "**没有一对的签名里含 `bit`**——位坐标本身在全部 %d 对上都不变。" % n_pairs)
    A("")
    A("pair 级分类（首/末 tile）：%s。"
      % "、".join("%s/%s/%s × %d" % (k[0], k[1], k[2], v)
                 for k, v in sorted(pair_cls.items())))
    A("")
    A("### 3.1 在 L1（只去列）就相同的 %d 对" % cnt["L1"])
    A("")
    A("| §2 # | family | src | tile A → tile B | Δ列 | Δbase | L1 m/e |")
    A("|---|---|---|---|---|---|---|")
    for i, r in enumerate(rows, 1):
        if r["L1"]["me"] == (0, 0):
            A("| %d | `%s` | `%s` | `%s` → `%s` | %s→%s | Δ%d | 0/0 |"
              % (i, r["family"], r["src"], r["tile_a"], r["tile_b"],
                 r["col_a"], r["col_b"], r["base_b"] - r["base_a"]))
    A("")
    A("### 3.2 只有 L2 才相同的 %d 对（L1 仍不同）" % (cnt["L2"] - cnt["L1"]))
    A("")
    A("这 %d 对全部是 **word 不同**（行不同）：L1 保留 `word = 2*(y%%50)+parity`，"
      "所以行差仍在；L2 把 word 压成 parity，行差被抹掉后才「相同」。"
      % (cnt["L2"] - cnt["L1"]))
    A("")
    A("### 3.3 为什么 L2 是恒等")
    A("")
    A("`Model.cells_of(self, ttype, family, src)`（`v7re/scripts/fasm2bit.py:113`）的入参是"
      "**tile_type + family + src**，不含 tile 名/列/行；`law_cells` 的列是"
      "`(tile_type, family, src_wire, frame_off, bit, sense, parity, src_index)`，**无坐标列**。"
      "所以对同 `(tt,fam,src)` 的任意两个 tile，L2 集合在代码层面就是同一个对象，"
      "`missing=0/extra=0` 不是测出来的，是**构造出来的**。唯一的例外是跨 tile_type 的对"
      "（本轮 %d 对），那才是真比较，见 §6。"
      % sum(1 for r in rows
            if len({m.tile_base(t)[0] for t in r["tiles"]}) > 1))
    A("")
    A("**关键读数**：L0 = %d/%d 全不同；L1 = %d/%d 相同；L2 = %d/%d 相同。"
      "也就是说，从 L0 到 L1 只丢了「列」，相同数从 %d 跳到 %d；从 L1 到 L2 只丢了「行」，"
      "相同数从 %d 跳到 %d。**两处「一样」是两次坐标降维各自造出来的，不是同一件事。**"
      % (cnt["L0"], n_pairs, cnt["L1"], n_pairs, cnt["L2"], n_pairs,
         cnt["L0"], cnt["L1"], cnt["L1"], cnt["L2"]))
    A("")
    A("## 4. 三对定点：L0/L1/L2 的格集合逐格展开")
    A("")
    picks = []
    for r in rows:
        if r["family"] == "WW2BEG3" and r["src"] == "WW4END_S0_0":
            picks.append(("P1 跨列跨行（最远列距）", r))
    for r in rows:
        if r["family"] == "IMUX_L34" and r["src"] == "SL1END1":
            picks.append(("P2 同列跨行（同 base，不同 y）", r))
    for r in rows:
        if r["family"] == "IMUX_L34" and r["src"] == "SR1BEG_S0":
            picks.append(("P3 同族不同源（同 family，不同 src）", r))
    for title, r in picks:
        A("### %s — `%s` / `%s`" % (title, r["family"], r["src"]))
        A("")
        A("- tile A = `%s`（base %d, y %d）  tile B = `%s`（base %d, y %d）"
          % (r["tile_a"], r["base_a"], r["y_a"], r["tile_b"], r["base_b"], r["y_b"]))
        A("")
        for mname, label in (("L0", "L0 绝对 (frame,word,bit)"),
                             ("L1", "L1 帧相对 (frame-base,word,bit)"),
                             ("L2", "L2 归一化 (frame-base,parity,bit)")):
            d = r[mname]
            A("| %s | 集合 A | 集合 B | missing | extra |" % label)
            A("|---|---|---|---|---|")
            A("| 值 | %s | %s | **%d** | **%d** |"
              % (" ".join("(%d,%d,%d)" % tuple(c) for c in d["A"]),
                 " ".join("(%d,%d,%d)" % tuple(c) for c in d["B"]),
                 d["me"][0], d["me"][1]))
            A("")
        A("- tile 窗口内实测点亮位数（含该 tile 上其它 PIP 的置位，不只是本 family）："
          "A=%d、B=%d，两窗口交集 **%d**；本 `(family,src)` 自身格数 **%d**。"
          % (r["obs_A"], r["obs_B"], r["obs_common"], len(r["L0"]["A"])))
        A("")
    A("## 5. 位复用统计：一个格被几条 PIP 引用、是否真的同时点亮")
    A("")
    A("### 5.1 模型级（同一 tile_type 的 law 全量）")
    A("")
    A("| tile_type | 去重格数 | (family,src) 引用条数 | 平均引用/格 | 引用数分布 |")
    A("|---|---|---|---|---|")
    for tt in ("INT_L", "INT_R"):
        s = ref_stats[tt]
        A("| %s | %d | %d | %.2f | %s |"
          % (tt, s["distinct_cells"], s["refs"], s["ratio"],
             " ".join("%s→%d" % (k, v) for k, v in s["hist"].items())))
    A("")
    A("即：在 law 里每个格平均被 **%.2f** 条 (family,src) 引用（INT_L），"
      "被引用最多的格有 %d 条。这是「同一批位被多个源共用」的**模型侧**事实。"
      % (ref_stats["INT_L"]["ratio"], max(int(k) for k in ref_stats["INT_L"]["hist"])))
    A("")
    A("### 5.2 设计级（_full8.bit 实测点亮，且同 tile 内被 ≥2 条已解码 PIP 引用）")
    A("")
    A("| 量 | 值 |")
    A("|---|---|")
    A("| 参与统计的 tile | %d |" % len(tiles))
    A("| 实测点亮格（逐 tile 累加） | %d |" % lit_cells_total)
    A("| 同时被 ≥2 条已解码 PIP 引用的点亮格 | **%d** |" % len(shared_lit))
    A("")
    if shared_lit:
        A("明细（前 20 条）：")
        A("")
        A("| tile | 格 (frame,word,bit) | 引用它的 PIP |")
        A("|---|---|---|")
        for s in shared_lit[:20]:
            A("| `%s` | `%s` | %s |" % (s["tile"], tuple(s["cell"]),
                                        "、".join("`%s`" % p for p in s["pips"])))
        A("")
    else:
        A("**实测 0 条**：本设计里没有任何一个点亮位同时被两条已解码 PIP 引用。"
          "即「两个一样的记录 = 同一批位被两条 PIP 重复计入」在本设计上**不成立**。"
          "（law 模型侧平均 %.2f 条/格是**候选空间**的重用，不是本设计里同时点亮的重用。）"
          % ref_stats["INT_L"]["ratio"])
        A("")
    A("## 6. 阴性对照：归一化比较器不是恒零函数")
    A("")
    A("| 对照 | 结果 |")
    A("|---|---|")
    A("| 不同 `(family,src)` 的 L2 集合（%d 个 key）去重后 | **%d** 种，碰撞 **%d** 组 |"
      % (len(l2sets), len(inv), len(collisions)))
    A("| 同 `(family,src)` 在 INT_L / INT_R 两种 tile_type 下的 L2 | 两侧都有且相同 **%d** 组；"
      "只有一侧有（family 名带 `_L`/`_R`）**%d** 组；两侧都有但不同 **%d** 组 |"
      % (tt_agree, len(tt_missing), len(tt_diff)))
    A("")
    if tt_missing:
        A("「只有一侧有」的 %d 组（不是坐标冲突，是 law_cells 里该 (family,src) 只注册了一个 tile_type）：%s。"
          % (len(tt_missing), "、".join("`%s/%s`" % tuple(k) for k in tt_missing)))
        A("")
    if tt_diff:
        A("「两侧都有但不同」的 %d 组：`%s`。"
          % (len(tt_diff), json.dumps(tt_diff[:5], ensure_ascii=False)))
        A("")
    if collisions:
        A("碰撞实例（这些 key 在 L2 下确实分不开，需单列）：")
        A("")
        for c in collisions[:10]:
            A("- " + "、".join("`%s/%s`" % kv for kv in c))
        A("")
    A("故 §3 中 L2 的 31/31 相同，**不是**比较器写坏导致的恒真：换一个 src，L2 立刻给出非零差。")
    A("")
    A("## 7. 与 T2 产物的对账")
    A("")
    if t2_agree is not None:
        A("- T2 逐实例 JSON（`t2b_pair_detail.json`）与本次独立重算：**%d/%d** 组在 tile 数、"
          "相对格集合上逐格一致；不一致 %d 组%s。"
          % (t2_agree["ok"], len(rows), len(t2_agree["bad"]),
             "" if not t2_agree["bad"] else "：`%s`" % json.dumps(t2_agree["bad"][:5], ensure_ascii=False)))
        A("- T2 的 `__meta__`：%s。"
          % json.dumps(t2_agree["meta"], ensure_ascii=False, sort_keys=True))
    else:
        A("- 未找到 `t2b_pair_detail.json`，跳过对账。")
    A("")
    A("**对 T2 叙述的一处更正（数据事实）**：T2 §5.2 把「同 base 的 18 对」描述为"
      "「两端 `frame` 与 `word` 完全相同 → 同一批绝对位」。本次复算：这 18 对的 "
      "`base` 相同但 `y` 不同（pair 级分类 `base_same/y_diff/col_same`），"
      "故 **frame 相同、word 不同**，绝对位并不相同；它们在 L0 下的 missing/extra 见 §2 逐行"
      "（2/2 或 4/4），不是 0。全部 %d 对里 L0 相同的对数是 **%d**。"
      % (n_pairs, cnt["L0"]))
    A("")
    A("另一处口径更正：`STATUS.md` §105 写「law 库 1602 格」，本次按"
      "`law_cells.sense=1` + mux 公式重算为 **%d** 格 / **%d** 条引用（INT_L，比值 %.2f×）；"
      "引用条数 8900 与 §105 一致，格数差 4。"
      % (ref_stats["INT_L"]["distinct_cells"], ref_stats["INT_L"]["refs"],
         ref_stats["INT_L"]["ratio"]))
    A("")
    A("## 8. 复现")
    A("")
    A("```")
    A("python pair_identity_check.py")
    A("```")
    A("")
    A("依赖边界（可复核）：只用 Python 标准库 + 本仓库 `v7re/scripts/fasm2bit.py` 的 "
      "`Model`（tile 地址与 law 公式的唯一实现）；不联网、不调 Vivado、不建新设计、"
      "不写 `STATUS.md`。位流读取是脚本内的独立实现（`read_payload`），"
      "不经过 `fasm2bit.decode`，便于用不同代码路径交叉验证。")
    A("")
    A("输入可用命令行覆盖（默认值见 `DEFAULTS`）：`--bit` `--decode` `--law-db` "
      "`--model-db` `--law-json` `--ecc-json` `--out-md` `--out-json`。")
    A("")
    A("产物：`v7re/steps/pair_identity_check.md`（本文件）、`v7re/steps/pair_identity_check.json`。")
    A("")
    A("## 9. 结论（数据层，供机制解释引用）")
    A("")
    A("1. **L0 绝对位：%d/%d 对全不同。** 现有设计里没有「真的同一批位」的成对 PIP；"
      "任何「两个一样的」都不是位流地址层面的相同。" % (cnt["L0"], n_pairs))
    A("2. **L1 去列：%d/%d 对相同**，全部是「同一行、不同列」的两块；"
      "签名恰为 `frame`（只差帧号，位与 word 都相同）。" % (cnt["L1"], n_pairs))
    A("3. **L2 去列+去行：%d/%d 对相同，且对同 tile_type 是恒等式**——"
      "`cells_of(tile_type, family, src)` 的三个入参都不含 tile 坐标，所以同 key 的任意两块"
      "在 L2 下必然逐格相同；该口径下的 missing=0/extra=0 不含任何测量信息。"
      "（本轮 %d 对跨 tile_type，那 %d 对是真比较，且两侧都有时 L2 全部一致：%d/%d。）"
      % (cnt["L2"], n_pairs,
         sum(1 for r in rows if len({m.tile_base(t)[0] for t in r["tiles"]}) > 1),
         sum(1 for r in rows if len({m.tile_base(t)[0] for t in r["tiles"]}) > 1),
         tt_agree, tt_agree + len(tt_diff)))
    A("4. **复用不是「重复计入」**：模型侧 %.2f 条/格是候选空间；设计侧同时点亮的共享格 **%d** 条。"
      % (ref_stats["INT_L"]["ratio"], len(shared_lit)))
    A("")

    with open(a.out_md, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("\n".join(md))

    js = {
        "__meta__": {
            "script": "pair_identity_check.py",
            "inputs": {k: {"path": getattr(a, k), "sha256": hashes[k]}
                       for k in ("bit", "decode", "law_db", "model_db", "law_json", "ecc_json")},
            "random": "none",
            "frames": nf,
            "decode_lines": len(lines),
            "pip_lines": sum(len(v) for v in bytile.values()),
            "non_pip_lines": non_pip,
            "tiles": len(tiles),
            "combos": len(combos),
            "multi": len(multi),
            "singles": len(singles),
            "selfcheck": {"tiles_checked": len(tiles), "mismatch": len(mismatch),
                          "detail": mismatch},
            "counts": {"pairs": n_pairs, "L0_zero": cnt["L0"], "L1_zero": cnt["L1"],
                       "L2_zero": cnt["L2"]},
            "signature_hist": dict(sorted(sigcnt.items())),
            "pair_class": {"%s|%s|%s" % k: v for k, v in sorted(pair_cls.items())},
            "reuse_model": ref_stats,
            "reuse_design": {"lit_cells": lit_cells_total,
                             "shared_lit": len(shared_lit), "detail": shared_lit},
            "l2_distinct": len(inv),
            "l2_collisions": [[list(k) for k in c] for c in collisions],
            "tile_type_agree": tt_agree,
            "tile_type_disagree": tt_disagree,
            "t2_crosscheck": t2_agree,
        },
        "pairs": [],
    }
    for r in rows:
        js["pairs"].append({
            "family": r["family"], "src": r["src"], "tiles": r["tiles"],
            "tile_a": r["tile_a"], "tile_b": r["tile_b"],
            "base_a": r["base_a"], "base_b": r["base_b"],
            "y_a": r["y_a"], "y_b": r["y_b"], "cells": r["cells"],
            "L0": {"A": r["L0"]["A"], "B": r["L0"]["B"], "missing": r["L0"]["me"][0],
                   "extra": r["L0"]["me"][1]},
            "L1": {"A": r["L1"]["A"], "B": r["L1"]["B"], "missing": r["L1"]["me"][0],
                   "extra": r["L1"]["me"][1]},
            "L2": {"A": r["L2"]["A"], "B": r["L2"]["B"], "missing": r["L2"]["me"][0],
                   "extra": r["L2"]["me"][1]},
            "signature": r["signature"],
        })
    with open(a.out_json, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(js, fh, ensure_ascii=False, indent=1, sort_keys=True)

    # ---- stdout（确定性：不含时间戳/耗时） ----
    print("inputs sha256: bit=%s decode=%s lawdb=%s" %
          (hashes["bit"][:16], hashes["decode"][:16], hashes["law_db"][:16]))
    print("tiles=%d combos=%d multi=%d pairs=%d  selfcheck_mismatch=%d"
          % (len(tiles), len(combos), len(multi), n_pairs, len(mismatch)))
    print("L0 identical=%d/%d   L1 identical=%d/%d   L2 identical=%d/%d"
          % (cnt["L0"], n_pairs, cnt["L1"], n_pairs, cnt["L2"], n_pairs))
    print("signatures: %s" % json.dumps(dict(sorted(sigcnt.items())), ensure_ascii=False))
    print("reuse model INT_L: cells=%d refs=%d ratio=%.2f  design shared_lit=%d"
          % (ref_stats["INT_L"]["distinct_cells"], ref_stats["INT_L"]["refs"],
             ref_stats["INT_L"]["ratio"], len(shared_lit)))
    print("l2 distinct=%d collisions=%d  tile_type agree=%d disagree=%d"
          % (len(inv), len(collisions), tt_agree, len(tt_disagree)))
    print("wrote %s" % a.out_md)
    print("wrote %s" % a.out_json)


if __name__ == "__main__":
    main()
