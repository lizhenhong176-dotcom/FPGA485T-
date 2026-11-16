#!/usr/bin/env python3
"""v_bits.py —— 在远端**直接从 .bit 重算**观测位，再对着形状表判定。

与 verify_reuse.py 的区别：verify_reuse 读的是缓存 JSON（tilepipe.json 等），
本脚本重新解析比特流，等于把「实验 → 差分 → 判定」整条链在远端重跑一遍，
不信任任何中间产物。

三个模式
--------
  tilepipe  单 PIP（PURE 语义）：ref 是删掉 sink PIP 的 dcp 生成的，
            差分应**恰好等于**形状表里 sense=1 的格集合。
  sweep     多 PIP 叠加（ref 删掉整条 net 的全部 PIP）：
            差分应落在「该 net 所有 INT_L/INT_R PIP 的格集合」之内，
            且理想情况下等于它们 sense=1 格的并集。
  fam       追加一条 PIP（FAM 语义）：置位 ⊆ sense=1，清零 ⊆ sense=0。

用法
----
  python3 v_bits.py tilepipe --dir /opt/lzh/step03/tilepipe --tile INT_L_X6Y11 \
          --shard 0/12 --out out_tp_0.json
  python3 v_bits.py merge out_tp_*.json --out out_tp.json
  python3 v_bits.py sweep  --dir /opt/lzh/step03/sweep1  --out out_sweep.json
  python3 v_bits.py fam    --dir /opt/lzh/step03/fam  --tile INT_L_X6Y11 --out out_fam.json
  python3 v_bits.py fam    --dir /opt/lzh/step03/famr --tile INT_R_X7Y10 --out out_famr.json

只依赖标准库 + /opt/lzh/v7re/bitstream/parser.py。
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import re
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, "/opt/lzh/v7re")

import pip_law                                    # noqa: E402
from bitstream.parser import frames_from_bit      # noqa: E402

ECC_WORD = 50
_SINK_RE = re.compile(r"IMUX(?:_[LR])?\d+")


# ------------------------------------------------------------------ 基础工具
def diff_dir(ref, var, skip=ECC_WORD):
    """返回 [(frame, word, bit, value_in_var)]；value=1 表示置位，0 表示清零。"""
    out = []
    n = min(len(ref), len(var))
    for i in range(n):
        a, b = ref[i], var[i]
        if a == b:
            continue
        for w in range(len(a)):
            if w == skip:
                continue
            d = a[w] ^ b[w]
            while d:
                bit = (d & -d).bit_length() - 1
                d &= d - 1
                out.append((i, w, bit, (b[w] >> bit) & 1))
    return out


def ecc_diff_count(ref, var):
    n = 0
    for i in range(min(len(ref), len(var))):
        if ref[i][ECC_WORD] != var[i][ECC_WORD]:
            n += 1
    return n


def load_cache(name):
    p = os.path.join(HERE, name)
    if not os.path.exists(p):
        return None
    with open(p, encoding="utf-8-sig") as fh:
        return json.load(fh)


def cells_of(rows, sense):
    return {(f, w, b) for f, w, b, s in rows if s == sense}


def verdict(obs, pred1, pred0):
    """obs/pred 都是 {(f,w,b)}；返回 (判定, extra, missing)。"""
    extra = obs - pred1 - pred0
    missing = pred1 - obs
    if not extra and not missing:
        return "EXACT", [], []
    if not extra and not (obs - pred1):
        return "SUB", [], sorted(missing)
    if extra and not (obs - pred1 - pred0):
        return "EXTRA", sorted(extra), []
    return "MIX", sorted(extra), sorted(missing)


def shard_pick(items, spec):
    if not spec:
        return items
    i, n = (int(x) for x in spec.split("/"))
    return [x for k, x in enumerate(items) if k % n == i]


def write_out(path, obj):
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(obj, fh, indent=1, sort_keys=True)
    print("写出 %s" % path)


# ------------------------------------------------------------------ tilepipe
def cmd_tilepipe(a):
    R = a.dir
    tags = sorted(os.path.basename(p)[4:-4]
                  for p in glob.glob(os.path.join(R, "ref_*.bit")))
    tags = shard_pick(tags, a.shard)
    cache = None if a.no_cache else load_cache(a.cache)
    out = {}
    tot = {"EXACT": 0, "SUB": 0, "EXTRA": 0, "MIX": 0, "NO_SHAPE": 0}
    cache_same = cache_diff = cache_none = 0
    t0 = time.time()
    nparsed = 0

    for tag in tags:
        refp = os.path.join(R, "ref_%s.bit" % tag)
        ref = frames_from_bit(refp)
        nparsed += 1
        sink = ""
        sp = os.path.join(R, tag + ".sink")
        if os.path.exists(sp):
            with open(sp) as fh:
                m = _SINK_RE.search(fh.read())
            sink = m.group(0) if m else ""
        rec = {"tile": a.tile, "sink": sink, "sources": {}}
        for f in sorted(os.listdir(R)):
            if not (f.startswith("v_%s_" % tag) and f.endswith(".bit")):
                continue
            src = f[len("v_%s_" % tag):-4]
            if a.limit and len(rec["sources"]) >= a.limit:
                break
            var = frames_from_bit(os.path.join(R, f))
            nparsed += 1
            rows = diff_dir(ref, var)
            obs = {(x[0], x[1], x[2]) for x in rows}
            pred_rows = pip_law.predict(a.tile, sink, src) if sink else []
            if not pred_rows:
                tot["NO_SHAPE"] += 1
                rec["sources"][src] = {"verdict": "NO_SHAPE", "obs": len(obs)}
                continue
            p1 = cells_of(pred_rows, 1)
            p0 = cells_of(pred_rows, 0)
            v, extra, missing = verdict(obs, p1, p0)
            tot[v] += 1
            ent = {"verdict": v, "obs": len(obs), "pred1": len(p1),
                   "ecc_frames": ecc_diff_count(ref, var)}
            if extra:
                ent["extra"] = extra[:20]
            if missing:
                ent["missing"] = missing[:20]
            if cache and tag in cache and src in cache.get(tag, {}).get("sources", {}):
                cobs = {tuple(x[:3]) for x in cache[tag]["sources"][src]}
                if cobs == obs:
                    cache_same += 1
                    ent["cache"] = "same"
                else:
                    cache_diff += 1
                    ent["cache"] = "diff"
                    ent["cache_only"] = sorted(cobs - obs)[:10]
                    ent["recomputed_only"] = sorted(obs - cobs)[:10]
            else:
                cache_none += 1
                ent["cache"] = "none"
            rec["sources"][src] = ent
        out[tag] = rec
        print("  %-28s sink=%-9s 源=%d  累计 %.0fs"
              % (tag, sink, len(rec["sources"]), time.time() - t0))

    summary = {"mode": "tilepipe", "dir": R, "tile": a.tile, "tags": len(tags),
               "parsed_bits": nparsed, "verdicts": tot,
               "cache_same": cache_same, "cache_diff": cache_diff,
               "cache_none": cache_none, "seconds": round(time.time() - t0, 1)}
    write_out(a.out, {"summary": summary, "tags": out})
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if (tot["EXTRA"] == 0 and tot["MIX"] == 0 and cache_diff == 0) else 1


# --------------------------------------------------------------------- sweep
def cmd_sweep(a):
    R = a.dir
    tags = sorted(re.match(r"pips_(.+)\.json$", f).group(1)
                  for f in os.listdir(R) if f.startswith("pips_"))
    tags = shard_pick(tags, a.shard)
    cache = None if a.no_cache else load_cache(a.cache)
    out = {}
    tot = {"EXACT": 0, "SUB": 0, "EXTRA": 0, "MIX": 0}
    cache_same = cache_diff = cache_none = 0
    n_pips = n_int = n_noshape = 0
    t0 = time.time()

    for tag in tags:
        refp = os.path.join(R, "ref_%s.bit" % tag)
        varp = os.path.join(R, "%s.bit" % tag)
        if not (os.path.exists(refp) and os.path.exists(varp)):
            print("  [skip] %s 缺 bit" % tag)
            continue
        ref = frames_from_bit(refp)
        var = frames_from_bit(varp)
        rows = diff_dir(ref, var)
        obs = {(x[0], x[1], x[2]) for x in rows}
        pips = json.load(open(os.path.join(R, "pips_%s.json" % tag)))
        n_pips += len(pips)
        pred1, pred0, no_shape, skipped = set(), set(), [], []
        for p in pips:
            t = p["tile"]
            if not (t.startswith("INT_L_X") or t.startswith("INT_R_X")):
                skipped.append("%s:%s->%s" % (t, p["src"], p["sink"]))
                continue
            n_int += 1
            pr = pip_law.predict_family(t, p["sink"], p["src"])
            if not pr:
                no_shape.append("%s:%s->%s" % (t, p["src"], p["sink"]))
                continue
            pred1 |= cells_of(pr, 1)
            pred0 |= cells_of(pr, 0)
        n_noshape += len(no_shape)
        v, extra, missing = verdict(obs, pred1, pred0)
        tot[v] += 1
        ent = {"verdict": v, "obs": len(obs), "pred1": len(pred1),
               "pred0": len(pred0), "pips": len(pips), "int_pips": len(pips) - len(skipped),
               "no_shape": no_shape, "ecc_frames": ecc_diff_count(ref, var)}
        if extra:
            ent["extra"] = extra[:20]
        if missing:
            ent["missing"] = missing[:20]
        if cache and tag in cache:
            cobs = {tuple(x[:3]) for x in cache[tag]}
            if cobs == obs:
                cache_same += 1
                ent["cache"] = "same"
            else:
                cache_diff += 1
                ent["cache"] = "diff"
                ent["cache_only"] = sorted(cobs - obs)[:10]
                ent["recomputed_only"] = sorted(obs - cobs)[:10]
        else:
            cache_none += 1
            ent["cache"] = "none"
        out[tag] = ent
        print("  %-12s pips=%-3d INT=%-3d obs=%-4d pred1=%-4d %-5s cache=%s"
              % (tag, len(pips), len(pips) - len(skipped), len(obs), len(pred1),
                 v, ent["cache"]))

    summary = {"mode": "sweep", "dir": R, "tags": len(out), "verdicts": tot,
               "pips_total": n_pips, "int_pips_total": n_int,
               "no_shape_total": n_noshape,
               "cache_same": cache_same, "cache_diff": cache_diff,
               "cache_none": cache_none, "seconds": round(time.time() - t0, 1)}
    write_out(a.out, {"summary": summary, "tags": out})
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if (tot["EXTRA"] == 0 and tot["MIX"] == 0 and cache_diff == 0) else 1


# ----------------------------------------------------------------------- fam
def cmd_fam(a):
    R = a.dir
    ref = frames_from_bit(os.path.join(R, a.ref))
    spec = None
    sp = os.path.join(R, "spec.json")
    if os.path.exists(sp):
        spec = {row[2]: (row[0], row[1]) for row in json.load(open(sp))}
    cache = None if a.no_cache else load_cache(a.cache)
    exp = None if a.no_cache else load_cache(a.expected)
    vars_ = sorted(f for f in os.listdir(R)
                   if f.startswith("v_") and f.endswith(".bit"))
    vars_ = shard_pick(vars_, a.shard)
    all_recs = json.load(open(os.path.join(HERE, "all_cells.json"), encoding="utf-8-sig"))
    fams = sorted({r["family"] for r in all_recs}, key=len, reverse=True)

    out = {}
    tot = {"EXACT": 0, "SUB": 0, "EXTRA": 0, "MIX": 0, "NO_SHAPE": 0}
    clear_ok = clear_bad = 0
    set_events = clear_events = 0
    cache_same = cache_diff = cache_none = 0
    t0 = time.time()

    for f in vars_:
        name = f[:-4]
        if spec and name in spec:
            family, src = spec[name]
        else:
            stem = name[2:]
            family = next((x for x in fams if stem.startswith(x + "_")), None)
            if family is None:
                tot["NO_SHAPE"] += 1
                out[name] = {"verdict": "NO_SHAPE"}
                continue
            src = stem[len(family) + 1:]
        var = frames_from_bit(os.path.join(R, f))
        rows = diff_dir(ref, var)
        ones = {(x[0], x[1], x[2]) for x in rows if x[3] == 1}
        zeros = {(x[0], x[1], x[2]) for x in rows if x[3] == 0}
        set_events += len(ones)
        clear_events += len(zeros)
        pr = pip_law.predict_family(a.tile, family, src)
        if not pr:
            tot["NO_SHAPE"] += 1
            out[name] = {"verdict": "NO_SHAPE", "family": family, "src": src,
                         "obs": len(ones)}
            continue
        p1 = cells_of(pr, 1)
        p0 = cells_of(pr, 0)
        v, extra, missing = verdict(ones, p1, p0)
        tot[v] += 1
        bad_clear = sorted(zeros - p0)
        if bad_clear:
            clear_bad += 1
        else:
            clear_ok += 1
        ent = {"verdict": v, "family": family, "src": src, "set": len(ones),
               "clear": len(zeros), "pred1": len(p1), "pred0": len(p0),
               "clear_outside_sense0": bad_clear[:10],
               "ecc_frames": ecc_diff_count(ref, var)}
        if extra:
            ent["extra"] = extra[:20]
        if missing:
            ent["missing"] = missing[:20]
        if cache and name in cache:
            cobs = {tuple(x[:3]) for x in cache[name]}
            if cobs == (ones | zeros):
                cache_same += 1
                ent["cache"] = "same"
            else:
                cache_diff += 1
                ent["cache"] = "diff"
                ent["cache_only"] = sorted(cobs - (ones | zeros))[:10]
                ent["recomputed_only"] = sorted((ones | zeros) - cobs)[:10]
        else:
            cache_none += 1
            ent["cache"] = "none"
        out[name] = ent

    summary = {"mode": "fam", "dir": R, "tile": a.tile, "variants": len(vars_),
               "verdicts": tot, "set_events": set_events,
               "clear_events": clear_events,
               "clear_within_sense0": clear_ok, "clear_outside_sense0": clear_bad,
               "cache_same": cache_same, "cache_diff": cache_diff,
               "cache_none": cache_none, "seconds": round(time.time() - t0, 1)}
    write_out(a.out, {"summary": summary, "variants": out})
    print(json.dumps(summary, ensure_ascii=False))
    return 0 if (tot["EXTRA"] == 0 and tot["MIX"] == 0 and clear_bad == 0
                 and cache_diff == 0) else 1


# --------------------------------------------------------------------- merge
def cmd_merge(a):
    parts = []
    for pat in a.inputs:
        parts.extend(sorted(glob.glob(pat)))
    if not parts:
        print("没有输入")
        return 2
    merged = {"summary": {}, "tags": {}}
    tot = {"EXACT": 0, "SUB": 0, "EXTRA": 0, "MIX": 0, "NO_SHAPE": 0}
    cs = cd = cn = 0
    parsed = 0
    secs = 0.0
    for p in parts:
        d = json.load(open(p, encoding="utf-8"))
        s = d.get("summary", {})
        for k, v in s.get("verdicts", {}).items():
            tot[k] = tot.get(k, 0) + v
        cs += s.get("cache_same", 0)
        cd += s.get("cache_diff", 0)
        cn += s.get("cache_none", 0)
        parsed += s.get("parsed_bits", 0)
        secs += s.get("seconds", 0.0)
        body = d.get("tags") or d.get("variants") or {}
        merged["tags"].update(body)
    merged["summary"] = {"mode": "merged", "parts": len(parts),
                         "verdicts": tot, "items": len(merged["tags"]),
                         "parsed_bits": parsed,
                         "cache_same": cs, "cache_diff": cd, "cache_none": cn,
                         "seconds": round(secs, 1)}
    write_out(a.out, merged)
    print(json.dumps(merged["summary"], ensure_ascii=False))
    return 0 if (tot.get("EXTRA", 0) == 0 and tot.get("MIX", 0) == 0 and cd == 0) else 1


# ---------------------------------------------------------------------- main
def main(argv):
    ap = argparse.ArgumentParser(description="远端位级验证：从 .bit 重算并判定")
    sub = ap.add_subparsers(dest="cmd", required=True)

    p = sub.add_parser("tilepipe", help="单 PIP（PURE）")
    p.add_argument("--dir", default="/opt/lzh/step03/tilepipe")
    p.add_argument("--tile", default="INT_L_X6Y11")
    p.add_argument("--shard", default=None, help="i/n")
    p.add_argument("--limit", type=int, default=0, help="每个 tag 最多测几个源")
    p.add_argument("--cache", default="tilepipe.json")
    p.add_argument("--no-cache", action="store_true")
    p.add_argument("--out", default="out_tilepipe.json")
    p.set_defaults(func=cmd_tilepipe)

    p = sub.add_parser("sweep", help="多 PIP 叠加")
    p.add_argument("--dir", default="/opt/lzh/step03/sweep1")
    p.add_argument("--shard", default=None)
    p.add_argument("--cache", default="sweep_obs.json")
    p.add_argument("--no-cache", action="store_true")
    p.add_argument("--out", default="out_sweep.json")
    p.set_defaults(func=cmd_sweep)

    p = sub.add_parser("fam", help="追加一条 PIP（FAM）")
    p.add_argument("--dir", default="/opt/lzh/step03/fam")
    p.add_argument("--tile", default="INT_L_X6Y11")
    p.add_argument("--ref", default="ref.bit")
    p.add_argument("--shard", default=None)
    p.add_argument("--cache", default="famdiff.json")
    p.add_argument("--expected", default="_famexp.json")
    p.add_argument("--no-cache", action="store_true")
    p.add_argument("--out", default="out_fam.json")
    p.set_defaults(func=cmd_fam)

    p = sub.add_parser("merge", help="合并分片结果")
    p.add_argument("inputs", nargs="+")
    p.add_argument("--out", default="out_merged.json")
    p.set_defaults(func=cmd_merge)

    a = ap.parse_args(argv)
    return a.func(a)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
