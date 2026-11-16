#!/usr/bin/env python3
"""tamper_localize.py —— 无参考位流的篡改检出与定位（威胁模型 TM2：语义自洽性校验）。

背景
----
S13–S15 已经把「位流 → PIP 列表 → 用定律重写 → 逐位比对」跑通，但那是**有参考**的
（重综合后的位图当基准）。本脚本换一个威胁模型：

  TM2（无参考 / 语义校验）：只拿到一个 .bit，没有 golden 位流，也没有网表。
  要求判断它是否被改过，并给出 (frame, word, bit) 级定位。

三层判据，每层都给可复算的定位：

  L1 可解释性：把位流解码成 PIP 集合，用定律/查表把该 PIP 集合重新编码成位集合；
      原始位流里**没有被任何已选 PIP 解释**的置位即为异常。定位粒度 = 单 bit。
  L2 槽位编码合法性：一个物理 mux 槽位 = (tile, bit b, parity)。它的合法编码只有
      「6 行 one-hot × 4 位列码 ∈ {1,2,7,11}」。三条不变量（干净位流 0 违例）：
        ① 同一槽位最多 1 行；② 有行 ⇒ 列码合法；③ 列码非 0 ⇒ 必须有行。
      定位粒度 = 槽位（tile, bit, parity）。
  L3 交叉一致性（诊断用）：同一 (tile, family) 命中 ≥2 个源 —— 因 cell 复用（每 cell
      被 3..18 个源共用），这条在干净位流上**恒有命中**，只能当诊断，不能当判据。

覆盖范围（诚实声明）：只建模 INT_L/INT_R 帧 0..25 的自有两个 word（44,100 个 tile，
占全器件配置位 45.2%）。CLB/DSP/BRAM tile、word 50（ECC）、其余 word 与行带不在
L1/L2 覆盖内 —— 这些区域的篡改本脚本**看不见**，这是要量的盲区，不是实现缺陷。

命令
----
    # 干净位流基线（理想：0 未解释位 / 0 槽位违例）
    python tamper_localize.py --check _full8.bit

    # 穷举单 bit 注入（解析式，不抽样）：遍历建模区内全部位，两个方向
    python tamper_localize.py --exhaustive _full8.bit --json ex.json

    # 多 bit 攻击：合成幽灵 mux / 换源，验证「≥2 bit 不可检出」
    python tamper_localize.py --attack _full8.bit --n 40 --seed 1 --json atk.json

    # 统计建模覆盖率
    python tamper_localize.py --coverage
"""
from __future__ import annotations

import argparse
import collections
import json
import os
import random
import sqlite3
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)
from bitstream.parser import frames_from_bit  # noqa: E402

LAW_DB = os.environ.get("V7RE_LAW_DB", r"E:\v7work\model\v7_law.sqlite")
LAW_JSON = os.path.join(ROOT, "steps", "pip_reuse_law.json")
BAND_ROWS = 50
ROWS_MAIN = (0, 1, 4, 5)        # 这 4 行用 pbit
ROWS_SUB = (2, 3)               # 这 2 行用 sbit = pbit ^ 1
LEGAL_CODES = (1, 2, 7, 11)
HI = 26                         # 块内 26 帧（0..25）


# ---------------------------------------------------------------- bit helpers
def load_bits(path):
    arr = np.array(frames_from_bit(path), dtype=np.uint32)
    bits = np.unpackbits(arr.view(np.uint8).reshape(arr.shape[0], 404),
                         axis=1, bitorder="little")
    return bits.reshape(arr.shape[0], 101, 32)


# 已知未建模格子（干净位流上恒定的「非布线」标记位）：
#   (1,0,0)/(1,1,0)  ref.bit 里每个被时钟/布线触及的 tile 都有这两格
#   (0,16,1)        GCLK 直通位（T5 定位）
KNOWN_UNMODELED = {(1, 0, 0), (1, 1, 0), (0, 16, 1)}


def word_of(y, par):
    w = 2 * (int(y) % BAND_ROWS) + par
    return w + 1 if w >= 50 else w


def code_of(frames_bits):
    """frames_bits = [b25,b24,b23,b22] → 4 位列码（码的 i 位在帧 25-i）。"""
    return sum(int(v) << i for i, v in enumerate(frames_bits))


# ------------------------------------------------------------------ tile world
class World:
    """INT tile 的地址 + 定律模型 + 查表回退。"""

    def __init__(self, db=LAW_DB, law_json=LAW_JSON):
        self.model = json.load(open(law_json, encoding="utf-8"))
        con = sqlite3.connect("file:%s?mode=ro" % db, uri=True)
        bbr = json.loads(con.execute(
            "SELECT value FROM meta WHERE key='band_by_region'").fetchone()[0])
        self.n_tiles_all = con.execute(
            "SELECT COUNT(*) FROM law_tiles").fetchone()[0]
        bands = collections.defaultdict(dict)
        for band, col, st in con.execute("SELECT band,col,start_frame FROM far_bands"):
            bands[band][col] = st
        self.tiles = []          # (name, ttype, col, y, base)
        seen = set()
        for name, ttype, col, y in con.execute(
                "SELECT tile_name,tile_type,col,y FROM law_tiles "
                "WHERE tile_type IN ('INT_L','INT_R')"):
            band = bbr[min(y // BAND_ROWS, len(bbr) - 1)]
            base = bands.get(band, {}).get(col)
            if base is None or name in seen:
                continue
            seen.add(name)
            self.tiles.append((name, ttype, col, y, int(base)))
        fb = collections.defaultdict(list)
        for fam, src, fo, bit, par, se in con.execute(
                "SELECT family,src_wire,frame_off,bit,parity,sense FROM law_cells "
                "WHERE tile_type IN ('INT_L','INT_R')"):
            fb[(fam, src)].append((fo, bit, par, se))
        con.close()
        # 每个 (ttype,family,src) 的格子列表；mux 区走定律，其余走查表
        self.cands = {tt: [] for tt in ("INT_L", "INT_R")}
        for fam, f in self.model["families"].items():
            pair, par, primary = f["pair"], f["parity"], f["primary"]
            pbit = pair if primary == "P" else pair + 1
            sbit = pair + 1 if primary == "P" else pair
            for src, (r, code) in f["slots"].items():
                row_bit = pbit if r in ROWS_MAIN else sbit
                cells = [(16 + r, row_bit, par)]
                for i, fr in enumerate((25, 24, 23, 22)):
                    if code >> i & 1:
                        cells.append((fr, pbit, par))
                for tt in self.cands:
                    self.cands[tt].append((fam, src, tuple(cells)))
        for (fam, src), cl in fb.items():
            if fam.startswith(("IMUX", "BYP_ALT", "FAN_ALT")):
                continue
            cells = tuple(sorted({(fo, bit, par) for (fo, bit, par, se) in cl
                                  if se == 1}))
            if not cells:
                continue
            for tt in self.cands:
                self.cands[tt].append((fam, src, cells))
        self.by_tile = {t[0]: i for i, t in enumerate(self.tiles)}

    # -- 哪些 tile 在帧 0..25 有置位（全 0 的 tile 不可能有 L1/L2 异常）
    def active_tiles(self, M, hi=HI):
        return [ti for ti, (name, tt, col, y, base) in enumerate(self.tiles)
                if M[base:base + hi, word_of(y, 0), :].any()
                or M[base:base + hi, word_of(y, 1), :].any()]

    # -- 该 tile 在帧 0..25 的置位集合 {(fo,bit,par)}
    def observed(self, M, ti, hi=HI):
        name, tt, col, y, base = self.tiles[ti]
        obs = set()
        for par in (0, 1):
            sub = M[base:base + hi, word_of(y, par), :]
            for fo, b in zip(*np.nonzero(sub)):
                obs.add((int(fo), int(b), par))
        return obs

    # -- 命中的 (family, src, cells)：要求全部格子置位
    def selected(self, M, ti, cands=None):
        name, tt, col, y, base = self.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        out = []
        for fam, src, cells in (cands if cands is not None else self.cands[tt]):
            if all(M[base + fo, words[par], bit] for (fo, bit, par) in cells):
                out.append((fam, src, cells))
        return out

    # -- L1：未解释位
    def explain(self, M, ti, hi=HI):
        obs = self.observed(M, ti, hi)
        sel = self.selected(M, ti)
        expl = set()
        for fam, src, cells in sel:
            expl.update(cells)
        return obs - expl, obs, sel

    # -- L2：槽位编码合法性
    def slot_state(self, M, ti, bit, par, override=None):
        """返回 (rows, code)。override = ((fo,bit,par), value) 用于假设性翻转。"""
        name, tt, col, y, base = self.tiles[ti]
        w = word_of(y, par)

        def rd(fo, b):
            if override is not None and (fo, b, par) == override[0]:
                return override[1]
            return int(M[base + fo, w, b])

        rows = [r for r in ROWS_MAIN if rd(16 + r, bit)]
        rows += [r for r in ROWS_SUB if rd(16 + r, bit ^ 1)]
        code = code_of([rd(25 - i, bit) for i in range(4)])
        return rows, code

    def slot_violations(self, M, ti, override=None):
        out = []
        for par in (0, 1):
            for bit in range(32):
                rows, code = self.slot_state(M, ti, bit, par, override)
                if len(rows) > 1:
                    out.append((bit, par, "multi-row", tuple(rows), code))
                elif rows and code not in LEGAL_CODES:
                    out.append((bit, par, "illegal-code", tuple(rows), code))
                elif not rows and code:
                    out.append((bit, par, "code-no-row", (), code))
        return out


# ------------------------------------------------------------------ detection
def scan(world, M, hi=HI):
    """全芯片 L1+L2 扫描。返回 (unexplained, violations, active_tiles)。"""
    un_all, v_all = [], []
    act = world.active_tiles(M, hi)
    for ti in act:
        un, _, _ = world.explain(M, ti, hi)
        for (fo, bit, par) in sorted(un):
            un_all.append((ti, fo, bit, par))
        for v in world.slot_violations(M, ti):
            v_all.append((ti,) + v)
    return un_all, v_all, act


def coverage_stats(world, M):
    """建模覆盖：位 / 全部配置位；tile / 全部 tile。"""
    tot = int(M.size)
    n_mod_tiles = len(world.tiles)
    bits_per_tile = HI * 2 * 32
    covered = n_mod_tiles * bits_per_tile
    covered_bits = 0
    for ti in range(n_mod_tiles):
        base = world.tiles[ti][4]
        y = world.tiles[ti][3]
        for par in (0, 1):
            covered_bits += int(M[base:base + HI, word_of(y, par), :].sum())
    return {"bits_covered": covered, "bits_total": tot,
            "bits_pct": round(100.0 * covered / tot, 2),
            "tiles_modelled": n_mod_tiles, "tiles_total": world.n_tiles_all,
            "tiles_pct": round(100.0 * n_mod_tiles / world.n_tiles_all, 2),
            "setbits_in_model": covered_bits}


# --------------------------------------------------- exhaustive single-bit math
def exhaustive_tile(world, M, ti, hi=HI):
    """解析式穷举该 tile 建模区内每一个 bit 的单点翻转，两个方向。

    判据与 scan() 一致：L1（有已选 PIP 的格子失去解释）+ L2（槽位编码非法）。
    基线解释不了的位（真实设计里必然存在）不参与「清 0」判定：清掉它只是让
    异常变少，不构成告警，单独记 off_baseline。

    返回 dict（每个键的 *_n 为次数，*_d 为检出次数，*_silent 为漏检）：
      off_mux / off_other  : 置位 → 清 0
      on_mux  / on_other   : 空位 → 置 1
    """
    un, obs, sel = world.explain(M, ti, hi)
    cellmap = collections.defaultdict(list)
    for i, (fam, src, cells) in enumerate(sel):
        for c in cells:
            cellmap[c].append(i)

    def covered_after(d, removed):
        for i in cellmap.get(d, ()):
            if i not in removed:
                return True
        return False

    # 差 1 格即可被选中的候选：它缺的那一格 → 置 1 后自解释（L1 沉默）
    deficit1 = set()
    for fam, src, cells in world.cands[world.tiles[ti][1]]:
        miss = [c for c in cells if c not in obs]
        if len(miss) == 1:
            deficit1.add(miss[0])

    def l2_bad(bit, par, c, val):
        rows, code = world.slot_state(M, ti, bit, par, (c, val))
        return (len(rows) > 1) or (bool(rows) and code not in LEGAL_CODES) \
            or (not rows and code != 0)

    stat = collections.Counter()
    for par in (0, 1):
        for bit in range(32):
            for fo in range(hi):
                c = (fo, bit, par)
                is_mux = fo >= 16
                if c in obs:
                    if c in un:
                        stat["off_baseline"] += 1
                        continue
                    rem = set(cellmap.get(c, ()))
                    hit = False
                    for i in rem:
                        for d in sel[i][2]:
                            if d != c and not covered_after(d, rem):
                                hit = True
                                break
                        if hit:
                            break
                    if not hit and is_mux:
                        hit = l2_bad(bit, par, c, 0)
                    key = "off_mux" if is_mux else "off_other"
                    stat[key + "_n"] += 1
                    stat[key + "_d"] += hit
                    if not hit:
                        stat[key + "_silent"] += 1
                else:
                    hit = c not in deficit1
                    if is_mux:
                        hit = hit or l2_bad(bit, par, c, 1)
                    key = "on_mux" if is_mux else "on_other"
                    stat[key + "_n"] += 1
                    stat[key + "_d"] += hit
                    if not hit:
                        stat[key + "_silent"] += 1
    return stat


def run_exhaustive(world, M, max_tiles=0, seed=1):
    act = world.active_tiles(M)
    if max_tiles and len(act) > max_tiles:
        act = sorted(random.Random(seed).sample(act, max_tiles))
    tot = collections.Counter()
    for ti in act:
        for k, v in exhaustive_tile(world, M, ti).items():
            tot[k] += v
    out = {"tiles_scanned": len(act), "cells_per_tile": HI * 2 * 32}
    for k in ("off_mux", "off_other", "on_mux", "on_other"):
        n, d = tot[k + "_n"], tot[k + "_d"]
        out[k] = {"n": n, "detected": d,
                  "rate_pct": round(100.0 * d / n, 4) if n else None,
                  "missed": n - d}
    out["off_baseline_skipped"] = tot["off_baseline"]
    n_all = sum(out[k]["n"] for k in ("off_mux", "off_other", "on_mux", "on_other"))
    d_all = sum(out[k]["detected"] for k in ("off_mux", "off_other", "on_mux", "on_other"))
    out["total"] = {"n": n_all, "detected": d_all,
                    "rate_pct": round(100.0 * d_all / n_all, 4) if n_all else None}
    return out


# ------------------------------------------------------------------- 交叉校验
def verify_analytic(world, M, rng, n=120):
    """抽样：真翻转 vs 解析预测，确认 exhaustive 的数学没错。"""
    act = world.active_tiles(M)
    rng.shuffle(act)
    rows = []
    agree = 0
    while len(rows) < n and act:
        ti = act.pop()
        name, tt, col, y, base = world.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        un0, obs, sel = world.explain(M, ti)
        cellmap = collections.defaultdict(list)
        for i, (fam, src, cells) in enumerate(sel):
            for c in cells:
                cellmap[c].append(i)

        def covered_after(d, removed):
            return any(i not in removed for i in cellmap.get(d, ()))

        deficit1 = set()
        for fam, src, cells in world.cands[tt]:
            miss = [c for c in cells if c not in obs]
            if len(miss) == 1:
                deficit1.add(miss[0])
        for _ in range(4):
            if len(rows) >= n:
                break
            c = (rng.randrange(HI), rng.randrange(32), rng.randrange(2))
            fo, bit, par = c
            is_mux = fo >= 16
            was_set = c in obs
            # 解析预测
            if was_set:
                if c in un0:
                    continue
                rem = set(cellmap.get(c, ()))
                pred = any(d != c and not covered_after(d, rem)
                           for i in rem for d in sel[i][2])
                if not pred and is_mux:
                    r2, cd2 = world.slot_state(M, ti, bit, par, (c, 0))
                    pred = (len(r2) > 1) or (bool(r2) and cd2 not in LEGAL_CODES) \
                        or (not r2 and cd2 != 0)
            else:
                pred = c not in deficit1
                if is_mux:
                    r2, cd2 = world.slot_state(M, ti, bit, par, (c, 1))
                    pred = pred or (len(r2) > 1) or (bool(r2) and cd2 not in LEGAL_CODES) \
                        or (not r2 and cd2 != 0)
            # 真翻转
            M[base + fo, words[par], bit] ^= 1
            un1, _, _ = world.explain(M, ti)
            v1 = world.slot_violations(M, ti)
            M[base + fo, words[par], bit] ^= 1
            obs_det = bool(set(un1) - set(un0)) or bool(v1)
            agree += int(obs_det == pred)
            rows.append({"cell": [fo, bit, par], "was_set": was_set,
                         "pred": bool(pred), "obs": bool(obs_det)})
    return {"n": len(rows), "agree": agree,
            "agree_pct": round(100.0 * agree / len(rows), 2) if rows else None,
            "mismatch": [r for r in rows if r["pred"] != r["obs"]][:10]}


# -------------------------------------------------------------------- attacks
def set_cells(M, base, words, cells, val):
    for (fo, bit, par) in cells:
        M[base + fo, words[par], bit] = val


def attack_fake_mux(world, M, rng, n):
    """2-bit 攻击：在空槽位上合成一个**合法**的幽灵 mux（1 行位 + 1 列码位）。

    期望：L1 沉默（幽灵 PIP 自解释）、L2 沉默（编码合法）→ 检出率 0，
    而且解码器会把这 2 个 bit 报成一条**从未布线过的 PIP**。
    """
    act = world.active_tiles(M)
    rng.shuffle(act)
    done, sealed, caught, no_effect = 0, 0, 0, []
    phantoms = []
    for ti in act:
        name, tt, col, y, base = world.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        sel0 = set((f, s) for f, s, _ in world.selected(M, ti))
        for fam, src, cells in world.cands[tt]:
            if len(cells) != 2:
                continue
            if any(c[0] < 16 for c in cells):
                continue
            pars = {c[2] for c in cells}
            bits = {c[1] for c in cells}
            if len(pars) != 1 or len(bits) != 1:
                continue          # 必须落在同一个物理槽位（同一 bit / parity）
            par, bit = pars.pop(), bits.pop()
            if world.slot_state(M, ti, bit, par) != ([], 0):
                continue          # 槽位必须是全空的
            if any(M[base + fo, words[par], b] for (fo, b, _) in cells):
                continue
            # 2026-11-08 修正：必须与基线签名比较，否则「该 tile 本来就有未解释位
            # （(1,0,0)/(1,1,0) 两个标记位）」会被误算成检出。
            sig0 = _tile_signature(world, M, ti)
            set_cells(M, base, words, cells, 1)
            un, _, sel1 = world.explain(M, ti)
            viol = world.slot_violations(M, ti)
            new = [(f, s) for f, s, _ in sel1 if (f, s) not in sel0]
            caught_here, _, _ = _detect(world, M, ti, sig0)
            if caught_here:
                caught += 1
            elif new:
                sealed += 1
                if len(phantoms) < 5:
                    phantoms.append({"tile": name, "family": new[0][0],
                                     "src": new[0][1],
                                     "bits": [[fo, b, p] for (fo, b, p) in cells]})
            else:
                no_effect.append([name, fam, src])
            set_cells(M, base, words, cells, 0)
            done += 1
            if done >= n:
                break
        if done >= n:
            break
    return {"attempted": done, "undetected_with_phantom_pip": sealed,
            "detected": caught, "no_phantom_no_anomaly": len(no_effect),
            "detect_rate_pct": round(100.0 * caught / done, 2) if done else None,
            "examples": phantoms}


def attack_swap(world, M, rng, n):
    """换源攻击：把已选 PIP 换成同族另一源，按需要改最少的位。"""
    act = world.active_tiles(M)
    rng.shuffle(act)
    cost = collections.Counter()
    cost_det = collections.Counter()
    exposure_n = collections.Counter()
    exposure_hit = collections.Counter()
    det = 0
    done = 0
    undetected = []
    for ti in act:
        name, tt, col, y, base = world.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        by_fam = collections.defaultdict(list)
        for fam, src, cells in world.cands[tt]:
            by_fam[fam].append((src, cells))
        sel = world.selected(M, ti)
        cellmap = collections.defaultdict(list)
        for i, (f2, s3, cells3) in enumerate(sel):
            for c3 in cells3:
                cellmap[c3].append(i)
        for fam, src, cells in sel:
            alts = [(s, c) for s, c in by_fam.get(fam, ()) if s != src]
            if not alts:
                continue
            s2, c2 = rng.choice(alts)
            diff_off = [c for c in cells if c not in c2]
            diff_on = [c for c in c2 if c not in cells]
            k = len(diff_off) + len(diff_on)
            # 附带损伤预估：清掉的格是否被别的已选 PIP 共用
            exposure = sum(len([i for i in cellmap.get(c, ())
                                if sel[i][1] != src]) for c in diff_off)
            pred = exposure > 0
            # 逐格保存原值再恢复：共享格若被无条件写成 0/1，会污染后续样本
            touched = [(fo, bit, par) for (fo, bit, par) in diff_off + diff_on]
            orig = {c: int(M[base + c[0], words[c[2]], c[1]]) for c in touched}
            sig0 = _tile_signature(world, M, ti)
            set_cells(M, base, words, diff_off, 0)
            set_cells(M, base, words, diff_on, 1)
            hit, _, _ = _detect(world, M, ti, sig0)
            for (fo, bit, par), v in orig.items():
                M[base + fo, words[par], bit] = v
            cost[k] += 1
            cost_det[k] += hit
            exposure_n[exposure > 0] += 1
            exposure_hit[(bool(exposure > 0), hit)] += 1
            done += 1
            if hit:
                det += 1
            elif len(undetected) < 5:
                undetected.append({"tile": name, "family": fam, "from": src,
                                   "to": s2, "bits_changed": k})
            if done >= n:
                break
        if done >= n:
            break
    return {"attempted": done, "detected": det,
            "detect_rate_pct": round(100.0 * det / done, 2) if done else None,
            "bits_changed_hist": dict(sorted(cost.items())),
            "detect_by_cost": {str(k): {"n": cost[k], "detected": cost_det[k],
                                        "rate_pct": round(100.0 * cost_det[k] / cost[k], 1)}
                               for k in sorted(cost)},
            "exposure_model": {
                "with_exposure_n": exposure_n[True],
                "with_exposure_detected": exposure_hit[(True, True)],
                "with_exposure_rate_pct": round(
                    100.0 * exposure_hit[(True, True)] / exposure_n[True], 1)
                if exposure_n[True] else None,
                "no_exposure_n": exposure_n[False],
                "no_exposure_detected": exposure_hit[(False, True)],
                "no_exposure_rate_pct": round(
                    100.0 * exposure_hit[(False, True)] / exposure_n[False], 1)
                if exposure_n[False] else None},
            "undetected_examples": undetected}


# ------------------------------------------------------------ tamper classes
def _tile_signature(world, M, ti):
    un, _, _ = world.explain(M, ti)
    return len(un), len(world.slot_violations(M, ti))


def _detect(world, M, ti, sig0):
    """基线签名 vs 篡改后签名：L1 变多或 L2 出现即算检出。"""
    b_un, b_v = sig0
    a_un, a_v = _tile_signature(world, M, ti)
    return (a_un > b_un or a_v > b_v), a_un - b_un, a_v - b_v


def class_pip_disable(world, M, rng, n):
    """整条已布线 PIP 抹掉：清空它全部的格子（等价于「这条 PIP 没被布线」）。

    这不是非法码字，只是一条 PIP 从配置里消失 —— 检测器没有 golden 网表，
    理论上看不见。这里实测。
    """
    act = world.active_tiles(M)
    rng.shuffle(act)
    done = det = 0
    ex = []
    for ti in act:
        name, tt, col, y, base = world.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        sel = world.selected(M, ti)
        if not sel:
            continue
        fam, src, cells = sel[rng.randrange(len(sel))]
        sig0 = _tile_signature(world, M, ti)
        set_cells(M, base, words, list(cells), 0)
        hit, du, dv = _detect(world, M, ti, sig0)
        set_cells(M, base, words, list(cells), 1)
        done += 1
        det += hit
        if not hit and len(ex) < 5:
            ex.append({"tile": name, "family": fam, "source": src,
                       "bits_cleared": len(cells)})
        if done >= n:
            break
    return {"class": "pip_disable", "attempted": done, "detected": det,
            "detect_rate_pct": round(100.0 * det / done, 2) if done else None,
            "undetected_examples": ex}


def class_pip_enable(world, M, rng, n):
    """整条未布线 PIP 添加：把某个候选 (family, source) 的全部格子写成 1。

    只要该槽位原本是空的，写进去的就是一个合法码字 —— 这就是「幽灵 PIP」，
    只是不是手挑 2 格，而是整条合法编码。
    """
    act = world.active_tiles(M)
    rng.shuffle(act)
    done = det = 0
    ex = []
    for ti in act:
        name, tt, col, y, base = world.tiles[ti]
        words = {0: word_of(y, 0), 1: word_of(y, 1)}
        sel = world.selected(M, ti)
        chosen = set((f, s) for f, s, _ in sel)
        cands = [(f, s, c) for f, s, c in world.cands[tt]
                 if (f, s) not in chosen
                 and not any(M[base + fo, words[par], bit] for (fo, bit, par) in c)]
        if not cands:
            continue
        fam, src, cells = cands[rng.randrange(len(cands))]
        sig0 = _tile_signature(world, M, ti)
        set_cells(M, base, words, list(cells), 1)
        hit, du, dv = _detect(world, M, ti, sig0)
        set_cells(M, base, words, list(cells), 0)
        done += 1
        det += hit
        if not hit and len(ex) < 5:
            ex.append({"tile": name, "family": fam, "source": src,
                       "bits_set": len(cells)})
        if done >= n:
            break
    return {"class": "pip_enable_blank", "attempted": done, "detected": det,
            "detect_rate_pct": round(100.0 * det / done, 2) if done else None,
            "undetected_examples": ex}


def class_word50(world, M, rng, n):
    """word 50（每行 ECC 字）里的单个 bit 翻转。

    word 50 在 word_of() 里永不产生（映射自动跳过），所以结构层不看它。
    这正是 ECC 被重算后攻击者能自由使用的位置。
    """
    act = world.active_tiles(M)
    rng.shuffle(act)
    done = det = 0
    ex = []
    for ti in act:
        name, tt, col, y, base = world.tiles[ti]
        fo = rng.randrange(HI)
        bit = rng.randrange(32)
        old = int(M[base + fo, 50, bit])
        sig0 = _tile_signature(world, M, ti)
        M[base + fo, 50, bit] = 1 - old
        hit, du, dv = _detect(world, M, ti, sig0)
        M[base + fo, 50, bit] = old
        done += 1
        det += hit
        if not hit and len(ex) < 5:
            ex.append({"tile": name, "frame": int(base + fo), "word": 50,
                       "bit": bit, "written": 1 - old})
        if done >= n:
            break
    return {"class": "word50_bit", "attempted": done, "detected": det,
            "detect_rate_pct": round(100.0 * det / done, 2) if done else None,
            "undetected_examples": ex}


def run_classes(world, M, rng, n):
    return [class_pip_disable(world, M, rng, n),
            class_pip_enable(world, M, rng, n),
            class_word50(world, M, rng, n)]


def delta_vs(world, M, other):
    """两个位流的 XOR 差异：有多少落在建模区、扫描结论是否变化。"""
    d = np.argwhere(M != other)
    act = set(world.active_tiles(np.maximum(M, other)))
    modeled = 0
    per_tile = {}
    for f, w, b in d:
        f, w, b = int(f), int(w), int(b)
        hit = False
        for ti in act:
            name, tt, col, y, base = world.tiles[ti]
            if base <= f < base + HI and w in (word_of(y, 0), word_of(y, 1)):
                hit = True
                per_tile[name] = per_tile.get(name, 0) + 1
                break
        modeled += hit
    un_a, v_a, _ = scan(world, M)
    un_b, v_b, _ = scan(world, other)
    return {"delta_bits": len(d), "delta_in_modeled_region": modeled,
            "delta_pct_modeled": round(100.0 * modeled / len(d), 2) if len(d) else None,
            "delta_by_tile_top": sorted(per_tile.items(), key=lambda x: -x[1])[:5],
            "scan_a": {"unexplained": len(un_a), "violations": len(v_a)},
            "scan_b": {"unexplained": len(un_b), "violations": len(v_b)}}


# ----------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", metavar="BIT")
    ap.add_argument("--exhaustive", metavar="BIT")
    ap.add_argument("--attack", metavar="BIT")
    ap.add_argument("--classes", metavar="BIT",
                    help="按篡改类（整条 PIP 删/加、word50）跑注入实验")
    ap.add_argument("--delta", metavar="BIT",
                    help="与 --classes/--check 给出的位流做 XOR 差异分析")
    ap.add_argument("--coverage", action="store_true")
    ap.add_argument("--whitelist", action="store_true",
                    help="把 KNOWN_UNMODELED 里的格子从 L1 里剔掉后再统计")
    ap.add_argument("--fpstats", action="store_true",
                    help="干净位流上的误报统计（L1 未解释位 / L2 违例 / 告警 tile 数）")
    ap.add_argument("--verify", metavar="BIT",
                    help="抽样真翻转，校验 exhaustive 的解析统计")
    ap.add_argument("--n", type=int, default=40)
    ap.add_argument("--tiles", type=int, default=0,
                    help="exhaustive 最多扫多少个 active tile（0=全部）")
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--json")
    a = ap.parse_args()

    world = World()
    path = a.check or a.exhaustive or a.attack or a.verify or a.classes
    if a.coverage or not path:
        M = load_bits(path or os.path.join(os.path.dirname(ROOT), "_full8.bit"))
        print(json.dumps(coverage_stats(world, M), ensure_ascii=False, indent=2))
        return 0

    M = load_bits(path)
    print("%s: frames=%d setbits=%d" % (os.path.basename(path), M.shape[0],
                                        int(M.sum())))
    un, viol, act = scan(world, M)
    print("基线: active_tiles=%d  L1 未解释位=%d  L2 槽位违例=%d"
          % (len(act), len(un), len(viol)))
    for x in un[:5]:
        print("   unexplained %s fo=%d bit=%d par=%d"
              % (world.tiles[x[0]][0], x[1], x[2], x[3]))
    for x in viol[:5]:
        print("   slot %s bit=%d par=%d %s rows=%s code=%d"
              % (world.tiles[x[0]][0], x[1], x[2], x[3], x[4], x[5]))

    out = {"bitstream": os.path.basename(path), "setbits": int(M.sum()),
           "baseline": {"unexplained": len(un), "slot_violations": len(viol),
                        "active_tiles": len(act)}}
    if a.verify:
        out["verify_analytic"] = verify_analytic(world, M, random.Random(a.seed),
                                                 a.n if a.n > 40 else 120)
    if a.exhaustive:
        out["exhaustive"] = run_exhaustive(world, M, a.tiles, a.seed)
    if a.attack:
        rng = random.Random(a.seed)
        out["attack_fake_mux"] = attack_fake_mux(world, M, rng, a.n)
        out["attack_swap"] = attack_swap(world, M, rng, a.n)
    if a.classes:
        out["classes"] = run_classes(world, M, random.Random(a.seed), a.n)
    if a.delta:
        other = load_bits(a.delta)
        out["delta"] = delta_vs(world, M, other)
    if a.fpstats:
        act_set = world.active_tiles(M)
        wl_un = sum(1 for (ti, fo, bit, par) in un if (fo, bit, par) in KNOWN_UNMODELED)
        wl_tiles = len({x[0] for x in un if (x[1], x[2], x[3]) not in KNOWN_UNMODELED})
        tiles_warn = 0
        setbits_model = 0
        for ti in act_set:
            u, obs, _ = world.explain(M, ti)
            if u:
                tiles_warn += 1
            setbits_model += len(obs)
        modeled = len(act_set) * HI * 2 * 32
        out["fpstats"] = {
            "active_tiles": len(act_set), "tiles_with_unexplained": tiles_warn,
            "tile_false_alarm_pct": round(100.0 * tiles_warn / len(act_set), 2),
            "unexplained_bits": len(un), "violations": len(viol),
            "modeled_bits": modeled,
            "bit_false_alarm_per_1e6": round(1e6 * len(un) / modeled, 2),
            "setbits_in_model": setbits_model,
            "unexplained_per_setbit_pct": round(100.0 * len(un) / setbits_model, 3)
            if setbits_model else None,
            "whitelisted_bits": wl_un, "tiles_warn_after_whitelist": wl_tiles,
            "unexplained_after_whitelist": len(un) - wl_un}
        print(json.dumps(out["fpstats"], ensure_ascii=False, indent=2))
    if a.exhaustive or a.attack or a.verify or a.classes or a.delta:
        print(json.dumps({k: v for k, v in out.items() if k != "baseline"},
                         ensure_ascii=False, indent=2))
    if a.json:
        json.dump(out, open(a.json, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=2)
    return 0


if __name__ == "__main__":
    sys.exit(main())
