"""v7re.blockmap —— 每 band 的「配置块序列」模型（P2 寻址层定案）

实测事实（S32，2026-11-09）：
  * 每 band 恰 5,180 帧，块尺寸签名固定：
        band 0/3/4/5/6 : 111×36 + 35×28 + 2×30 + 2×72          = 5,180 （150 块）
        band 1/2 (PCIE) : 105×36 + 35×28 + 1×30 + 2×72 + 1×246  = 5,180 （144 块）
  * 36 = CLB 列块（在 clb_blocks 实测），28 = BRAM/DSP/接口，
    72 = IO 列，246 = PCIE 区，30 = 边缘接口。
  * 块基址 = band 起点的前缀和；子块（gap）基址 = 前一块基址 + 前一块长度。
  * Y 不改变块（Y 差分实测：Y20 与 Y24 落在同一组帧，只有 word 从 40 变 48）。

本模块把上面的模型变成可查询的表，并给出「某 tile 可能属于哪一块」的候选集合，
供按列实测消歧使用（不要用命中数仲裁，见 S31 T4d）。
"""
from __future__ import annotations

import collections
import json
import os
import sqlite3

LAW_DB = r"E:\v7work\model\v7_law.sqlite"
TILEGRID = os.path.join(r"E:\v7work\db\prjxray\xc7vx485t", "tilegrid.json")

CLB_FRAMES = 36
BAND_FRAMES = 5180          # 每 band 的 fabric 帧预算（实测闭合）


def band_of(y_name: int) -> int:
    return y_name // 50


def word_of(y_name: int) -> int:
    r = y_name % 50
    return 2 * r + (1 if r >= 25 else 0)


def load(law_db: str = LAW_DB, tilegrid: str = TILEGRID):
    """返回 (blocks, tiles)。

    blocks[band] = [ {base, size, kind, grid_col} , ... ] 按 base 升序
    tiles[name]  = (grid_x, grid_y, type, name_y)
    """
    con = sqlite3.connect(law_db)
    clb = collections.defaultdict(list)
    for gc, band, base in con.execute(
            "select grid_col, band, base_frame from clb_blocks"):
        clb[band].append((base, gc))
    for b in clb:
        clb[b].sort()

    blocks = {}
    for band, lst in clb.items():
        out = []
        for i, (base, gc) in enumerate(lst):
            out.append({"base": base, "size": CLB_FRAMES, "kind": "clb", "grid_col": gc})
            if i + 1 < len(lst):
                gap = lst[i + 1][0] - (base + CLB_FRAMES)
                if gap > 0:
                    kind = {28: "gap28", 30: "edge30", 72: "io72", 246: "pcie"}.get(gap, f"gap{gap}")
                    out.append({"base": base + CLB_FRAMES, "size": gap,
                                "kind": kind, "grid_col": None})
        out.sort(key=lambda d: d["base"])
        blocks[band] = out

    raw = json.load(open(tilegrid))
    tiles = {n: (v["grid_x"], v["grid_y"], v["type"], int(n.rsplit("Y", 1)[1]))
             for n, v in raw.items()}
    return blocks, tiles


def budget_report(blocks) -> dict:
    """核对每 band 的帧预算是否闭合（应全部 5,180）。"""
    rep = {}
    for band, lst in blocks.items():
        sizes = collections.Counter(d["size"] for d in lst)
        rep[band] = {"blocks": len(lst), "sum": sum(d["size"] for d in lst),
                     "sizes": dict(sorted(sizes.items()))}
    return rep


def candidates(blocks, tiles, name: str):
    """该 tile 可能所属的块基址候选（按 grid_x 邻接给出，最多 3 个）。

    返回 [(base, kind, why), ...]；空表示 tile 不在 fabric（IO/时钟等）。
    """
    if name not in tiles:
        return []
    gx, _gy, tt, y_name = tiles[name]
    band = band_of(y_name)
    if band not in blocks:
        return []
    seq = blocks[band]
    clbs = [d for d in seq if d["kind"] == "clb"]
    west = [d for d in clbs if d["grid_col"] < gx]
    east = [d for d in clbs if d["grid_col"] > gx]
    if not west or not east:
        return []
    w = max(west, key=lambda d: d["grid_col"])
    e = min(east, key=lambda d: d["grid_col"])
    after = [d for d in seq if d["base"] == w["base"] + w["size"]]
    before = [d for d in seq if d["base"] + d["size"] == e["base"]]
    out = []
    if before:
        out.append((before[0]["base"], before[0]["kind"], "gap-before-east-clb"))
    out.append((w["base"], "clb", "west-clb"))
    if after:
        out.append((after[0]["base"], after[0]["kind"], "gap-after-west-clb"))
    out.append((e["base"], "clb", "east-clb"))
    seen, uniq = set(), []
    for b, k, why in out:
        if b not in seen:
            seen.add(b)
            uniq.append((b, k, why))
    return uniq[:3]


def measured(law_db: str = LAW_DB) -> dict:
    """tile -> 块基址。优先用 §201 修正后的 `tile_blocks_fixed`
    （旧 `tile_blocks` 有 28.5% 的 tile 基址偏了一个邻居块），
    表不存在时回落到旧表。"""
    con = sqlite3.connect(law_db)
    try:
        return {n: b for n, b in con.execute("select tile_name, base_frame from tile_blocks_fixed")}
    except sqlite3.Error:
        try:
            return {n: b for n, b in con.execute("select tile_name, base_frame from tile_blocks")}
        except sqlite3.Error:
            return {}
    finally:
        con.close()


if __name__ == "__main__":
    blocks, tiles = load()
    rep = budget_report(blocks)
    for band in sorted(rep):
        print("band", band, rep[band])
    meas = measured()
    bases = {d["base"] for lst in blocks.values() for d in lst}
    hit = sum(1 for v in meas.values() if v in bases)
    print(f"measured {len(meas)} / bases-as-block {hit}")
    for t in ("INT_L_X10Y11", "INT_R_X15Y20", "INT_L_X32Y50", "SLICE_X8Y11"):
        print(t, candidates(blocks, tiles, t))
