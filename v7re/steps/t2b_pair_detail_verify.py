#!/usr/bin/env python3
"""T2 自检：对 t2b_pair_detail.md 做独立复核（不回用生成脚本的中间变量）。

检查项：
  V1 §1 每行的「§2 行号」区间确实落在 md 内、含对应 `### 2.i` 标题、且区间内 tile 行数 == tile 数
  V2 区间内每个 tile 行的相对格字段与 §1「相对格」字段逐字相同
  V3 §0 的 220 / 68 与 __meta__ 的 cell_instances / cell_types 一致
  V4 独立从 _full8.bit 读原始 payload：抽样若干绝对位必须为 1，且窗口内随机对照位必须为 0
"""
import json
import os
import random
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "v7re", "scripts"))
import fasm2bit as F  # noqa: E402

MD = os.path.join(ROOT, "v7re", "steps", "t2b_pair_detail.md")
JSON = os.path.join(ROOT, "v7re", "steps", "t2b_pair_detail.json")
BIT = os.path.join(ROOT, "_full8.bit")

md = open(MD, encoding="utf-8").read().split("\n")
meta = json.load(open(JSON, encoding="utf-8"))["__meta__"]

fails = []


def chk(cond, msg):
    print(("PASS " if cond else "FAIL ") + msg)
    if not cond:
        fails.append(msg)


# ---- 解析 §1 ----
sec1 = {}
for line in md:
    m = re.match(r"^\| (\d+) \| `([^`]+)` \| `([^`]+)` \| (\d+) \| (\d+) \| (.+?) \| (.+?) \| (.+?) \| "
                 r"`([0-9a-f]{12})` \| L(\d+)–L(\d+) \|$", line)
    if m:
        sec1[int(m.group(1))] = {
            "family": m.group(2), "src": m.group(3),
            "tiles": int(m.group(4)), "cells": int(m.group(5)),
            "rel": m.group(6), "hash": m.group(9),
            "l0": int(m.group(10)), "l1": int(m.group(11)),
        }
chk(len(sec1) == 31, "§1 解析到 31 行（实得 %d）" % len(sec1))

# ---- 解析 §2 块 ----
blocks = {}
cur = None
for idx, line in enumerate(md, 1):
    m = re.match(r"^### 2\.(\d+) `([^`]+)` / `([^`]+)`（(\d+) tile）$", line)
    if m:
        cur = int(m.group(1))
        blocks[cur] = {"title_line": idx, "family": m.group(2), "src": m.group(3),
                       "tiles": int(m.group(4)), "rows": []}
        continue
    if cur:
        m = re.match(r"^\| `([^`]+)` \| (\d+) \| (\d+) \| (.+?) \| (.+?) \|$", line)
        if m:
            blocks[cur]["rows"].append({"line": idx, "tile": m.group(1),
                                        "base": int(m.group(2)), "y": int(m.group(3)),
                                        "rel": m.group(4), "abs": m.group(5)})
chk(len(blocks) == 31, "§2 解析到 31 块（实得 %d）" % len(blocks))

# ---- V1 / V2 ----
v1 = v2 = 0
for i in sorted(sec1):
    s, b = sec1[i], blocks[i]
    inside = s["l0"] <= b["title_line"] <= s["l1"]
    rows_in = [r for r in b["rows"] if s["l0"] <= r["line"] <= s["l1"]]
    ok1 = inside and len(rows_in) == s["tiles"] == b["tiles"] and s["family"] == b["family"] \
        and s["src"] == b["src"]
    chk(ok1, "V1 #%d 行号 L%d–L%d 覆盖标题 L%d 与 %d/%d 条 tile 行"
        % (i, s["l0"], s["l1"], b["title_line"], len(rows_in), s["tiles"]))
    v1 += ok1
    ok2 = all(r["rel"] == s["rel"] for r in rows_in) and s["cells"] == len(s["rel"].split())
    chk(ok2, "V2 #%d 区间内每行相对格 == §1 相对格（格数 %d）" % (i, s["cells"]))
    v2 += ok2

# ---- V3 ----
inst = sum(sec1[i]["tiles"] * sec1[i]["cells"] for i in sec1)
typ = sum(sec1[i]["cells"] for i in sec1)
chk(inst == 220 and inst == meta["cell_instances"], "V3a Σ tiles×cells = 220 = meta(%d)" % inst)
chk(typ == 68 and typ == meta["cell_types"], "V3b Σ cells = 68 = meta(%d)" % typ)

# ---- V4 独立 payload 抽样 ----
data, sp, words = F.load_words(BIT)
poff = F.payload_offset(words)
FW, EW = F.FRAME_WORDS, F.ECC_WORD


def bit_at(f, w, b):
    return (words[poff + f * FW + w] >> b) & 1


random.seed(7)
samples = []
for i in sorted(sec1):
    for r in blocks[i]["rows"]:
        for tok in r["abs"].split():
            f, w, b = [int(x) for x in tok.strip("()").split(",")]
            samples.append((f, w, b))
chk(len(samples) == 220, "V4a 绝对位样本数 = 220（= §0 格实例；实得 %d）" % len(samples))
bad = [(f, w, b) for (f, w, b) in samples if bit_at(f, w, b) != 1]
chk(not bad, "V4b 220 个绝对位在原始 payload 上全部为 1（异常 %d 个）" % len(bad))

# 对照（比 V4b 更强）：对全部 76 个 tile，PIP 窗口内实测置位位集合必须 == 该 tile 所有 family
# 的预测格并集。missing/extra 都必须为 0，否则 md 里的「格」就不是窗口的全部内容。
DECODE = os.path.join(ROOT, "v7re", "steps", "t2b_full8_decode.fasm")
model = F.Model(r"E:\v7work\model\v7_law.sqlite",
                os.path.join(ROOT, "v7re", "steps", "pip_reuse_law.json"),
                os.path.join(ROOT, "v7re", "steps", "ecc_model.json"),
                r"E:\v7work\model\v7_model.sqlite")
raw = set()
nf = (len(words) - poff) // FW
for f in range(nf):
    b0 = poff + f * FW
    for w in range(FW):
        if w == EW:
            continue
        v = words[b0 + w]
        while v:
            bit = (v & -v).bit_length() - 1
            raw.add((f, w, bit))
            v &= v - 1

by_tile = {}
for line in open(DECODE, encoding="utf-8"):
    s = line.strip().split(".")
    if len(s) == 3:
        by_tile.setdefault(s[0], []).append((s[1], s[2]))
chk(len(by_tile) == 76, "V4c 解码得到 76 个 INT tile（实得 %d）" % len(by_tile))

w_miss = w_extra = 0
for tile in sorted(by_tile):
    tt, base, y = model.tile_base(tile)
    declared = set()
    for fam, src in by_tile[tile]:
        declared |= {(base + fo, 2 * (y % 50) + par, b)
                     for (fo, b, par) in model.cells_of(tt, fam, src)}
    win = {(f, w, b) for (f, w, b) in raw
           if base <= f <= base + 25 and w in (2 * (y % 50), 2 * (y % 50) + 1)}
    w_miss += len(declared - win)
    w_extra += len(win - declared)
chk(w_miss == 0 and w_extra == 0,
    "V4d 76 tile 窗口 missing=%d extra=%d（必须都为 0）" % (w_miss, w_extra))

print("\nSUMMARY V1=%d/31 V2=%d/31 fails=%d" % (v1, v2, len(fails)))
sys.exit(1 if fails else 0)
