#!/usr/bin/env python3
"""fasm2bit.py —— FASM 行 → 位流（覆盖 mux 区 64 族 + law_cells 表内族）。

FASM 行格式（本项目的规范形式）：

    INT_L_X8Y20.IMUX_L5.WR1END2
    INT_L_X8Y20.BYP_ALT0.BYP_BOUNCE0
    # 注释

语义：同一 tile 的同一 family **互斥**（一个 mux 只能选一个源）。
写入时先把该 family 的全部候选源位置清零，再点亮指定源的位置。

ECC：受影响帧的 word50 低 13 位按 `ecc_model.json` 重算；
模型未覆盖的位置直接报错（不猜）。

用法：
    python fasm2bit.py --in base.bit --out out.bit --fasm design.fasm [--blank]
    python fasm2bit.py --in base.bit --decode          # 反方向：位流 → FASM 行
"""
import argparse
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

import numpy as np  # noqa: E402
from bitstream.parser import parse_bit  # noqa: E402
import clk_mux_bits  # noqa: E402

SYNC = b"\xAA\x99\x55\x66"
FRAME_WORDS = 101
ECC_WORD = 50
NEXC = 32
MUX_PREFIX = ("IMUX", "BYP_ALT", "FAN_ALT")


def load_words(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    n = (len(data) - pos - 4) // 4
    return data, pos, list(struct.unpack(">%dI" % n, data[pos + 4:pos + 4 + 4 * n]))


def payload_offset(words):
    i = 0
    while i < len(words):
        h = words[i]
        i += 1
        typ = (h >> 29) & 0x7
        if typ == 2:
            return i
        op = (h >> 27) & 0x3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF
        if op == 1:
            i += 1
            continue
        if addr == 0x02:            # FDRI
            return i + 1 if cnt == 0 else i
        if op == 2:
            i += cnt
    raise SystemExit("未找到 FDRI")


class Model:
    """定律（mux 区）+ 表（其他族）+ tile 地址。"""

    def __init__(self, law_db, law_json, ecc_json, model_db=None):
        import sqlite3
        self.con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
        self.con.row_factory = sqlite3.Row
        self.law = json.load(open(law_json, encoding="utf-8"))["families"]
        self.ecc = {int(k): v for k, v in
                    json.load(open(ecc_json, encoding="utf-8"))["positions"].items()}
        self.bbr = json.loads(self.con.execute(
            "select value from meta where key='band_by_region'").fetchone()[0])
        self.bands = {}
        for band, col, s in self.con.execute("select band,col,start_frame from far_bands"):
            self.bands.setdefault(band, {})[col] = s
        self.tiles = {}
        for name, ttype, col, y in self.con.execute(
                "select tile_name,tile_type,col,y from law_tiles"):
            self.tiles[name] = (ttype, col, y)
        self._site_cache = {}
        self.mcon = sqlite3.connect("file:%s?mode=ro" % (model_db or law_db), uri=True)
        try:
            self.mcon.execute("select 1 from site_frames limit 1")
        except Exception:
            self.mcon = self.con
        self.cells = {}
        for fam, src, tt, fo, bit, par in self.con.execute(
                "select family,src_wire,tile_type,frame_off,bit,parity from law_cells "
                "where sense=1"):
            self.cells.setdefault((tt, fam, src), []).append((fo, bit, par))

    def tile_base(self, tile):
        if tile not in self.tiles:
            return None
        ttype, col, y = self.tiles[tile]
        band = self.bbr[min(y // 50, len(self.bbr) - 1)]
        base = self.bands.get(band, {}).get(col)
        return None if base is None else (ttype, base, y)

    @staticmethod
    def word_of(y, parity):
        w = 2 * (y % 50) + parity
        return w + 1 if w >= 50 else w

    def cells_of(self, ttype, family, src):
        """→ [(frame_off, bit, parity)]，未知道 None。"""
        if family.startswith(MUX_PREFIX):
            f = self.law.get(family)
            if not f:
                return None
            sl = f["slots"].get(src)
            if not sl:
                return None
            r, code = sl
            pair, par, primary = f["pair"], f["parity"], f["primary"]
            pbit = pair if primary == "P" else pair + 1
            sbit = pair + 1 if primary == "P" else pair
            cells = {(16 + r, pbit if r in (0, 1, 4, 5) else sbit, par)}
            for i, fr in enumerate((25, 24, 23, 22)):
                if code >> i & 1:
                    cells.add((fr, pbit, par))
            return sorted(cells)
        return self.cells.get((ttype, family, src))

    def site_all(self, site, bel):
        """一次取该 site/bel 的全部 (feature → [(frame,word,bit)])。"""
        key = (site, bel)
        if key in self._site_cache:
            return self._site_cache[key]
        rows = self.mcon.execute(
            "select feature, frame, word, bit from site_frames where site=? and bel=?",
            (site, bel)).fetchall()
        d = {}
        for feat, f, w, b in rows:
            d.setdefault(str(feat), []).append((int(f), int(w), int(b)))
        self._site_cache[key] = d
        return d

    def site_bits(self, site, bel, feature):
        """→ [(frame, word, bit)]，来自 site_frames。"""
        return self.site_all(site, bel).get(feature, [])

    def site_features(self, site, bel):
        return sorted(self.site_all(site, bel))

    def all_sources(self, ttype, family):
        if family.startswith(MUX_PREFIX):
            f = self.law.get(family)
            return list(f["slots"]) if f else []
        return [k[2] for k in self.cells if k[0] == ttype and k[1] == family]


def parse_fasm(path):
    """返回 [(kind, a, b, c, value)]；kind='int' 或 'clb'。"""
    out = []
    for line in open(path, encoding="utf-8-sig"):
        line = line.split("#")[0].strip()
        if not line:
            continue
        if line.startswith("BUFGCTRL_X0Y") and line.endswith(("=I0", "=I1")):
            site, val = line.split("=", 1)
            out.append(("bufg", site.split(".")[0], "SEL", None, val))
            continue
        val = 1
        if "=" in line:
            line, vs = line.split("=", 1)
            vs = vs.strip()
            val = int(vs, 0) if not vs.lower().startswith("0x") else int(vs, 16)
        parts = line.split(".")
        if len(parts) == 2:
            # site.bel 的整组特征（如 INIT=0x...）
            out.append(("clb", parts[0], parts[1], None, val))
        elif len(parts) == 3:
            name = parts[0]
            if name.startswith(("SLICE_", "CLBL", "IOB", "RAMS", "DSP")):
                out.append(("clb", name, parts[1], parts[2], val))
            else:
                out.append(("int", name, parts[1], parts[2], 1))
        else:
            raise SystemExit("无法解析的 FASM 行: %s" % line)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="src", required=True)
    ap.add_argument("--out", dest="dst")
    ap.add_argument("--fasm")
    ap.add_argument("--blank", action="store_true", help="先把整个 payload 清零")
    ap.add_argument("--ignore-ecc-coverage", action="store_true",
                    help="ECC 未覆盖的位置不报错（只用于数据字保真度测量，产物不可加载）")
    ap.add_argument("--decode", action="store_true")
    ap.add_argument("--tiles", default=None,
                    help="只解码这些 tile（逗号分隔或文件路径，一行一个）")
    ap.add_argument("--law-db", default=r"E:\v7work\model\v7_law.sqlite")
    ap.add_argument("--model-db", default=r"E:\v7work\model\v7_model.sqlite")
    ap.add_argument("--law-json", default=os.path.join(ROOT, "steps", "pip_reuse_law.json"))
    ap.add_argument("--ecc-json", default=os.path.join(ROOT, "steps", "ecc_model.json"))
    a = ap.parse_args()

    model = Model(a.law_db, a.law_json, a.ecc_json, a.model_db)
    data, sp, words = load_words(a.src)
    poff = payload_offset(words)
    nframes = len(parse_bit(a.src).payload_words) // FRAME_WORDS

    def widx(f, w):
        return poff + f * FRAME_WORDS + w

    if a.decode:
        # 反向：位流 → FASM（只解 mux 区与表内族，按格数>=4 判唯一）
        pos_bits = {}
        for f in range(nframes):
            for w in range(FRAME_WORDS):
                if w == ECC_WORD:
                    continue
                v = words[widx(f, w)]
                while v:
                    b = (v & -v).bit_length() - 1
                    pos_bits[(f, w, b)] = 1
                    v &= v - 1
        # 只对「帧内有置位」的 tile 做判定：空 tile 直接跳过（62k tile 里绝大多数是空的）
        frames_with_bits = {}
        for (f, w, b) in pos_bits:
            frames_with_bits[f] = frames_with_bits.get(f, 0) + 1
        only = None
        if a.tiles:
            if os.path.exists(a.tiles):
                only = {x.strip() for x in open(a.tiles, encoding="utf-8") if x.strip()}
            else:
                only = {x.strip() for x in a.tiles.split(",") if x.strip()}
        # 预计算：tile_type → family → {src: frozenset(cells)} 与位域并集
        fam_pats, fam_domain = {}, {}
        for tt in ("INT_L", "INT_R"):
            fams_tt = {k[1] for k in model.cells if k[0] == tt}
            if tt == "INT_L":
                fams_tt |= set(model.law)
            fam_pats[tt], fam_domain[tt] = {}, {}
            for fam in fams_tt:
                d, dom = {}, set()
                for src in model.all_sources(tt, fam):
                    cells = model.cells_of(tt, fam, src)
                    if not cells:
                        continue
                    d[src] = frozenset(cells)
                    dom |= d[src]
                if d:
                    fam_pats[tt][fam] = d
                    fam_domain[tt][fam] = dom
        lines = []
        gclk = []
        for tile in sorted(model.tiles):
            if only is not None and tile not in only:
                continue
            base = model.tile_base(tile)
            if not base:
                continue
            ttype, b0, y = base
            if not any(frames_with_bits.get(b0 + fo, 0) for fo in range(26)):
                continue
            for fam, pats in fam_pats.get(ttype, {}).items():
                domain = fam_domain[ttype][fam]
                obs = frozenset(c for c in domain
                                if (b0 + c[0], model.word_of(y, c[2]), c[1]) in pos_bits)
                if not obs:
                    continue
                for s in [k for k, v in pats.items() if v == obs]:
                    lines.append("%s.%s.%s" % (tile, fam, s))
                    if fam.startswith("CLK_L") and s.startswith("GCLK_L_B"):
                        gclk.append((tile, s))
        # CLB：从 site_frames 读 INIT（行格式 `SITE.BEL=0x...`），只输出非零值
        cur = model.mcon.execute(
            "select site, bel, feature, frame, word, bit from site_frames "
            "where feature like 'INIT[%%' order by site, bel, feature")
        cur_site = cur_bel = None
        acc = 0
        seen = 0
        n_site = 0
        last = [None, None]

        def flush():
            nonlocal n_site
            if last[0] is None or seen == 0 or acc == 0:
                return
            lines.append("%s.%s=0x%016x" % (last[0], last[1], acc))
            n_site += 1

        for site, bel, feature, f, w, b in cur:
            if (site, bel) != (cur_site, cur_bel):
                flush()
                cur_site, cur_bel = site, bel
                acc = 0
                seen = 0
                last = [site, bel]
            try:
                idx = int(feature[5:7])
            except ValueError:
                continue
            if not (0 <= idx < 64):
                continue
            if (f, w, b) in pos_bits:
                acc |= (1 << idx)
            seen += 1
        flush()

        # GCLK 直通：使能位 (frame_off=0, parity=1, bit=16) + CLK_L* 选中源 → 真实 PIP
        # BUFGCTRL select (T43 measured formula)
        for _Y in range(clk_mux_bits.SITES):
            _a, _b = clk_mux_bits.bits_of(_Y)
            _va = 1 if _a in pos_bits else 0
            _vb = 1 if _b in pos_bits else 0
            if _va and not _vb:
                lines.append("BUFGCTRL_X0Y%d.SEL=I1" % _Y)
            elif _vb and not _va:
                lines.append("BUFGCTRL_X0Y%d.SEL=I0" % _Y)

        for tile, s_ in gclk:
            base = model.tile_base(tile)
            if not base:
                continue
            _tt, b0, y = base
            if (b0, model.word_of(y, 1), 16) not in pos_bits:
                continue
            line = s_.rsplit("_", 1)[0]
            lines.append("%s.%s.%s" % (tile, s_, line))
        txt = "\n".join(lines)
        if a.dst:
            open(a.dst, "w", encoding="utf-8").write(txt + "\n")
            print("解出 %d 行（INT/GCLK %d，CLB %d）→ %s"
                  % (len(lines), len(lines) - n_site, n_site, a.dst))
        else:
            print(txt)
        return

    if not a.fasm:
        raise SystemExit("需要 --fasm 或 --decode")
    if a.blank:
        for f in range(nframes):
            for w in range(FRAME_WORDS):
                words[widx(f, w)] = 0

    before = list(words)
    feats = parse_fasm(a.fasm)
    by_family = {}
    clb_feats = []
    bufg_feats = []
    for kind, x, y, z, v in feats:
        if kind == "int":
            by_family.setdefault((x, y), []).append(z)
        elif kind == "bufg":
            bufg_feats.append((x, v))
        else:
            clb_feats.append((x, y, z, v))

    touched = {}
    unknown = []
    for (tile, family), srcs in by_family.items():
        base = model.tile_base(tile)
        if not base:
            unknown.append((tile, family, "tile 无地址"))
            continue
        ttype, b0, y = base
        # 互斥：先清掉该 family 全部候选源
        for s in model.all_sources(ttype, family):
            cells = model.cells_of(ttype, family, s)
            if not cells:
                continue
            for fo, bit, par in cells:
                words[widx(b0 + fo, model.word_of(y, par))] &= ~(1 << bit)
        for s in srcs:
            if family.startswith("GCLK_L_B") and s == family.rsplit("_", 1)[0]:
                wi = widx(b0, model.word_of(y, 1))
                words[wi] |= (1 << 16)
                touched.setdefault(b0, set()).add(model.word_of(y, 1) * NEXC + 16)
                continue
            cells = model.cells_of(ttype, family, s)
            if not cells:
                unknown.append((tile, family, s))
                continue
            for fo, bit, par in cells:
                wi = widx(b0 + fo, model.word_of(y, par))
                words[wi] |= (1 << bit)
                touched.setdefault(b0 + fo, set()).add(
                    (model.word_of(y, par) * NEXC + bit))

    # BUFGCTRL select (T43 formula)
    for site, sel in bufg_feats:
        Y = int(site.split("_X0Y", 1)[1])
        for (f_, w_, b_, want) in clk_mux_bits.encode(None, Y, sel):
            wi = widx(f_, w_)
            if want:
                words[wi] |= (1 << b_)
            else:
                words[wi] &= ~(1 << b_)
            touched.setdefault(f_, set()).add(w_ * NEXC + b_)

    # CLB：site.bel.feature
    for site, bel, feature, val in clb_feats:
        if feature is None or feature == "INIT":
            if not any(f.startswith("INIT") for f in model.site_features(site, bel)):
                unknown.append((site, bel, "-", "该 bel 无 INIT 特征"))
                continue
            allbits = model.site_all(site, bel)
            for i in range(64):
                for (f, w, b) in allbits.get("INIT[%02d]" % i, []):
                    wi = widx(f, w)
                    if (val >> i) & 1:
                        words[wi] |= (1 << b)
                    else:
                        words[wi] &= ~(1 << b)
        else:
            bits = model.site_bits(site, bel, feature)
            if not bits:
                unknown.append((site, bel, feature, "site_frames 无此特征"))
                continue
            for (f, w, b) in bits:
                wi = widx(f, w)
                if val:
                    words[wi] |= (1 << b)
                else:
                    words[wi] &= ~(1 << b)

    if unknown:
        print("未知特征 %d 条（跳过）：%s" % (len(unknown), unknown[:5]))

    # ECC：按「实际发生变化的位」做增量（安全，且与 bitgen 同口径）
    per_frame = {}
    for f in range(nframes):
        for w in range(FRAME_WORDS):
            if w == ECC_WORD:
                continue
            x = words[widx(f, w)] ^ before[widx(f, w)]
            while x:
                b = (x & -x).bit_length() - 1
                x &= x & (x - 1)
                per_frame.setdefault(f, set()).add(w * NEXC + b)
    skipped = 0
    for f, positions in sorted(per_frame.items()):
        miss = [p for p in positions if p not in model.ecc]
        if miss:
            if a.ignore_ecc_coverage:
                skipped += 1
                continue
            raise SystemExit("帧 %d 有未覆盖位置 %s，拒绝写入" % (f, miss))
        delta = 0
        for p in positions:
            delta ^= model.ecc[p]
        wi = widx(f, ECC_WORD)
        words[wi] = (words[wi] & ~0x1FFF) | ((words[wi] & 0x1FFF) ^ delta)

    out = bytearray(data)
    out[sp + 4:sp + 4 + 4 * len(words)] = struct.pack(">%dI" % len(words), *words)
    open(a.dst, "wb").write(bytes(out))
    print("写出 %s：特征 %d 条，涉及 tile %d 个，改动帧 %d 个，ECC 跳过帧 %d"
          % (a.dst, len(feats), len(by_family), len(per_frame), skipped))


if __name__ == "__main__":
    main()
