"""int_base_solve.py — 用真实位流反解 INT tile 的帧基址，并验证 law_cells 的格。

原理：law_cells 给出 (family, src) 在 tile 内的相对 (frame_off, bit, parity)；
     位流里若该 PIP 被使用，则 base+frame_off 帧的 word(y,parity) 的第 bit 位为 1。
     对 tile 的全部 PIP 取下界约束，暴力扫 base，唯一解即为该 tile 的帧基址。

用法：
    python int_base_solve.py <design>.bit <design>.pips [--limit N] [--long]
    python int_base_solve.py <design>.bit <design>.pips --fixed

--long  只统计长线族（LV/LH/LVB）的验证结果。
--fixed 不暴力扫 base，直接用 `tile_blocks_fixed`（§201 基址律）当基址，
        只做验证。53,102 个 INT tile 全覆盖，比暴力扫快几个数量级；
        两者结果一致时正好互为交叉自证。
"""
import os, re, sqlite3, collections, sys

LAW = r"E:\v7work\model\v7_law.sqlite"
LONG = ("LV_L0", "LV_L18", "LH0", "LH12", "LVB_L0", "LVB_L12", "LV_L9", "LH6")


def load_law(path=LAW):
    con = sqlite3.connect(path)
    cells = collections.defaultdict(list)
    fam_src = collections.defaultdict(set)
    for tt, f, s, fo, b, se, p, idx in con.execute(
            "select * from law_cells where tile_type in ('INT_L','INT_R')"):
        if se == 1:
            cells[(tt, f, s)].append((fo, b, p))
            fam_src[(tt, f)].add(s)
    tiles = {r[0]: (r[1], r[2]) for r in
             con.execute("select tile_name,tile_type,y from law_tiles")}
    con.close()
    return cells, fam_src, tiles


def load_fixed(path=LAW):
    """§201 基址律的修正结果：tile -> 块基址（53,102 个 INT_L/INT_R tile）。"""
    con = sqlite3.connect("file:%s?mode=ro" % path, uri=True)
    try:
        return {n: b for n, b in
                con.execute("select tile_name, base_frame from tile_blocks_fixed")}
    finally:
        con.close()


def parse_pips(path):
    by = collections.defaultdict(set)
    for line in open(path, encoding="utf-8", errors="ignore"):
        m = re.search(r"(INT_[LR]_X\d+Y\d+)/INT_[LR]\.(\S+?)(?:<<)?->>(\S+)", line)
        if m:
            by[m.group(1)].add((m.group(2), m.group(3)))
    return by


def word_of(y, parity):
    r = y % 50
    return 2 * r + (1 if r >= 25 else 0) + parity


def solve(frames, cells, y, limit=None):
    limit = limit or len(frames) - 40
    out = []
    for base in range(limit):
        if all((frames[base + fo][word_of(y, p)] >> b) & 1 for fo, b, p in cells):
            out.append(base)
    return out


def main():
    sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    from bitstream.parser import frames_from_bit
    bit, pips = sys.argv[1], sys.argv[2]
    only_long = "--long" in sys.argv
    use_fixed = "--fixed" in sys.argv
    cells_db, fam_src, tiles = load_law()
    F = frames_from_bit(bit)
    by = parse_pips(pips)
    bases, uniq, amb, none = {}, 0, 0, 0
    if use_fixed:
        # 直接查表当基址：不需要每 tile 扫 5,068,319 个候选
        fixed = load_fixed()
        for tile, pairs in by.items():
            t = tiles.get(tile)
            if not t or tile not in fixed:
                continue
            bases[tile] = fixed[tile]
            uniq += 1
        print(f"[--fixed] tiles taken from tile_blocks_fixed: {uniq}")
    else:
        for tile, pairs in by.items():
            t = tiles.get(tile)
            if not t:
                continue
            tt, y = t
            cs = [c for src, dst in pairs for c in cells_db.get((tt, dst, src), [])]
            if len(cs) < 4:
                continue
            h = solve(F, cs, y)
            if len(h) == 1:
                bases[tile] = h[0]; uniq += 1
            elif h:
                amb += 1
            else:
                none += 1
        print(f"tiles with unique base: {uniq}  ambiguous: {amb}  none: {none}")
    ll_tot = ll_ok = 0
    all_tot = all_ok = 0
    bad = []
    for tile, base in bases.items():
        tt, y = tiles[tile]
        for src, dst in by[tile]:
            cs = cells_db.get((tt, dst, src), [])
            if not cs:
                continue
            hit = all((F[base + fo][word_of(y, p)] >> b) & 1 for fo, b, p in cs)
            all_tot += 1
            all_ok += hit
            if not hit and len(bad) < 12:
                bad.append((tile, src, dst))
            if not (dst in LONG or src in LONG):
                continue
            ll_tot += 1
            ll_ok += hit
    print(f"long-line PIPs checked: {ll_tot}  all-cells-set: {ll_ok}")
    print(f"all PIPs checked: {all_tot}  all-cells-set: {all_ok}"
          + (f"  ({100.0 * all_ok / all_tot:.2f}%)" if all_tot else ""))
    if bad:
        print("  first misses:", bad)
    for tile in sorted(bases)[:10]:
        print(f"  {tile} base={bases[tile]}")


if __name__ == "__main__":
    main()
