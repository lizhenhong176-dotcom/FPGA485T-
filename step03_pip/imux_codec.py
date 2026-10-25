# -*- coding: utf-8 -*-
"""IMUX 编解码器（位级）。

用法::

    python imux_codec.py list  IMUX_L7                 # 该 mux 的 24 个输入位模式
    python imux_codec.py read  some.bit --mux IMUX_L7  # 从比特流读出一个 mux 的选择
    python imux_codec.py write in.bit out.bit --mux IMUX_L7 --src BYP_BOUNCE3

坐标约定
--------
- 帧：`base + df`，`df = segbits word - 16`（0..9）
- 字：IMUX 字段所在字，INT_L/CLBLL_L 为 23（写死，右半 tile 待实测确认）
- 位：`bit`，物理 0..31

编码 = 先把该 mux 的完整域（`imux_domain.json`，10 个单元）清零，再置位目标源的
正极性位。这样从一个源切到另一个源不需要知道原状态。
"""
from __future__ import annotations

import argparse
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CELLS = os.path.join(HERE, "imux_cells.json")
DOMAIN = os.path.join(HERE, "imux_domain.json")
FIELD_WORD = {"INT_L": 23, "INT_R": 23}   # 默认值；实际字由 mux 号决定，见 field_word()
BASE_FRAME = {"INT_L": 31696, "INT_R": 31732}   # 实测：左半 31696、右半 31732（Step03 早期）

sys.path.insert(0, os.path.join(ROOT, "v7re"))


def field_word(mux: str) -> int:
    """IMUX 字段所在字：22 + ((L//4) % 2)。L8 -> 22，L7 -> 23（pip_bits 实测）。"""
    lut = int("".join(ch for ch in mux if ch.isdigit()))
    return 22 + ((lut // 4) % 2)


class ImuxTable:
    def __init__(self, cells_path=CELLS, domain_path=DOMAIN):
        self.pos = {}      # (ttype,mux,src) -> set((df,bit))
        self.muxes = {}    # (ttype,mux) -> set(src)
        self.domain = {}   # (ttype,mux) -> set((df,bit))
        for r in json.load(open(cells_path, encoding="utf-8")):
            key = (r["tile_type"], r["mux"], r["src_wire"])
            self.muxes.setdefault((r["tile_type"], r["mux"]), set()).add(r["src_wire"])
            if r["sense"]:
                self.pos.setdefault(key, set()).add((r["df"], r["bit"]))
        for k, v in json.load(open(domain_path, encoding="utf-8")).items():
            ttype, mux = k.split("|")
            self.domain[(ttype, mux)] = {(a, b) for a, b in v}
        # 没有正极性位的源就是默认源
        for (ttype, mux), srcs in self.muxes.items():
            for s in srcs:
                self.pos.setdefault((ttype, mux, s), set())

    # --- 位操作 -------------------------------------------------------
    @staticmethod
    def _get(frames, df, bit, base, word):
        fr = frames[base + df]
        return (fr[word] >> bit) & 1

    @staticmethod
    def _set(frames, df, bit, base, word, val):
        fr = frames[base + df]
        if val:
            fr[word] |= 1 << bit
        else:
            fr[word] &= ~(1 << bit)

    # --- 编码 / 解码 ---------------------------------------------------
    def encode(self, frames, ttype, mux, src, base=None, word=None):
        base = BASE_FRAME[ttype] if base is None else base
        word = field_word(mux) if word is None else word
        targets = self.pos.get((ttype, mux, src))
        if targets is None:
            raise KeyError("no such source %s/%s/%s" % (ttype, mux, src))
        for df, bit in self.domain[(ttype, mux)]:
            self._set(frames, df, bit, base, word, 0)
        for df, bit in targets:
            self._set(frames, df, bit, base, word, 1)
        return frames

    def read(self, frames, ttype, mux, base=None, word=None):
        base = BASE_FRAME[ttype] if base is None else base
        word = field_word(mux) if word is None else word
        on = {(df, bit) for df, bit in self.domain[(ttype, mux)]
              if self._get(frames, df, bit, base, word)}
        if not on:
            return "VCC_WIRE", True   # 默认源：整域为 0
        for src in sorted(self.muxes[(ttype, mux)]):
            if self.pos[(ttype, mux, src)] == on:
                return src, True
        # 没有精确匹配：返回最接近的
        best, score = None, -1
        for src in sorted(self.muxes[(ttype, mux)]):
            p = self.pos[(ttype, mux, src)]
            j = len(p & on) / max(1, len(p | on))
            if j > score:
                best, score = src, j
        return best, False


def load_frames(path):
    from bitstream.parser import frames_from_bit
    return frames_from_bit(path)


def cmd_list(table, mux):
    for ttype in ("INT_L", "INT_R"):
        if (ttype, mux) not in table.muxes:
            continue
        print("%s %s  domain=%s" % (ttype, mux, sorted(table.domain[(ttype, mux)])))
        for src in sorted(table.muxes[(ttype, mux)]):
            cells = sorted(table.pos[(ttype, mux, src)])
            pat = " ".join("%d/%d" % c for c in cells) or "(默认：全清)"
            print("  %-18s %s" % (src, pat))
    return 0


def cmd_read(table, bit, mux):
    frames = load_frames(bit)
    for ttype in ("INT_L", "INT_R"):
        if (ttype, mux) in table.muxes:
            src, exact = table.read(frames, ttype, mux)
            print("%s %s -> %s%s" % (ttype, mux, src, "" if exact else "  (NOT EXACT)"))
    return 0


def fdri_payload_span(data: bytes):
    """返回 FDRI 数据区在文件中的 (字节起点, 字节终点)。"""
    pos = data.find(b"\xAA\x99\x55\x66")
    if pos < 0:
        raise ValueError("no sync")
    start = pos + 4
    words = struct.unpack(">%dI" % ((len(data) - start) // 4), data[start:start + ((len(data) - start) // 4) * 4])
    i = 0
    payload_start = payload_end = None
    while i < len(words):
        h = words[i]
        i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            n = h & 0x7FFFFFF
            i += n
            continue
        if typ != 1:
            break
        if op == 0:
            continue
        if op == 1:
            i += 1
            continue
        if addr == 0x02:  # FDRI
            if cnt == 0:
                t2 = words[i]
                i += 1
                n = t2 & 0x7FFFFFF
            else:
                n = cnt
            if payload_start is None:
                payload_start = start + i * 4
            i += n
            payload_end = start + i * 4
            continue
        i += cnt
    return payload_start, payload_end


def cmd_write(table, src_path, dst_path, mux, wire, ttype):
    data = bytearray(open(src_path, "rb").read())
    frames = load_frames(src_path)
    table.encode(frames, ttype, mux, wire)
    ps, pe = fdri_payload_span(bytes(data))
    flat = b"".join(struct.pack(">I", w) for fr in frames for w in fr)
    if len(flat) != pe - ps:
        raise ValueError("payload size mismatch: %d vs %d" % (len(flat), pe - ps))
    data[ps:pe] = flat
    open(dst_path, "wb").write(bytes(data))
    print("wrote", dst_path, "mux=%s src=%s (%s)" % (mux, wire, ttype))
    return 0


def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    a = sub.add_parser("list"); a.add_argument("mux")
    b = sub.add_parser("read"); b.add_argument("bit"); b.add_argument("--mux", required=True)
    c = sub.add_parser("write")
    c.add_argument("src"); c.add_argument("dst"); c.add_argument("--mux", required=True)
    c.add_argument("--src-wire", dest="wire", required=True)
    c.add_argument("--tile-type", default="INT_L")
    ns = ap.parse_args()
    table = ImuxTable()
    if ns.cmd == "list":
        return cmd_list(table, ns.mux)
    if ns.cmd == "read":
        return cmd_read(table, ns.bit, ns.mux)
    return cmd_write(table, ns.src, ns.dst, ns.mux, ns.wire, ns.tile_type)


if __name__ == "__main__":
    sys.exit(main())
