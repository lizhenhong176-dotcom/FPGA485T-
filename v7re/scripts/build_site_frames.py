#!/usr/bin/env python3
"""build_site_frames.py —— Phase B 第一步：把 CLB site 绑定到具体 frame/word/bit。

数据源（全部只读）：
  v7_law.sqlite  clb_tiles(slice→tile_type, grid_col, inst, y)
                 clb_blocks(grid_col, band → base_frame)
                 clb_cells(tile_type, family, src_wire, frame_off, bit, sense, parity)
目标库：
  v7_model.sqlite  site_addr(device, site, tile_type, grid_col, inst, y, base_frame, word0, source)
                   site_frames(device, site, bel, feature, frame, word, bit, source)

地址公式（step03_pip/S2_S3_SITE_LAYOUT.md 勘误版 + S5/S11 实测）：
  band   = y // 50
  base   = clb_blocks[(grid_col, band)]
  frame  = base + frame_off
  word   = 2*(y % 50) + (1 if y % 50 >= 25 else 0) + parity
  bit    = law.bit                     (CLB 的 bit 恒在 0..31，不需要 bit//32 => word+1)
  inst   = slice 名 X 的奇偶（偶→X0，奇→X1）；family 前缀 SLICEL_X<i> / SLICEM_X<i> 必须与之一致

用法：
  python build_site_frames.py --site-addr                 # 只建 site_addr（75,900 行）
  python build_site_frames.py --site-frames --columns 19  # 指定列做 site_frames
  python build_site_frames.py --site-frames --limit 500   # 前 500 个 slice
  python build_site_frames.py --site-frames --all         # 全量（约 3,715 万行 / ~2 GB）
  python build_site_frames.py --validate                  # 只跑校验，不写库
"""
import argparse
import json
import os
import sqlite3
import sys
import time

DEVICE = "xc7vx485t"
DEFAULT_LAW = r"E:\v7work\model\v7_law.sqlite"
DEFAULT_MODEL = r"E:\v7work\model\v7_model.sqlite"
SOURCE = "law:clb_cells+clb_blocks@2026-11-02"

# 锁定引脚后的 INIT 索引映射（T19 实测 -> T21 bel 规则 -> T22 行界定位）。
# law 库里的 INIT[00..63] 索引顺序来自 T13（未加 LOCK_PINS），T18 证明 64/64 索引被
# I0..I5 置换污染；T19 逐位实测后集合级自证 missing=0 且 extra=0。
# 关键事实：law 的 (frame_off, bit) 位池集合是对的（64 个 (off,bit) 对与 T19 完全相同），
# 错的只是「索引 -> 位池元素」的对应关系；因此本覆盖只改索引顺序，不改位池规模。
# inst0 组 frame_off 32..35、inst1 组 26..29（law 自带，按 bel 的 INIT 行取 min 得到）。
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT_LOCKED_INIT = os.path.join(REPO_ROOT, "v7re", "steps", "clb_init_locked_map.json")
SOURCE_LOCKED = SOURCE + "+locked:T19"
# law 的 bel 名 -> T21 实测的 LUT 名（bel 规则：A/B 同 word0，C/D 同 word0+1；
# B/D 的位在 16..31）。
LUT_BEL = {"ALUT": "A6LUT", "BLUT": "B6LUT", "CLUT": "C6LUT", "DLUT": "D6LUT"}

# V7 实测「该特征不占用任何配置位」的覆盖表（键 = tile_type, bel, feature）。
# 出处：v7_law.v7_verified 里 bit 为 NULL 的行及其 note。
#   ('CLBLM_R','AOUTMUX','A5Q')
#     note: "e_both: LUT O6->o1 + FDRE Q->o2 same slice routes OK, AOUTMUX unchanged=
#            all-zero; FF.Q exit needs no CLB bit (artix7 bit7 not seen on V7);
#            decode: AOUTMUX=null + FF present + Q used -> A5Q, else O6"
#   即 artix7 定律里 AOUTMUX.A5Q 的 (30,7) 位在 V7 上不存在，生成时必须剔除，
#   否则 site_frames 会多出 75,800 行假条目。
#   该 note 的措辞是全局性的（"FF.Q exit needs no CLB bit (artix7 bit7 not seen on
#   V7)"），且实测点覆盖 SLICEM_X0（D 片）。先按全局剔除处理，tile_type 用 '*' 通配；
#   待第二个独立 tile_type（CLBLL_L / CLBLM_L）上重复同一实验后再收紧。
V7_EMPTY_OVERRIDES = {("*", "AOUTMUX", "A5Q")}

SITE_ADDR_DDL = """
CREATE TABLE IF NOT EXISTS site_addr (
    device      TEXT NOT NULL,
    site        TEXT NOT NULL,
    tile_type   TEXT NOT NULL,
    grid_col    INTEGER NOT NULL,
    inst        INTEGER NOT NULL,
    y           INTEGER NOT NULL,
    band        INTEGER NOT NULL,
    base_frame  INTEGER NOT NULL,
    word0       INTEGER NOT NULL,
    source      TEXT NOT NULL,
    PRIMARY KEY (device, site)
)
"""


def word_of(y):
    """site 在块内的基准 word（parity=0）。"""
    m = y % 50
    return 2 * m + (1 if m >= 25 else 0)


def load_locked_init(path=DEFAULT_LOCKED_INIT, enabled=True):
    """实测 INIT 索引表：{slice 种类: {索引: (rel_off, bit_in_16)}} + bel 规则。

    T19 证明 SLICEM 与 SLICEL 两套顺序不同（相差一个仿射输入置换，见 map 的
    permutation 字段），因此按 slice 种类分别给出，构建时按 family 前缀选表。
    """
    if not enabled or not os.path.exists(path):
        return None
    m = json.load(open(path, encoding="utf-8"))
    orders = {}
    for kind, tbl in m["orders"].items():
        order = {int(k): (v[0], v[1]) for k, v in tbl.items()}
        if sorted(order) != list(range(64)):
            raise SystemExit("INIT 索引表 %s 不是 0..63 全覆盖：%s" % (kind, path))
        if len({tuple(v) for v in order.values()}) != 64:
            raise SystemExit("INIT 索引表 %s 的 (rel_off, bit) 不是 64 个互异元素" % kind)
        orders[kind] = order
    if set(orders) != {"SLICEM", "SLICEL"}:
        raise SystemExit("INIT 索引表缺少 SLICEM/SLICEL 之一：%s" % sorted(orders))
    return {"orders": orders, "bel_rule": m["bel_rule"],
            "measurements": m.get("measurements", {}), "path": path}


def lut_init_group_base(law, bel):
    """law 里该 bel 的 INIT 行占据的最小 frame_off（inst0=32 / inst1=26）。"""
    offs = [off for (b_, src, off, bit, sense, parity) in law
            if b_ == bel and src.startswith("INIT")]
    return min(offs) if offs else None


class Cells(dict):
    """cells[(tile_type, inst)] -> [(bel, src, off, bit, sense, parity)]；kinds 另存切片种类。"""
    kinds = None


def load_law(law_db):
    con = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    tiles = con.execute(
        "SELECT slice_name, tile_type, grid_col, inst, y FROM clb_tiles").fetchall()
    blocks = {(gc, band): base for gc, band, base in
              con.execute("SELECT grid_col, band, base_frame FROM clb_blocks")}
    cells = Cells()
    cells.kinds = {}
    for tt, fam, src, off, bit, sense, parity in con.execute(
            "SELECT tile_type, family, src_wire, frame_off, bit, sense, parity FROM clb_cells"):
        pfx, bel = fam.split(".", 1)
        # pfx = 'SLICEL_X0' / 'SLICEM_X1'
        kind, xs = pfx.rsplit("_X", 1)
        inst = int(xs)
        prev = cells.kinds.get((tt, inst))
        if prev is not None and prev != kind:
            raise SystemExit("law 里 (%s,%d) 同时出现 %s 与 %s 两种切片：无法按种类选 INIT 表"
                             % (tt, inst, prev, kind))
        cells.kinds[(tt, inst)] = kind
        cells.setdefault((tt, inst), []).append((bel, src, off, bit, sense, parity))
    con.close()
    return tiles, blocks, cells


def build_site_addr(tiles, blocks, device=DEVICE):
    rows, missing = [], []
    for name, tt, gc, inst, y in tiles:
        band = y // 50
        base = blocks.get((gc, band))
        if base is None:
            missing.append((name, tt, gc, inst, y, band))
            continue
        rows.append((device, name, tt, gc, inst, y, band, base, word_of(y), SOURCE))
    return rows, missing


def emit_site_frames(addr_rows, cells, device=DEVICE, sel=None, locked=None):
    out = []
    skipped_type = {}
    n_locked = 0
    group_base = {}
    for (dev, site, tt, gc, inst, y, band, base, w0, src) in addr_rows:
        if sel is not None and site not in sel:
            continue
        law = cells.get((tt, inst))
        if law is None:
            skipped_type[(tt, inst)] = skipped_type.get((tt, inst), 0) + 1
            continue
        if locked is not None:
            for bel in LUT_BEL:
                key = (tt, inst, bel)
                if key not in group_base:
                    gb = lut_init_group_base(law, bel)
                    if gb is not None:
                        group_base[key] = gb
        for bel, feature, off, bit, sense, parity in law:
            if ((tt, bel, feature) in V7_EMPTY_OVERRIDES
                    or ("*", bel, feature) in V7_EMPTY_OVERRIDES):
                # V7 实测该特征不占用任何配置位（见 V7_EMPTY_OVERRIDES 的出处），
                # 定律表里遗留的 artix7 位不得写入 site_frames
                continue
            src_tag = SOURCE
            if locked is not None and bel in LUT_BEL and feature.startswith("INIT["):
                # 实测 INIT 索引表（T19 测 SLICEM、T23 测 SLICEL，两套顺序不同）：
                # 只覆盖「索引 -> 位池元素」的对应关系，位池规模与 bel 规则不变
                # （T21：A/B 同 word0，C/D word0+1；B/D 位在 16..31）。
                kind = cells.kinds[(tt, inst)]
                idx = int(feature[5:-1])
                rel, bit_in16 = locked["orders"][kind][idx]
                word_plus, bit_plus = locked["bel_rule"][LUT_BEL[bel]]
                if word_plus != parity or bit_plus + bit_in16 > 31:
                    raise SystemExit("bel 规则与 law 冲突：%s/%s word_plus=%d parity=%d"
                                     % (bel, feature, word_plus, parity))
                gb = group_base.get((tt, inst, bel))
                if gb is None:
                    raise SystemExit("law 里 %s/%s 没有 INIT 行，无法定位 inst%d 组基址"
                                     % (tt, bel, inst))
                off = gb + rel
                bit = bit_plus + bit_in16
                src_tag = SOURCE_LOCKED
                n_locked += 1
            frame = base + off
            if frame < 0 or frame > 50175:
                continue
            out.append((dev, site, bel, feature, frame,
                        w0 + parity, bit, src_tag))
    if locked is not None:
        skipped_type.setdefault("_locked_init_rows", n_locked)
    return out, skipped_type


def write_site_addr(model_db, rows):
    con = sqlite3.connect(model_db)
    con.isolation_level = None          # 自己管事务，避免隐式 BEGIN 与显式 BEGIN 打架
    try:
        con.execute(SITE_ADDR_DDL)
        con.execute("BEGIN")
        con.executemany(
            "INSERT OR REPLACE INTO site_addr VALUES (?,?,?,?,?,?,?,?,?,?)", rows)
        con.commit()
    finally:
        con.close()


def write_site_frames(model_db, rows, replace=False):
    con = sqlite3.connect(model_db)
    con.isolation_level = None          # 同上：DELETE 后紧跟显式 BEGIN 必须在自动提交模式下
    try:
        if replace:
            con.execute("DELETE FROM site_frames")
        con.execute("BEGIN")
        con.executemany(
            "INSERT OR REPLACE INTO site_frames VALUES (?,?,?,?,?,?,?,?)",
            [(d, s, b, f, fr, w, bi, src) for (d, s, b, f, fr, w, bi, src) in rows])
        con.commit()
    finally:
        con.close()


def validate_locked_init(addr_rows, cells, locked):
    """第 4 条：实测 INIT 索引表自检（两条独立实测锚点 + law 一致性）。

    a) SLICE_X12Y20（SLICEM 切片）逐索引：生成的 64 个 (frame, word, bit) 必须与 T19
       单最小项实测表完全一致。
    b) SLICE_X11Y20（SLICEL 切片）集合级：INIT=0xDEADBEEFCAFEBABE 时生成的 46 个置位点
       必须与 T23 实测差分集完全一致（这一条正是区分 SLICEM/SLICEL 两套顺序的判据）。
    c) law 里每个 (tile_type, inst) 的 INIT 索引顺序必须与对应种类的实测表一致——
       防止 law 被悄悄改成第三套顺序。
    """
    if locked is None:
        print("  SKIP  INIT 索引表自检：未加载（--no-locked-init）")
        return True
    good = True

    # c) law 与实测表逐种类一致（全库）
    for (tt, inst), rows_law in sorted(cells.items()):
        kind = cells.kinds[(tt, inst)]
        want = locked["orders"][kind]
        for bel in LUT_BEL:
            got = {int(src[5:-1]): (off, bit) for (b_, src, off, bit, sense, parity)
                   in rows_law if b_ == bel and src.startswith("INIT[")}
            if not got:
                continue
            base = min(o for o, _ in got.values())
            bit_plus = locked["bel_rule"][LUT_BEL[bel]][1]
            norm = {i: (o - base, b - bit_plus) for i, (o, b) in got.items()}
            if norm != want:
                bad = [i for i in range(64) if norm.get(i) != want[i]]
                print("  FAIL  law INIT 顺序与实测表不符：%s inst%d %s 差异 %d/64（样例 %s）"
                      % (tt, inst, bel, len(bad), bad[:4]))
                good = False
    if good:
        print("  PASS  law INIT 索引顺序与实测表一致：SLICEM %d 个 / SLICEL %d 个 (tile_type,inst) 全等"
              % (sum(1 for k in cells.kinds if cells.kinds[k] == "SLICEM"),
                 sum(1 for k in cells.kinds if cells.kinds[k] == "SLICEL")))

    # a) T19 绝对映射（SLICEM，X12Y20）
    t19_path = os.path.join(REPO_ROOT, "v7re", "steps", "clb_init_locked_x12y20_a6lut.json")
    anchor = next((r for r in addr_rows if r[1] == "SLICE_X12Y20"), None)
    if not os.path.exists(t19_path) or anchor is None:
        print("  FAIL  T19 锚点缺失：表=%s 锚点=%s" % (os.path.exists(t19_path), anchor is not None))
        return False
    t19 = json.load(open(t19_path, encoding="utf-8"))
    base = anchor[7]
    rows, _ = emit_site_frames([anchor], cells, locked=locked)
    got_a = {int(feat[5:-1]): (fr, w, bi) for (d, s, bel, feat, fr, w, bi, src) in rows
             if bel == "ALUT" and feat.startswith("INIT[")}
    bad = [(i, tuple(int(x) for x in t19[str(i)]), got_a.get(i))
           for i in range(64)
           if got_a.get(i) != tuple(int(x) for x in t19[str(i)])]
    frames_ok = all(sorted({r[4] for r in rows if r[2] == bel and r[3].startswith("INIT[")})
                    == [base + 32, base + 33, base + 34, base + 35] for bel in LUT_BEL)
    print("  %s  T19 锚点 SLICE_X12Y20（SLICEM）：64 索引对账不符 %d，四 bel 帧组 base+32..35 %s"
          % ("PASS" if not bad and frames_ok else "FAIL", len(bad),
             "是" if frames_ok else "否"))
    if bad[:4]:
        print("    不符样例（索引, T19, 生成）：", bad[:4])
    good &= (not bad) and frames_ok

    # b) T23 集合级（SLICEL，X11Y20）
    t23_path = os.path.join(REPO_ROOT, "step03_pip", "t23_diff_raw.json")
    anchor_b = next((r for r in addr_rows if r[1] == "SLICE_X11Y20"), None)
    if not os.path.exists(t23_path) or anchor_b is None:
        print("  FAIL  T23 锚点缺失：表=%s 锚点=%s"
              % (os.path.exists(t23_path), anchor_b is not None))
        return False
    t23 = json.load(open(t23_path, encoding="utf-8"))[0]
    obs = {(int(f), int(w), bi) for f, per in t23["frames"].items()
           for w, bits in per.items() if int(w) == 40 for bi in bits}
    v_hex = "0xDEADBEEFCAFEBABE"
    rows_b, _ = emit_site_frames([anchor_b], cells, locked=locked)
    pred = {(fr, w, bi) for (d, s, bel, feat, fr, w, bi, src) in rows_b
            if bel == "ALUT" and feat.startswith("INIT[")
            and (int(v_hex, 16) >> int(feat[5:-1])) & 1}
    ok_b = pred == obs
    print("  %s  T23 锚点 SLICE_X11Y20（SLICEL）：INIT=%s 置位点 生成 %d / 实测 %d，全等 %s"
          % ("PASS" if ok_b else "FAIL", v_hex, len(pred), len(obs), "是" if ok_b else "否"))
    if not ok_b:
        print("    missing", sorted(pred - obs)[:5], "extra", sorted(obs - pred)[:5])
    good &= ok_b
    return bool(good)


def validate(law_db, model_db, addr_rows, cells, locked=None):
    """四条互相独立的校验，任何一条挂掉就说明公式或数据有问题。"""
    ok = True

    # 1) 结构：每个 slice 都能落到 block，frame 不越界
    if not addr_rows:
        print("  FAIL  site_addr 为空")
        return False
    bad = [r for r in addr_rows if r[7] is None]
    print("  %s  结构：%d 个 slice 有地址，无 block 的 %d 个"
          % ("PASS" if not bad else "FAIL", len(addr_rows), len(bad)))
    ok &= not bad

    # 2) 锚点：SLICE_X10Y20 的 INIT 必须落在 frame 31750/31751、word 40
    anchor = next((r for r in addr_rows if r[1] == "SLICE_X10Y20"), None)
    if anchor:
        base, w0 = anchor[7], anchor[8]
        # ALUT 的 64 个 INIT 位横跨 4 帧（off 32..35），其中 off34/35 = INIT[00..07]/
        # [16..23]/[32..39]/[48..55]（S5 实测：INIT 数据帧 31750/31751）；off32/33 是
        # 同一 4 帧组的另一半（INIT[08..15] 等）。因此整组应为 base+32 .. base+35。
        init_frames = sorted({base + off for (bel, src, off, bit, sense, parity) in
                              cells[("CLBLM_R", 0)] if bel == "ALUT" and src.startswith("INIT")})
        good = (base == 31716 and w0 == 40
                and init_frames == [31748, 31749, 31750, 31751])
        print("  %s  锚点 SLICE_X10Y20：base=%d word0=%d INIT 4 帧组=%s"
              "（期望 31716/40/[31748..31751]）"
              % ("PASS" if good else "FAIL", base, w0, init_frames))
        ok &= good
    else:
        print("  FAIL  锚点 SLICE_X10Y20 不在 site_addr 里")
        ok = False

    # 3) 与 v7_verified 的 98 条实测对账：同 (tile_type,family,src,frame_off,bit) 必须存在，
    #    且 word 必须等于某个合法 y 的 word_of(y)+parity
    lc = sqlite3.connect("file:%s?mode=ro" % law_db, uri=True)
    verified = lc.execute(
        "SELECT tile_type, family, src_wire, frame_off, word, bit FROM v7_verified").fetchall()
    lc.close()
    law_set = {}
    law_bels = {}
    for (tt, inst), rows in cells.items():
        for (bel, src, off, bit, sense, parity) in rows:
            law_set[(tt, inst, bel, src, off, bit)] = parity
            law_bels.setdefault((tt, inst), set()).add(bel)
    # 帧 = 101 word（实测 a.bit：len(frame)=101）。50 行 slice × 2 word + 1 备用
    # = 101，所以 word 0..100 都合法；r>=25 的行整体 +1 后 r=49 的第二字正好落到
    # word 100。注意 word 51..100（r>=25 的下半区）目前**没有实测依据**，
    # 只有公式外推，见 steps/SITE_FRAMES_STATUS.md 的开放项。
    legal_words = set(range(0, 101))
    hit = miss = word_bad = skipped = empty_ok = empty_bad = deviation = 0
    missing_examples = []
    for tt, fam, src, off, word, bit in verified:
        pfx = fam.split(".", 1)[0]
        # v7_verified 里混有 S14/S15 阶段直接写入的行（前缀 'S14'/'S15'/''），
        # 以及只有前缀没有 bel 的行，它们不是定律条目
        if not pfx.startswith(("SLICEL_X", "SLICEM_X")) or fam.count(".") != 1:
            skipped += 1
            continue
        bel = fam.split(".", 1)[1]
        inst = int(pfx.rsplit("_X", 1)[1])
        if bel not in law_bels.get((tt, inst), ()):
            # S14/S15 阶段写入的观察行（如 'A6LUT' + 'INIT_FIELD'/'IMUX_CSP'），
            # 不是定律表的 BEL，不参与对账
            skipped += 1
            continue
        if bit is None:
            # 实测「无编码位」的特征：定律里对应的位集必须全是 sense=0（恒 0 池）；
            # 例外是 V7_EMPTY_OVERRIDES 里登记的、定律仍写着 artix7 位的特征
            senses = [se_ for (b_, s_, o_, bi_, se_, p_) in cells[(tt, inst)]
                      if b_ == bel and s_ == src]
            if ((tt, bel, src) in V7_EMPTY_OVERRIDES
                    or ("*", bel, src) in V7_EMPTY_OVERRIDES):
                deviation += 1
            elif senses and all(s == 0 for s in senses):
                empty_ok += 1
            else:
                empty_bad += 1
                if len(missing_examples) < 8:
                    missing_examples.append(("EMPTY-MISMATCH", tt, fam, src))
            continue
        if src.endswith("*") or src in ("FF",):
            # S5/S6 的注释行（'ZINI*' 已更正为 AFF.ZRST；'FF' 是 FF 类型标记）
            skipped += 1
            continue
        if (tt, inst, bel, src, off, bit) not in law_set:
            miss += 1
            if len(missing_examples) < 8:
                missing_examples.append((tt, fam, src, off, bit))
            continue
        if word not in legal_words:
            word_bad += 1
            continue
        hit += 1
    print("  %s  v7_verified 对账：命中定律 %d，恒 0 池 %d，已登记 V7 偏差 %d，"
          "word 不合法 %d，未找到定律 %d，空池不符 %d，注释/非定律跳过 %d（总计 %d）"
          % ("PASS" if miss == 0 and word_bad == 0 and empty_bad == 0 else "FAIL",
             hit, empty_ok, deviation, word_bad, miss, empty_bad, skipped,
             len(verified)))
    if missing_examples:
        print("    未命中样例：", missing_examples)
    ok &= (miss == 0 and word_bad == 0 and empty_bad == 0)

    # 4) 锁定引脚 INIT 表自检（T19 绝对映射对账 + 位池不变 + 索引置换数）
    ok &= validate_locked_init(addr_rows, cells, locked)
    return bool(ok)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--law-db", default=DEFAULT_LAW)
    ap.add_argument("--model-db", default=DEFAULT_MODEL)
    ap.add_argument("--site-addr", action="store_true", help="建 site_addr")
    ap.add_argument("--site-frames", action="store_true", help="生成 site_frames")
    ap.add_argument("--columns", default="", help="逗号分隔的 grid_col 列表")
    ap.add_argument("--limit", type=int, default=0, help="只处理前 N 个 slice")
    ap.add_argument("--all", action="store_true", help="全量生成")
    ap.add_argument("--validate", action="store_true", help="只校验")
    ap.add_argument("--replace", action="store_true", help="先清空 site_frames")
    ap.add_argument("--dry-run", action="store_true", help="只生成不写库（统计 + 校验用）")
    ap.add_argument("--locked-init", default=DEFAULT_LOCKED_INIT,
                    help="锁定引脚 INIT 映射 JSON（默认 v7re/steps/clb_init_locked_map.json）")
    ap.add_argument("--no-locked-init", action="store_true",
                    help="回退到 law 的 INIT 索引顺序（T13 血统，仅供差分对照）")
    a = ap.parse_args()

    t0 = time.time()
    locked = load_locked_init(a.locked_init, enabled=not a.no_locked_init)
    if locked is None:
        print("WARN  未使用锁定 INIT 映射：INIT 索引沿用 law（T13 血统，不可用于真实设计）")
    tiles, blocks, cells = load_law(a.law_db)
    addr_rows, missing = build_site_addr(tiles, blocks)
    print("law: %d slices, %d blocks, %d cell-rules；site_addr 可建 %d 行，缺 block %d"
          % (len(tiles), len(blocks), sum(len(v) for v in cells.values()),
             len(addr_rows), len(missing)))
    if missing[:3]:
        print("  缺 block 样例：", missing[:3])

    if a.validate:
        ok = validate(a.law_db, a.model_db, addr_rows, cells, locked=locked)
        print("VALIDATE:", "PASS" if ok else "FAIL")
        return 0 if ok else 1

    if a.site_addr:
        write_site_addr(a.model_db, addr_rows)
        print("site_addr 写入 %d 行 (%.1fs)" % (len(addr_rows), time.time() - t0))

    if a.site_frames:
        sel = None
        rows_in = addr_rows
        if a.columns:
            cols = {int(x) for x in a.columns.split(",") if x.strip()}
            rows_in = [r for r in addr_rows if r[3] in cols]
        if a.limit:
            rows_in = rows_in[:a.limit]
        if not a.all:
            sel = {r[1] for r in rows_in}
        sf_rows, skipped = emit_site_frames(addr_rows if not sel else rows_in, cells,
                                            locked=locked)
        n_locked = skipped.pop("_locked_init_rows", 0)
        if skipped:
            print("  跳过的 (tile_type,inst)：", skipped)
        print("site_frames 生成 %d 行（slice %d 个，其中锁定 INIT 行 %d）"
              % (len(sf_rows), len({r[1] for r in sf_rows}), n_locked))
        if a.dry_run:
            print("  只生成不写库（--dry-run）")
            return 0
        write_site_frames(a.model_db, sf_rows, replace=a.replace)
        print("site_frames 写入完成 (%.1fs, 库 %.1f MB)"
              % (time.time() - t0, os.path.getsize(a.model_db) / 1e6))
    return 0


if __name__ == "__main__":
    sys.exit(main())
