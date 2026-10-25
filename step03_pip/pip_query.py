"""PIP 位表查询 / 反解工具。

用法：
  python pip_query.py mux  CLBLL_L_X6Y11:IMUX_L7        # 列一个 mux 的源→位表
  python pip_query.py pip  "BYP_BOUNCE3->>IMUX_L7"       # 查一条 PIP 的位
  python pip_query.py decode ref.bit                     # 从比特流反解出 PIP
  python pip_query.py stats                              # 表规模

默认库：E:\\v7work\\model\\v7_model.sqlite，可用 --db 指定。

表口径（2026-10-25 迁移后）：
  kind='route'   -> frame/word/bit 有值，表示「选这个源要置的位」
  kind='default' -> 坐标列为 NULL，表示「默认源，不置任何选择位」
  bump: --source 只筛某个来源（tilepipe_20261025 / step03_pip_20261024）
"""
import argparse
import collections
import os
import sqlite3
import sys

DEFAULT_DB = r"E:\v7work\model\v7_model.sqlite"
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "v7re"))


def load_muxes(conn, source=None):
    q = ("SELECT tile,wire_b,wire_a,frame,word,bit,source,kind FROM pip_bits")
    args = ()
    if source:
        q += " WHERE source=?"
        args = (source,)
    muxes = collections.defaultdict(lambda: collections.defaultdict(set))
    kinds = collections.defaultdict(dict)   # (tile,sink) -> src -> 'default'|'route'
    tags = collections.defaultdict(set)
    for tile, sink, src, fr, wd, bt, tag, kind in conn.execute(q, args):
        slot = muxes[(tile, sink)][src]  # 不存在时创建空集
        if fr is not None:
            slot.add((fr, wd, bt))
        elif kind != "default":
            raise ValueError("route row without coords: %s %s" % (tile, src))
        kinds[(tile, sink)][src] = kind
        tags[(tile, sink)].add(tag)
    return muxes, tags, kinds


def cmd_mux(conn, key, source):
    tile, sink = key.split(":")
    muxes, tags, kinds = load_muxes(conn, source)
    m = muxes.get((tile, sink))
    if not m:
        print("not found:", key)
        return 1
    print("%s %s  sources=%d  source_tag=%s" % (tile, sink, len(m), ",".join(sorted(tags[(tile, sink)]))))
    print("%-16s %-3s %s" % ("wire", "n", "bits (frame/word/bit)"))
    for src in sorted(m):
        bs = sorted(m[src])
        if not bs:
            print("%-16s %-3d %s" % (src, 0, "(默认源：不置任何选择位)"))
            continue
        print("%-16s %-3d %s" % (src, len(bs), " ".join("%d/%d/%d" % b for b in bs)))
    return 0


def cmd_pip(conn, expr, source):
    if "->>" in expr:
        src, sink = expr.split("->>")
    else:
        src, sink = expr.split("->")
    muxes, _, _ = load_muxes(conn, source)
    hits = [(tile, m[src]) for (tile, s), m in muxes.items() if s == sink and src in m]
    if not hits:
        print("no pips for", expr)
        return 1
    for tile, bits in sorted(hits):
        print("%-18s %-16s ->> %-10s %s" % (tile, src, sink, " ".join("%d/%d/%d" % b for b in sorted(bits))))
    return 0


def cmd_stats(conn):
    print("pip_bits rows", conn.execute("SELECT count(*) FROM pip_bits").fetchone()[0])
    for src, n in conn.execute("SELECT source,count(*) FROM pip_bits GROUP BY source"):
        print("  %-24s %d" % (src, n))
    for kind, n in conn.execute("SELECT kind,count(*) FROM pip_bits GROUP BY kind"):
        print("  kind=%-16s %d" % (kind, n))
    print("tiles", conn.execute("SELECT count(DISTINCT tile) FROM pip_bits_mapped").fetchone()[0],
          "muxes", conn.execute("SELECT count(*) FROM (SELECT DISTINCT tile,wire_b FROM pip_bits)").fetchone()[0],
          "default-sources", conn.execute("SELECT count(*) FROM pip_bits WHERE kind='default'").fetchone()[0])
    print("每 tile 的 mux 数：")
    for tile, n in conn.execute("SELECT tile,count(*) FROM (SELECT DISTINCT tile,wire_b FROM pip_bits) GROUP BY tile ORDER BY tile"):
        print("  %-18s %d" % (tile, n))
    return 0


def cmd_decode(conn, bit_path, source):
    from bitstream.parser import frames_from_bit  # v7re 解析器

    frames = frames_from_bit(bit_path)
    muxes, tags, _ = load_muxes(conn, source)

    def bit_at(coord):
        fr, wd, bt = coord
        if fr >= len(frames):
            return 0
        word = frames[fr][wd] if wd < len(frames[fr]) else 0
        return (word >> bt) & 1

    print("frames", len(frames))
    exact = near = miss = 0
    for (tile, sink), m in sorted(muxes.items()):
        alphabet = {c for bs in m.values() for c in bs}
        on = {c for c in alphabet if bit_at(c)}
        best, best_score = None, -1.0
        for src, bs in m.items():
            score = len(on & bs) / max(1, len(bs | on))
            if score > best_score:
                best, best_score = src, score
        if on == m[best]:
            exact += 1
            flag = "EXACT"
        elif best_score >= 0.5:
            near += 1
            flag = "near"
        else:
            miss += 1
            continue
        print("%-18s %-10s -> %-16s %-5s jaccard=%.2f on=%d" %
              (tile, sink, best, flag, best_score, len(on)))
    print("exact=%d near=%d skip=%d total=%d" % (exact, near, miss, len(muxes)))
    return 0


def cmd_imux(conn, mux):
    """IMUX 输入编码表（① 的解）：mux + 源 -> (row, col_code, index)。"""
    q = ("SELECT tile_type,mux,lut_input,src_wire,row,col_code,col_index,idx,field_bit "
         "FROM imux_codes")
    args = ()
    if mux:
        q += " WHERE mux=?"
        args = (mux,)
    q += " ORDER BY tile_type, lut_input, row, col_index"
    cur = conn.execute(q, args)
    last = None
    for ttype, m, lut, wire, row, code, ci, idx, fb in cur:
        if (ttype, m) != last:
            print("%s %s  lut=%d field_bit=%d" % (ttype, m, lut, fb))
            print("  %-18s %-2s %-6s %-5s %-4s" % ("wire", "row", "code", "col", "idx"))
            last = (ttype, m)
        print("  %-18s %-2d %-6s %-5d %-4d" % (wire, row, code, ci, idx))
    return 0


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["mux", "pip", "decode", "stats", "imux"])
    ap.add_argument("arg", nargs="?")
    ap.add_argument("--db", default=DEFAULT_DB)
    ap.add_argument("--source")
    a = ap.parse_args()
    conn = sqlite3.connect(a.db)
    if a.cmd == "mux":
        return cmd_mux(conn, a.arg, a.source)
    if a.cmd == "pip":
        return cmd_pip(conn, a.arg, a.source)
    if a.cmd == "stats":
        return cmd_stats(conn)
    if a.cmd == "imux":
        return cmd_imux(conn, a.arg)
    return cmd_decode(conn, a.arg, a.source)


if __name__ == "__main__":
    sys.exit(main())
