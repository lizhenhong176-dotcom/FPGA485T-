"""IMUX 输入编码表生成器（① 求解 mux 物理输入序号）。

思路
----
1. 从 prjxray 的 7 系列 INT 瓦片 segbits 数据库（本地 prjxray_ref/artix7/）
   解析每个 IMUX mux 的 24 个输入，每个输入由一组位描述：
       - 行选择：word 16..21 中的恰好一个置位（bit 02 或 03）
       - 列选择：word 22..25 的四位码（0001 / 0010 / 1011 / 0111）
   48 个 mux × 24 输入，每个输入落在唯一个 (row, col) 坐标上。
2. 用我们自己的 485T 实测数据（tilepipe.json，36 个 mux × 24 源）做交叉验证：
   把实测掩码归一化成 (row, col_code)，逐条比对 segbits。
3. 验证通过后，输出完整表（INT_L + INT_R 共 96 个 mux × 24 输入），
   并写入 SQLite（imux_codes 表）。

坐标约定
--------
row     : 0..5，对应 word 16..21
col_code: 4 位串，对应 word 22..25 的置位模式（'0' 取反 / '1' 置位）
物理输入序号 index = row * 4 + col_index，其中 col_index 按
    0001 -> 0, 0010 -> 1, 1011 -> 2, 0111 -> 3
（该顺序只是我们自己的编号，硅片只认 (row, col_code) 这组位模式。）

用法::

    python gen_imux_table.py            # 验证并生成 CSV + JSON
    python gen_imux_table.py --ingest   # 另外写入 model 数据库
"""
from __future__ import annotations

import argparse
import collections
import json
import os
import re
import sqlite3
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SEGBITS = [
    (r"E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7\segbits_int_l.db", "INT_L"),
    (r"E:\DEEPSEEK\FPGA比特流逆向\prjxray_ref\artix7\segbits_int_r.db", "INT_R"),
]
TILEPIPE = os.path.join(HERE, "tilepipe.json")
DB = r"E:\v7work\model\v7_model.sqlite"

COL_ORDER = {"0001": 0, "0010": 1, "1011": 2, "0111": 3}
COL_BY_FRAMES = {
    frozenset({8}): "0010",
    frozenset({9}): "0001",
    frozenset({6, 8, 9}): "1011",
    frozenset({7, 8, 9}): "0111",
}


def bit_base(lut_input: int) -> int:
    """我们实测的字段基位：bit = 1 + 8*(L%4) + (L//8)。"""
    return 1 + 8 * (lut_input % 4) + (lut_input // 8)


def parse_segbits(path: str, tile_type: str) -> dict[str, dict[str, tuple[int, str]]]:
    """mux -> {src_wire: (row, col_code)}。"""
    out: dict[str, dict[str, tuple[int, str]]] = {}
    # INT_L 的 mux 叫 IMUX_L0..L47；INT_R 的叫 IMUX0..IMUX47（无 _L）
    rx = re.compile(r"%s\.(IMUX(?:_L)?\d+)\.(.+)$" % re.escape(tile_type))
    for line in open(path, encoding="utf-8"):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        m = rx.match(parts[0])
        if not m:
            continue
        row = None
        code = [None] * 4
        for tok in parts[1:]:
            neg = tok.startswith("!")
            tok = tok.lstrip("!")
            word, bit = (int(x) for x in tok.split("_"))
            if 16 <= word <= 21:
                row = word - 16
            elif 22 <= word <= 25:
                code[word - 22] = "0" if neg else "1"
        if row is None or any(c is None for c in code):
            continue
        out.setdefault(m.group(1), {})[m.group(2)] = (row, "".join(code))
    return out


def lattice(rec: dict) -> dict[str, tuple[int, str]]:
    """把一次 tilepipe 实测记录归一化成 (row, col_code)，与 segbits 同构。"""
    lut = int(re.search(r"(\d+)$", rec["sink"]).group(1))
    b0 = bit_base(lut)
    frames = [c[0] for cells in rec["sources"].values() for c in cells]
    if not frames:
        return {}
    f0 = min(frames)
    out = {}
    for src, cells in rec["sources"].items():
        norm = {(fr - f0, b - b0) for fr, _w, b in cells}
        if not norm:
            continue
        rows = {c[0] for c in norm if c[0] < 6}
        sig = frozenset(c[0] for c in norm if c[0] >= 6)
        if len(rows) != 1 or sig not in COL_BY_FRAMES:
            continue
        out[src] = (rows.pop(), COL_BY_FRAMES[sig])
    return out


def validate(seg: dict[str, dict[str, tuple[int, str]]]) -> tuple[int, int, int, list]:
    data = json.load(open(TILEPIPE, encoding="utf-8-sig"))
    total = row_ok = col_ok = 0
    bad = []
    for rec in data.values():
        mux = rec["sink"]
        ref = seg.get(mux, {})
        for wire, rc in lattice(rec).items():
            if wire not in ref:
                continue
            total += 1
            row_ok += rc[0] == ref[wire][0]
            col_ok += rc[1] == ref[wire][1]
            if rc != ref[wire]:
                bad.append((mux, wire, rc, ref[wire]))
    return total, row_ok, col_ok, bad


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--ingest", action="store_true")
    args = ap.parse_args()

    tables = {}
    for path, ttype in SEGBITS:
        if not os.path.exists(path):
            print("missing", path)
            continue
        tables[ttype] = parse_segbits(path, ttype)
        n_mux = len(tables[ttype])
        n_edge = sum(len(v) for v in tables[ttype].values())
        print("%s: %d mux, %d input edges" % (ttype, n_mux, n_edge))

    total, row_ok, col_ok, bad = validate(tables["INT_L"])
    print("validate vs 485T tilepipe: compared=%d row_exact=%d col_exact=%d bad=%d"
          % (total, row_ok, col_ok, len(bad)))
    for b in bad[:5]:
        print("  mismatch", b)
    if total == 0 or row_ok != total or col_ok != total:
        print("VALIDATION FAILED — refuse to emit table")
        return 1

    rows = []
    for ttype, muxes in tables.items():
        for mux in sorted(muxes, key=lambda m: int(re.search(r"(\d+)$", m).group(1))):
            lut = int(re.search(r"(\d+)$", mux).group(1))
            b0 = bit_base(lut)
            for wire, (row, code) in sorted(muxes[mux].items()):
                rows.append({
                    "tile_type": ttype,
                    "mux": mux,
                    "lut_input": lut,
                    "src_wire": wire,
                    "row": row,
                    "row_word": 16 + row,
                    "col_code": code,
                    "col_index": COL_ORDER[code],
                    "index": row * 4 + COL_ORDER[code],
                    "field_bit": b0,
                })

    out_json = os.path.join(HERE, "imux_codes.json")
    json.dump(rows, open(out_json, "w", encoding="utf-8"), indent=1)
    print("wrote", out_json, len(rows), "rows")

    if args.ingest:
        conn = sqlite3.connect(DB)
        conn.executescript("""
            DROP TABLE IF EXISTS imux_codes;
            CREATE TABLE imux_codes (
                tile_type TEXT NOT NULL,
                mux       TEXT NOT NULL,
                lut_input INTEGER NOT NULL,
                src_wire  TEXT NOT NULL,
                row       INTEGER NOT NULL,
                row_word  INTEGER NOT NULL,
                col_code  TEXT NOT NULL,
                col_index INTEGER NOT NULL,
                idx       INTEGER NOT NULL,
                field_bit INTEGER NOT NULL,
                source    TEXT NOT NULL DEFAULT 'prjxray_a7_20261025',
                PRIMARY KEY (tile_type, mux, src_wire)
            );
        """)
        conn.executemany(
            "INSERT INTO imux_codes VALUES (?,?,?,?,?,?,?,?,?,?,?)",
            [(r["tile_type"], r["mux"], r["lut_input"], r["src_wire"], r["row"],
              r["row_word"], r["col_code"], r["col_index"], r["index"],
              r["field_bit"], "prjxray_a7_20261025") for r in rows],
        )
        conn.commit()
        n = conn.execute("SELECT COUNT(*) FROM imux_codes").fetchone()[0]
        print("ingested imux_codes rows:", n)
    return 0


if __name__ == "__main__":
    sys.exit(main())
