"""v7re.tilemap —— 通用「tile → 配置块」寻址层（P2 工程化）

替代散落的 clb_blocks 四级优先级 + 各 tile 类特判。三条 API：

    tile_block(name)      -> Block | None     该 tile 的配置块（base_frame, frame_count）
    cell(name, off, word, bit) -> (frame, word, bit)   把 tile 内相对位置换算成绝对位置
    word_of(y)            -> int             行内字基址（wof 规则）

地址模型（全部实测）：
    frame = block.base_frame + frame_off
    word  = word_of(tile_name_Y) + bit//32        # Y 取 tile 名的 Y，不是 grid_y
    bit   = bit % 32
    word_of(y) = 2*(y%50) + (1 if y%50 >= 25 else 0)

块的两种长度：36 帧（CLB 列，同时承载两侧 INT tile 的 mux 位）与 28 帧
（BRAM / DSP / 接口列）。块的先后按 band 内 grid 列从左到右累加。
"""
from __future__ import annotations

import bisect
import json
import os
import sqlite3
from dataclasses import dataclass

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)                       # E:\DEEPSEEK\FPGA比特流逆向
DEFAULT_LAW_DB = r"E:\v7work\model\v7_law.sqlite"
DEFAULT_MODEL_DB = r"E:\v7work\model\v7_model.sqlite"
TILEGRID = os.path.join(r"E:\v7work\db\prjxray\xc7vx485t", "tilegrid.json")

ROWS_PER_BAND = 50
CLB_FRAMES = 36
SMALL_FRAMES = 28


@dataclass(frozen=True)
class Block:
    base_frame: int
    frame_count: int
    band: int
    grid_col: int
    source: str = "derived"


def word_of(y: int) -> int:
    r = y % ROWS_PER_BAND
    return 2 * r + (1 if r >= 25 else 0)


class TileMap:
    """由 law DB 的 clb_blocks + tilegrid 重建完整的块表。"""

    def __init__(self, law_db: str = DEFAULT_LAW_DB, tilegrid: str = TILEGRID):
        self.law_db = law_db
        raw = json.load(open(tilegrid))
        # name -> (grid_x, grid_y, type, name_y)   band 用 tile 名的 Y，列用 grid_x
        self.tiles = {n: (v["grid_x"], v["grid_y"], v["type"],
                          int(n.rsplit("Y", 1)[1]))
                      for n, v in raw.items()}
        self._clb: dict[tuple[int, int], int] = {}
        con = sqlite3.connect(law_db)
        self.db = con
        for gc, band, base in con.execute("select grid_col,band,base_frame from clb_blocks"):
            self._clb[(gc, band)] = base
        self._load_measured()
        self._build_columns()
        self._build_blocks()

    def _load_measured(self) -> None:
        self.measured: dict[str, tuple[int, int]] = {}
        try:
            for n, b, c in self.db.execute(
                    "select tile_name, base_frame, frame_count from tile_blocks"):
                self.measured[n] = (b, c)
        except sqlite3.Error:
            pass

    # ---------- 列序列 ----------
    _SKIP = ("NULL", "VBRK", "T_TERM_INT", "BRKH_INT", "BRKH_CLB", "BRKH_BRAM",
             "BRKH_DSP")

    def _build_columns(self) -> None:
        """(band, grid_x) -> 该列上"有配置"的 tile 类型（NULL/VBRK 不算）。"""
        def rank(tt: str) -> int:
            if tt.startswith(("BRAM_L", "BRAM_R", "DSP_L", "DSP_R")) or \
               tt.endswith("_INTERFACE_L") or tt.endswith("_INTERFACE_R"):
                return 0
            if tt.startswith("CLB"):
                return 1
            if tt in ("INT_L", "INT_R"):
                return 2
            return 3

        self.col_type: dict[tuple[int, int], str] = {}
        self.col_rank: dict[tuple[int, int], int] = {}
        for name, (gx, gy, tt, ny) in self.tiles.items():
            b = ny // ROWS_PER_BAND
            if tt in self._SKIP:
                continue
            r = rank(tt)
            k = (b, gx)
            if k not in self.col_rank or r < self.col_rank[k]:
                self.col_rank[k] = r
                self.col_type[k] = tt
        self.band_cols = {}
        for (b, gx) in self.col_type:
            self.band_cols.setdefault(b, []).append(gx)
        for b in self.band_cols:
            self.band_cols[b].sort()

    # 独立占一个 28 帧块的列类型（INT_L/INT_R 默认与相邻 CLB 共用 36 帧块）
    ALLOC28 = ("BRAM_L", "BRAM_R", "DSP_L", "DSP_R",
               "BRAM_INT_INTERFACE_L", "BRAM_INT_INTERFACE_R",
               "INT_INTERFACE_L", "INT_INTERFACE_R",
               "IO_INT_INTERFACE_L", "IO_INT_INTERFACE_R")

    # 实测覆盖表：IO 夹缝列（无 CLB 邻列，基址无法递推）
    OVERRIDE = {("INT_L", 84, 1): 27322, ("INT_R", 85, 1): 27354}

    def _build_blocks(self) -> None:
        """按 band 内 grid_x 从左到右分配块：CLB=36 帧，BRAM/DSP/接口=28 帧。"""
        self.blocks: list[Block] = []
        self.col_block: dict[tuple[int, int], Block] = {}
        for band, cols in sorted(self.band_cols.items()):
            clb_bases = sorted(base for (g, b), base in self._clb.items()
                               if b == band)
            if not clb_bases:
                continue
            # clb_blocks 的 grid_col 是"帧块序列号"而非 grid_x：
            # 按 gx 升序把该带的 CLB 列与基址升序一一对齐
            clb_cols = [g for g in cols if self.col_rank.get((band, g)) == 1]
            gx2base = dict(zip(clb_cols, clb_bases))
            cursor = None          # 上一块的末尾帧号；None = 还没锚点
            for gx in cols:
                tt = self.col_type[(band, gx)]
                r = self.col_rank[(band, gx)]
                if r == 1 and gx in gx2base:
                    base, cnt = gx2base[gx], CLB_FRAMES
                elif (tt, gx, band) in self.OVERRIDE:
                    base, cnt = self.OVERRIDE[(tt, gx, band)], SMALL_FRAMES
                    cursor = base
                elif r == 0 and cursor is not None:
                    base, cnt = cursor, SMALL_FRAMES
                else:
                    continue        # INT_L/INT_R 与 CLB 共用，或左侧无锚点
                blk = Block(base, cnt, band, gx)
                self.blocks.append(blk)
                self.col_block[(gx, band)] = blk
                cursor = base + cnt
        self.blocks.sort(key=lambda b: b.base_frame)
        self._bases = [b.base_frame for b in self.blocks]

    # ---------- 查询 ----------
    def block_at_frame(self, frame: int) -> Block | None:
        i = bisect.bisect_right(self._bases, frame) - 1
        if i < 0:
            return None
        b = self.blocks[i]
        return b if frame < b.base_frame + b.frame_count else None

    def tile_block(self, name: str) -> Block | None:
        # MEASURED 优先：tile_blocks 表里是解码实测过的 (tile -> 块基址)
        if name in self.measured:
            base, cnt = self.measured[name]
            gx, gy, tt, ny = self.tiles.get(
                name, (None, None, None, None))
            return Block(base, cnt, (ny // ROWS_PER_BAND) if ny is not None else -1,
                         gx if gx is not None else -1,
                         source="measured")
        if name not in self.tiles:
            return None
        gx, gy, tt, ny = self.tiles[name]
        band = ny // ROWS_PER_BAND
        if tt in self._SKIP:
            return None
        if tt.startswith(("CLB", "BRKH")):
            return self.col_block.get((gx, band))
        if tt in self.ALLOC28:
            return self.col_block.get((gx, band))
        if tt in ("INT_L", "INT_R"):
            own = self.col_block.get((gx, band))
            if own and own.frame_count == SMALL_FRAMES:
                return own
            if (tt, gx, band) in self.OVERRIDE:
                return Block(self.OVERRIDE[(tt, gx, band)], SMALL_FRAMES,
                             band, gx)
            # S13 四级优先级：两侧 CLB → 西侧+36 → 西侧+68 → 东侧-28
            for d in (-1, +1):
                blk = self.col_block.get((gx + d, band))
                if blk and self.col_type.get((band, gx + d), "").startswith("CLB"):
                    return blk
            west = [c for c in self.band_cols[band] if c < gx]
            if west:
                w = max(west)
                wb = self.col_block.get((w, band))
                if wb:
                    cand = wb.base_frame + CLB_FRAMES
                    blk = self.block_at_frame(cand)
                    if blk:
                        return blk
            return None
        return self.col_block.get((gx, band))

    def cell(self, name: str, frame_off: int, word_field: int, bit_field: int):
        """tile 内 (off, word, bit) → 绝对 (frame, word, bit)。word_field 已含 bit//32。"""
        blk = self.tile_block(name)
        if blk is None:
            return None
        y = self.tiles[name][3]
        return (blk.base_frame + frame_off, word_of(y) + word_field, bit_field % 32)


_inst: TileMap | None = None


def get(law_db: str = DEFAULT_LAW_DB) -> TileMap:
    global _inst
    if _inst is None or _inst.law_db != law_db:
        _inst = TileMap(law_db)
    return _inst


if __name__ == "__main__":
    tm = get()
    print("blocks", len(tm.blocks), "bands", len(tm.band_cols))
    for n in ("SLICE_X8Y11", "INT_L_X6Y11", "BRAM_R_X29Y70", "DSP48_X0Y0",
              "SLICE_X10Y20", "INT_R_X23Y36"):
        blk = tm.tile_block(n)
        print(n, "->", (blk.base_frame, blk.frame_count) if blk else None)
