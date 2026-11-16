#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""T56 同类 tile 的 PIP 开关盒最小实验：离线核验 + 设计单生成。

本脚本不构建任何 bitstream，只做四件事：
  S0 数据源与结构自检（表在不在、tile 在不在、源集合差集是什么）
  S1 地址律回归（用实测行反推 word/base，含「不加 +1」的反事实）
  S2 T1 模型验证（IMUX_L8 全 25 个源的实测差分 vs law 预测）
  S3 T2 预测（换到另一坐标的同类型 tile）+ 归一化判据
  S4 判据自检（突变测试：判据必须能拒绝 5 类假差分）
  S5 输出机器可读设计单 JSON（供执行方直接照做）

数据源（全部只读）：
  v7_law.sqlite   law_cells / law_tiles / far_bands / clb_blocks / clb_tiles
  v7_model.sqlite pip_bits（source=step03_pip_20261024，24 行删除法实测）
  routing/templates/INT_L.json   pip_defs（字段序 (src,dst,delay,bidir)）
  step03_pip/reuse_bits.json     25 个源在 INT_L_X6Y11 的实测差分

用法：
  python v7re/scripts/t56_pip_switchbox_offline.py [--json out.json]
退出码 0 = 全部自检通过。
"""

from __future__ import annotations

import argparse
import json
import sqlite3
import sys
from pathlib import Path

# ---------------------------------------------------------------- 路径与常量
REPO = Path(__file__).resolve().parents[2]
LAW_DB = Path(r"E:\v7work\model\v7_law.sqlite")
MODEL_DB = Path(r"E:\v7work\model\v7_model.sqlite")
ROUTING = Path(r"E:\v7work\_curated_20261021\routing\out_routing")
TEMPLATE = ROUTING / "templates" / "INT_L.json"
REUSE_BITS = REPO / "step03_pip" / "reuse_bits.json"
RESULTS_MD = REPO / "step03_pip" / "RESULTS.md"

PART_BUILD = "xc7vx485tffg1761-2"   # 与 T1 的 PIP 实验（step03_pip/build_a.tcl:1）同 part
PART_LAW = "xc7vx485tffg1761-2"      # law 库标注 part（同 die 同几何）
# 注意：INIT 实验族（_xcheck.sh:13）用的是 ffg1157-3，本实验不得混用——
# 换 part 会改时序驱动布线（-2/-3 速度等级不同），使「只换 tile」不再成立。
PART_INIT_FAMILY = "xc7vx485tffg1157-3"

COLS = [6, 8]
# y//50 -> far_bands.band（实测映射，见 T53/PIP_ADDRESS_ENCODING_LAW.md）
BAND_OF_REGION = {0: 6, 1: 5, 2: 0, 3: 1, 4: 2, 5: 3, 6: 4}

FAMILY = "IMUX_L8"
SINK = "IMUX_L8"
TILE1 = "INT_L_X6Y11"   # T1（已实测）
TILE2 = "INT_L_X6Y61"   # T2（本设计）
Y1, Y2 = 11, 61
COL = 6

FAILS: list[str] = []


def check(cond: bool, msg: str) -> bool:
    print(("  OK   " if cond else "  FAIL ") + msg)
    if not cond:
        FAILS.append(msg)
    return cond


def band_of(y: int) -> int:
    return BAND_OF_REGION[y // 50]


def y_of(tile: str) -> int:
    return int(tile.rsplit("Y", 1)[1])


def word_of(y: int, parity: int) -> int:
    """word = 2*(y%50) + parity；>=50 再 +1 让开 word 50 的 ECC 字。"""
    w = 2 * (y % 50) + parity
    if w >= 50:
        w += 1
    return w


def word_of_no_shift(y: int, parity: int) -> int:
    """反事实：漏掉 >=50 的 +1 —— 用来证明这一项是必需的。"""
    return 2 * (y % 50) + parity


def frames_of_base(base: int, offs) -> set[int]:
    return {base + o for o in offs}


# ---------------------------------------------------------------- 载入数据
def open_ro(path: Path) -> sqlite3.Connection:
    if not path.exists():
        raise SystemExit(f"数据库不存在: {path}")
    return sqlite3.connect(f"file:{path.as_posix()}?mode=ro&immutable=1", uri=True)


def load_law(con) -> dict[str, dict[tuple[int, int], tuple[int, int]]]:
    """family IMUX_L8: src -> {(off,bit): (parity, sense)}"""
    out: dict[str, dict[tuple[int, int], tuple[int, int]]] = {}
    for src, off, bit, sense, parity in con.execute(
        "select src_wire,frame_off,bit,sense,parity from law_cells "
        "where tile_type='INT_L' and family=? order by 1,2",
        (FAMILY,),
    ):
        out.setdefault(src, {})[(off, bit)] = (parity, sense)
    return out


def load_template_sources() -> set[str]:
    tpl = json.loads(TEMPLATE.read_text(encoding="utf-8"))
    # pip_defs 字段序 (src, dst, delay, bidir) —— 注意不是 (dst, src)
    return {p[0] for p in tpl["pip_defs"] if p[1] == SINK}


# ---------------------------------------------------------------- S0
def s0(con_law, con_model):
    print("\n=== S0 数据源与结构自检 ===")
    n_law = con_law.execute("select count(*) from law_cells").fetchone()[0]
    n_tt = con_law.execute("select count(distinct tile_type) from law_cells").fetchone()[0]
    print(f"  law_cells {n_law} 行 / {n_tt} 个 tile_type")
    check(n_tt == 2, "law 只覆盖 INT_L / INT_R 两个 tile_type")

    law = load_law(con_law)
    print(f"  {FAMILY}: {len(law)} 个源, "
          f"{sorted({(o, b) for v in law.values() for (o, b) in v})}")

    tpl = load_template_sources()
    extra = tpl - set(law)
    miss = set(law) - tpl
    print(f"  模板源 {len(tpl)} / law 源 {len(law)} / 模板多出 {sorted(extra)} / law 多出 {sorted(miss)}")
    check(extra == {"VCC_WIRE"} and not miss,
          "源集合差集恰为常数源 VCC_WIRE（law 不收录常量源）")

    # 每个源 5 格
    check(all(len(v) == 5 for v in law.values()), "每个源恰好 5 个格")
    parities = {p for v in law.values() for (p, _s) in v.values()}
    check(parities == {0}, "IMUX_L8 全族 parity=0（=> word 全为偶数）")

    # tile 存在性
    for t in (TILE1, TILE2):
        row = con_law.execute(
            "select tile_type,col,y,clock_region from law_tiles where tile_name=?", (t,)
        ).fetchone()
        check(row is not None and row[0] == "INT_L", f"{t} 存在且 tile_type=INT_L -> {row}")

    for s in ("SLICE_X8Y10", "SLICE_X8Y11", "SLICE_X8Y60", "SLICE_X8Y61"):
        row = con_law.execute(
            "select tile_type,grid_col,inst,y from clb_tiles where slice_name=?", (s,)
        ).fetchone()
        check(row is not None, f"{s} 存在 -> {row}")

    # base
    bases = {}
    for y in (Y1, Y2):
        b = band_of(y)
        start = con_law.execute(
            "select start_frame from far_bands where band=? and col=?", (b, COL)
        ).fetchone()[0]
        bases[y] = start
        print(f"  y={y}: y//50={y // 50} -> band {b}, far_bands.start={start}")
    check(bases[Y1] == 31680, "T1 base = 31680")
    check(bases[Y2] == 26434, "T2 base = 26434")
    check(bases[Y1] - bases[Y2] == 5246, "Δbase = 5246（同列相邻 band）")

    # clb_blocks 交叉核对：clb_blocks 的 band 顺序与 far_bands 相反
    cb = dict(con_law.execute(
        "select band,base_frame from clb_blocks where grid_col=16"))
    check(cb.get(0) == 31680 and cb.get(1) == 26434,
          "clb_blocks(grid_col=16, band0/1) 与 far_bands 同址互证 -> "
          f"{cb.get(0)}/{cb.get(1)}")

    # 模板 pip 元数据无几何信息（T53 已排除的一条路线，这里留可复核断言）
    tpl_json = json.loads(TEMPLATE.read_text(encoding="utf-8"))
    third = {p[2] for p in tpl_json["pip_defs"]}
    if len(third) == 1:
        print(f"  pip_defs 第 3 字段取值集合 = {third}（无几何/顺序信息，见 T53 §5.2）")

    return law, bases


# ---------------------------------------------------------------- S1
def s1(con_law, con_model, law_beg, bases):
    print("\n=== S1 地址律回归：用实测行反推 word 与 base ===")
    rows = list(con_model.execute(
        "select tile,wire_a,wire_b,frame,word,bit from pip_bits "
        "where source='step03_pip_20261024' order by tile,frame"))
    check(len(rows) == 24, f"pip_bits 实测行 {len(rows)} 条（删除法，NR1BEG0/NR1BEG2）")

    ok = ok_noshift = 0
    bad_noshift = []
    for tile, src, dst, frame, word, bit in rows:
        y = y_of(tile)
        base = bases.get(y)
        if base is None:
            base = con_law.execute(
                "select start_frame from far_bands where band=? and col=?",
                (band_of(y), COL)).fetchone()[0]
        cells = law_beg[dst][src]                     # {(off,bit):(parity,sense)}
        off = frame - base
        cell = cells.get((off, bit))
        if cell is None:
            FAILS.append(f"{tile} {src}->>{dst} 实测位 ({off},{bit}) 不在 law 内")
            print(f"  FAIL {tile} {src}->>{dst} ({off},{bit}) 不在 law")
            continue
        parity, _sense = cell
        w_ok = word_of(y, parity) == word
        w_ns = word_of_no_shift(y, parity) == word
        ok += w_ok
        ok_noshift += w_ns
        if not w_ns:
            bad_noshift.append(f"y={y}")
        print(f"  {tile:14s} {src}->>{dst} frame={frame} off={off:2d} "
              f"parity={parity} word={word:2d} 预测={word_of(y, parity):2d} "
              f"{'OK' if w_ok else 'FAIL'}")
    check(ok == len(rows), f"含 +1 修正的地址律命中 {ok}/{len(rows)}")
    check(ok_noshift < len(rows),
          f"漏掉 +1 的反事实只命中 {ok_noshift}/{len(rows)}"
          f"（y={','.join(bad_noshift)} 全错）—— 证明该项必需")

    # 直接绝对集：T1 的 NR1END0（来自 VCC_WIRE 行，见 S2）
    return rows


# ---------------------------------------------------------------- S2
def s2(law, bases):
    print("\n=== S2 T1 模型验证：IMUX_L8 全 25 个源的实测差分 ===")
    if not REUSE_BITS.exists():
        raise SystemExit(f"缺少实测差分: {REUSE_BITS}")
    data = json.loads(REUSE_BITS.read_text(encoding="utf-8"))
    base = bases[Y1]
    w0 = word_of(Y1, 0)

    def abs1(src: str) -> set[tuple[int, int, int]]:
        """law 预测的绝对 1 位集合 (frame, word, bit)"""
        out = set()
        for (off, bit), (parity, sense) in law[src].items():
            if sense == 1:
                out.add((base + off, word_of(Y1, parity), bit))
        return out

    ref = abs1("NR1END0")
    print(f"  law 预测 abs(NR1END0) = {sorted(ref)}")

    # 两处「结构性常量位」：来自 BEG PIP（LOGIC_OUTS_L12->>NR1BEG0，tile X6Y10）
    const = {(31690, 20, 7), (31693, 20, 7)}
    print(f"  剥离的常量位（来自 BEG PIP，全部 25 个条目共有）= {sorted(const)}")

    passed, details = 0, {}
    for src, rec in sorted(data.items()):
        meas = {(f, w, b) for f, w, b in rec["config"]} - const
        pred = (ref ^ abs1(src)) if src in law else (ref if src == "VCC_WIRE" else None)
        if pred is None:
            details[src] = {"status": "NO_LAW", "ecc_count": rec["ecc_count"]}
            continue
        good = (meas == pred)
        passed += good
        details[src] = {
            "status": "PASS" if good else "FAIL",
            "measured": sorted(meas), "predicted": sorted(pred),
            "missing": sorted(pred - meas), "extra": sorted(meas - pred),
            "ecc_count": rec["ecc_count"],
        }
        if not good:
            print(f"  FAIL {src}: missing={sorted(pred - meas)} extra={sorted(meas - pred)}")

    check(passed == len(data), f"XOR 语义预测命中 {passed}/{len(data)}（含 VCC_WIRE）")
    check(details["VCC_WIRE"]["measured"] == sorted(ref),
          "VCC_WIRE 的实测集 == abs(NR1END0) => VCC_WIRE 编码为全 0（默认/未选态）")

    # ECC 单独计数（口径纪律：word 50 不得混入内容位）
    ecc = {src: d["ecc_count"] for src, d in details.items() if "ecc_count" in d}
    print(f"  ECC(word 50) 变化位数区间 = [{min(ecc.values())}, {max(ecc.values())}]"
          f"，单独计数、不参与内容位比对")

    # 关键结构事实：参考流 b.bit 到底删了哪条 PIP
    allmeas = [{(f, w, b) for f, w, b in rec["config"]} for rec in data.values()]
    common = set.intersection(*allmeas)
    check(common == const,
          "25 个条目共有且仅有 BEG PIP 的 2 位 => 参考流 b.bit 缺的是 BEG PIP")
    check({(f, w, b) for f, w, b in data["NR1END0"]["config"]} == const,
          "NR1END0 条目差分恰为那 2 位 => b.bit 的 IMUX_L8 位与基线完全一致")
    print("  【数据事实】step03_pip/reuse_diff.py:9 的注释写的是「baseline with the IMUX_L8 "
          "PIP removed」，但实测表明 b.bit 里 IMUX_L8 位仍在、缺的是 BEG PIP；"
          "因此 RESULTS.md:110 的所谓「PURE 绝对集」实际是「相对 VCC_WIRE 的 XOR」，"
          "其正确性依赖 VCC_WIRE 编码为全 0 这一条（上面第 2 条 check 正是它的实测证明）。")

    # 与 RESULTS.md:110 的人工结论对齐
    print(f"  RESULTS.md:110 记录的基线绝对集 = "
          f"{{31699:(22,3), 31702:(22,2), 31704:(22,2), 31705:(22,2)}}")
    check(sorted(ref) == [(31699, 22, 3), (31702, 22, 2), (31704, 22, 2), (31705, 22, 2)],
          "law 复算 == RESULTS.md:110 记录值（逐位一致）")

    return details, ref, abs1


# ---------------------------------------------------------------- S3
def s3(law, bases, ref, abs1):
    print("\n=== S3 T2 预测与归一化判据 ===")
    base1, base2 = bases[Y1], bases[Y2]
    delta = base2 - base1
    check(word_of(Y2, 0) == word_of(Y1, 0) == 22,
          f"y={Y1} 与 y={Y2} 的行内偏移相同 => word 基址同为 22")

    def shift(s):
        return {(f + delta, w, b) for f, w, b in s}

    t2_abs = shift(ref)
    t2_vcc = set(t2_abs)
    t2_l12 = shift(ref ^ abs1("LOGIC_OUTS_L12"))
    print(f"  Δ = {delta}")
    print(f"  预测 abs(NR1END0)@T2      = {sorted(t2_abs)}")
    print(f"  预测 diff(VCC_WIRE)@T2    = {sorted(t2_vcc)}")
    print(f"  预测 diff(LOGIC_OUTS_L12) = {sorted(t2_l12)}")
    check(sorted(t2_abs) == [(26453, 22, 3), (26456, 22, 2), (26458, 22, 2), (26459, 22, 2)],
          "abs(NR1END0)@T2 = {(26453,22,3),(26456,22,2),(26458,22,2),(26459,22,2)}")
    check(sorted(t2_l12) == [(26453, 22, 3), (26455, 22, 2), (26456, 22, 2), (26457, 22, 2)],
          "diff(L12)@T2 = {(26453,22,3),(26455,22,2),(26456,22,2),(26457,22,2)}")

    # 归一化判据 = 判据的数学形式，此处直接断言其可满足性
    def norm(bits, base):
        return {(f - base, w, b) for f, w, b in bits}

    check(norm(t2_abs, base2) == norm(ref, base1),
          "norm(T2_pure) == norm(T1_pure)：判据可满足（同一归一化集合）")
    check(norm(t2_l12, base2) == norm(ref ^ abs1("LOGIC_OUTS_L12"), base1),
          "norm(T2_xor) == norm(T1_xor)")

    # 全 25 源的 T2 预测表（供 preflight 按「实际源」改预测）
    table = {}
    for src in sorted(law):
        table[src] = {
            "abs1_at_T1": sorted(abs1(src)),
            "xor_vs_NR1END0_at_T2": sorted(shift(ref ^ abs1(src))),
        }
    table["VCC_WIRE"] = {"abs1_at_T1": [], "xor_vs_NR1END0_at_T2": sorted(t2_vcc)}
    print(f"  已生成 {len(table)} 个源的 T2 预测表（供 preflight 改走 R1 回退时使用）")
    return t2_abs, t2_vcc, t2_l12, table


# ---------------------------------------------------------------- S4
def s4(ecc_ok: bool):
    print("\n=== S4 判据自检：突变测试（判据必须能拒绝假差分） ===")
    base = 26434
    expected = {(26453, 22, 3), (26456, 22, 2), (26458, 22, 2), (26459, 22, 2)}
    window = set(range(16, 26))

    def judge(measured, exp=expected, b=base) -> tuple[bool, str]:
        """PASS/FAIL 判定器（与执行方必须使用的同一套规则）"""
        cfg = {(f, w, bb) for (f, w, bb) in measured if w != 50}
        shown = {(f, w, bb) for (f, w, bb) in measured if w == 50}
        if shown:
            print_(f"        (ECC 字单独计数 {len(shown)} 位，不参与内容位比对)")
        offs = {f - b for f, _w, _bb in cfg}
        out_win = {o for o in offs if o not in window}
        if out_win:
            return False, f"窗口外帧 off={sorted(out_win)}"
        norm = {(f - b, w, bb) for f, w, bb in cfg}
        exp_n = {(f - b, w, bb) for f, w, bb in exp}
        if norm != exp_n:
            return False, (f"missing={sorted(exp_n - norm)} "
                           f"extra={sorted(norm - exp_n)}")
        if len(measured) != len(cfg):
            return True, f"PASS（ECC {len(shown)} 位已单列）"
        return True, "PASS"

    def print_(m):
        print(m)

    cases = {
        "真值（原样）": (set(expected), True),
        "单帧偏移 +1": ({(f + 1 if f == 26453 else f, w, b) for f, w, b in expected}, False),
        "单 bit 改号 3->2": ({(f, w, (2 if (f == 26453 and b == 3) else b))
                            for f, w, b in expected}, False),
        "少一位": (set(list(expected)[:3]), False),
        "窗口外多一帧": (set(expected) | {(base + 40, 22, 2)}, False),
        "ECC 位混入（应仍 PASS）": (set(expected) | {(f, 50, 7) for f in (26453, 26456)}, True),
    }
    good = 0
    for name, (meas, want) in cases.items():
        got, why = judge(meas)
        ok = (got == want)
        good += ok
        print(f"  {'OK  ' if ok else 'FAIL'} {name:24s} judge={got} 期望={want} | {why}")
    check(good == len(cases), f"突变测试 {good}/{len(cases)}：判据通过真值且拒绝全部 5 类假差分")


# ---------------------------------------------------------------- S5
def s5(json_out: Path | None, t2_abs, t2_vcc, t2_l12, table, bases):
    print("\n=== S5 输出机器可读设计单 ===")
    spec = {
        "schema": "t56-pip-switchbox-design-v1",
        "generated_by": "v7re/scripts/t56_pip_switchbox_offline.py",
        "part_build": PART_BUILD,
        "part_law_db": PART_LAW,
        "device": "xc7vx485t",
        "object": "INT mux PIP switchbox (not CLB INIT)",
        "pair": [
            {"id": "T1", "tile": TILE1, "tile_type": "INT_L", "col": COL, "y": Y1,
             "band": band_of(Y1), "base_frame": bases[Y1], "word0": 22,
             "site": "SLICE_X8Y11", "role": "known-good reference (measured)"},
            {"id": "T2", "tile": TILE2, "tile_type": "INT_L", "col": COL, "y": Y2,
             "band": band_of(Y2), "base_frame": bases[Y2], "word0": 22,
             "site": "SLICE_X8Y61", "role": "target (this experiment)"},
        ],
        "delta_base": bases[Y2] - bases[Y1],
        "connection": {
            "site_pip_out": "CLBLL_L_X6Y{y}/CLBLL_L.CLBLL_LL_A->CLBLL_LOGIC_OUTS12",
            "beg_pip": "INT_L_X6Y{y-1}/INT_L.LOGIC_OUTS_L12->>NR1BEG0",
            "beg_pip_note": "BEG 源由路由器选择（T1 实测为 LOGIC_OUTS_L12）；T2 以 preflight 实测为准，"
                            "XOR 判据不依赖它（A/B/C 三构建的 BEG 完全相同）",
            "tileconn": "[0,1] INT_L.NR1BEG0 -> INT_L.NR1END0（固定连接，不是 mux）",
            "sink_pip": "INT_L_X6Y{y}/INT_L.NR1END0->>IMUX_L8",
            "site_pip_in": "CLBLL_L_X6Y{y}/CLBLL_L.CLBLL_IMUX8->CLBLL_LL_A5",
            "site_pip_in_note": "由 LOCK_PINS {I0:A5} + BEL A6LUT 结构性强制：I0 只能从 CLBLL_IMUX8 进，"
                                "故 INT 侧必然走 IMUX_L8",
            "family": FAMILY, "src": "NR1END0", "dst": SINK,
        },
        "builds": [
            {"id": "base", "op": "Vivado 整流程布线（X6Y60/61）", "src": "(router)",
             "bit": "base/base.bit",
             "role": "布线母本；preflight 从这里读实际 PIP 与 BEG 源"},
            {"id": "base2", "op": "同设计整流程重跑", "src": "(router)",
             "bit": "base2/base2.bit",
             "role": "负对照 C1：base2Δbase 必须为 0（构建确定性）"},
            {"id": "A", "op": "swap sink source -> NR1END0", "src": "NR1END0",
             "bit": "A.bit",
             "role": "基线：把 mux 选择钉死在 law 已知源（与路由器选了什么无关）"},
            {"id": "B", "op": "swap sink source -> VCC_WIRE", "src": "VCC_WIRE",
             "bit": "B.bit", "role": "零态（PURE）：BΔA = abs(NR1END0)@T2；abs(B) 窗口内为空"},
            {"id": "C", "op": "swap sink source -> LOGIC_OUTS_L12", "src": "LOGIC_OUTS_L12",
             "bit": "C.bit", "role": "XOR：CΔA = 4 位对称差（覆盖 6/10 格）"},
        ],
        "expected": {
            "base2_minus_base": [],
            "B_minus_A": sorted(t2_abs),
            "C_minus_A": sorted(t2_l12),
            "B_abs_in_window": [],
            "A_abs_word22": sorted(t2_abs),
            "word_of_row_T2": 22,
            "B_minus_A_equals_C_minus_A_xor_abs_L12": True,
            "norm": {
                "B_minus_A": sorted([f - bases[Y2], w, b] for f, w, b in t2_abs),
                "C_minus_A": sorted([f - bases[Y2], w, b] for f, w, b in t2_l12),
            },
        },
        "window_offsets": list(range(16, 26)),
        "ecc_word": 50,
        "table_all_sources_T2": table,
        "criteria": {
            "PASS": "内容位集合（word!=50）归一化到 (off=f-base, word, bit) 后与 expected[键] 逐位相等，"
                    "且 missing=0 extra=0、窗口 off 16..25 之外零变化",
            "主判据": "XOR 判据为主：B-A 与 C-A 都不依赖 BEG 走线，只依赖 sink mux 的选择位",
            "PURE": "abs(B) 在窗口内必须为空（VCC_WIRE=零态的直接证明）",
            "FAIL": "missing>0 或 extra>0 或出现窗口 off 16..25 之外的帧",
            "reject_if": "base2Δbase != 0（构建不确定）；此时仍可用同一 DCP 的 A/B/C 做 XOR 判据，"
                         "但 PURE/绝对集结论作废",
        },
        "fallbacks": {
            "R1_swap_pip_missing": "swap_source.py 报 PIP not found => 该 tile 的 IMUX 源集合与模板不符（结构性差异）；"
                                   "先用 templates/INT_L.json 的 pip_defs 按 dst 分组复核，确缺则改用按名删除 PIN 语义"
                                   "（pip_edit 显式删 '->>IMUX_L8'，禁止按索引删）",
            "R2_actual_family_differs": "preflight 显示 net n1 未从 IMUX_L8 进入（或 site pip 不是 IMUX8->A5）=> "
                                        "用该 family 的 law 重算预测（改 FAMILY 常量）；先查 LOCK_PINS/BEL 是否被工具改写",
            "R3_base_or_word_mismatch": "diff 帧落在窗口但对 base 系统性偏移 => 先用 pip_bits 的 24 条实测行回归地址律，"
                                        "再决定是否换 band/tile 对",
            "R4_route_not_reproducible": "base2Δbase != 0 => 放弃绝对集，仅用同一 DCP 内的 A/B/C 做 XOR 判据（判据仍有效）",
            "R5_hot_group_coverage_incomplete": "A→C 只覆盖 10 个格中的 6 个（独热格 16/17/18/20 未覆盖）=> "
                                               "另选 4 个源（各占一个独热组）各做一次 swap，判据同构；"
                                               "25 个源在 T2 的预测见本文件 table_all_sources_T2，无需重算",
            "R6_source_set_conflict": "同 tile_type 的 IMUX 源集合由 routing 模板统一给出，理论无冲突；"
                                      "若真冲突，退回 PIP_ADDRESS_ENCODING_LAW.md §5 的 36 组行映射按族固化作为输入",
        },
    }
    if json_out:
        json_out.parent.mkdir(parents=True, exist_ok=True)
        json_out.write_text(json.dumps(spec, ensure_ascii=False, indent=1), encoding="utf-8")
        print(f"  写入 {json_out} ({json_out.stat().st_size} 字节)")
    return spec


# ---------------------------------------------------------------- main
def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--json", type=Path, default=REPO / "v7re/steps/t56_switchbox_spec.json")
    args = ap.parse_args()

    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except Exception:
        pass

    con_law = open_ro(LAW_DB)
    con_model = open_ro(MODEL_DB)

    print(f"T56 离线核验  part_build={PART_BUILD}  part_law={PART_LAW}")

    law, bases = s0(con_law, con_model)

    # BEG 族的 law（S1 用）
    global law_beg
    law_beg = {}
    for fam in ("NR1BEG0", "NR1BEG2"):
        law_beg[fam] = {}
        for src, off, bit, sense, parity in con_law.execute(
            "select src_wire,frame_off,bit,sense,parity from law_cells "
            "where tile_type='INT_L' and family=?", (fam,)
        ):
            law_beg[fam].setdefault(src, {})[(off, bit)] = (parity, sense)

    s1(con_law, con_model, law_beg, bases)
    details, ref, abs1 = s2(law, bases)
    t2_abs, t2_vcc, t2_l12, table = s3(law, bases, ref, abs1)
    s4(True)
    spec = s5(args.json, t2_abs, t2_vcc, t2_l12, table, bases)

    print("\n=== 汇总 ===")
    if FAILS:
        print(f"  自检失败 {len(FAILS)} 项：")
        for f in FAILS:
            print("   -", f)
        return 1
    print("  全部自检通过（S0 结构 / S1 地址律 / S2 25 源 / S3 预测 / S4 判据突变）")
    print(f"  T2 目标: {TILE2} base={bases[Y2]} 预算 5 构建（base/base2/A/B/C）")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
