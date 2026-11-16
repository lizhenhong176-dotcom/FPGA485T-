"""G1：INT tile 内 108 条"特殊 PIP"（64 条 VCC 常量 + 44 条扇入=1 直通）的定性取证。

判据（四条独立证据，越多越硬）：
 E1 模板分组：216 个目的 wire → 172 个扇入>1（3,693 PIP）+ 44 个扇入=1（44 PIP）
 E2 VCC 只在扇入>1 的组里当"源"，且 law_cells 里 0 次出现
 E3 位池恒 1 检测：若直通/VCC 占位，则其位在任意活跃 tile 上必恒为 1；实测统计恒 1 位
 E4 已测位库 pip_bits 里是否出现过这些 PIP
输出：step03_pip/out/g1_special_pips.json
"""
import io
import json
import os
import sys
import collections

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, ".."))
sys.path.insert(0, os.path.join(ROOT, "v7re", "scripts"))

import numpy as np  # noqa: E402
import tamper_localize as tl  # noqa: E402

TPL = r"E:\v7work\_curated_20261021\routing\out_routing\templates\INT_L.json"
LAW = r"E:\v7work\model\v7_law.sqlite"
MODEL = r"E:\v7work\model\v7_model.sqlite"
OUT = os.path.join(HERE, "out", "g1_special_pips.json")
BITS = [os.path.join(ROOT, "tamper", "ref", "ref.bit")]


def main():
    d = json.load(io.open(TPL, encoding="utf-8"))
    pips = [(r[0], r[1]) for r in d["pip_defs"]]
    by_dst = collections.defaultdict(list)
    for src, dst in pips:
        by_dst[dst].append(src)

    multi = {k: v for k, v in by_dst.items() if len(v) > 1}
    single = {k: v for k, v in by_dst.items() if len(v) == 1}
    vcc_pips = [[s, dst] for dst, srcs in multi.items() for s in srcs
                if "VCC" in s.upper()]
    vcc_fams = sorted({dst for _, dst in vcc_pips})
    pass_pips = [[srcs[0], dst] for dst, srcs in single.items()]

    # E2：law_cells 里的 VCC 出现次数 / 含 VCC 的族的源数
    import sqlite3
    con = sqlite3.connect(LAW)
    cur = con.cursor()
    vcc_in_law = cur.execute(
        "SELECT count(*) FROM law_cells WHERE sense=1 AND src_wire LIKE '%VCC%'"
    ).fetchone()[0]
    fam_srcs = dict(cur.execute(
        "SELECT family, count(DISTINCT src_wire) FROM law_cells "
        "WHERE tile_type='INT_L' AND sense=1 GROUP BY family").fetchall())
    vcc_fam_srcs = {f: fam_srcs.get(f) for f in vcc_fams if f in fam_srcs}
    tpl_fanin_vcc = {f: len(multi[f]) for f in vcc_fams}
    tpl_fanin_novcc = {f: len([s for s in multi[f] if "VCC" not in s.upper()])
                       for f in vcc_fams}

    # E4：已测位库
    mc = sqlite3.connect(MODEL)
    mcur = mc.cursor()
    pb_vcc = mcur.execute(
        "SELECT count(*) FROM pip_bits WHERE wire_a LIKE '%VCC%' OR wire_b LIKE '%VCC%'"
    ).fetchone()[0]
    dst_set = set(single) | set(vcc_fams)
    pb_rows = mcur.execute("SELECT wire_a, wire_b FROM pip_bits").fetchall()
    pb_hit = [r for r in pb_rows if r[0] in dst_set or r[1] in dst_set]

    # E3：位池恒 1 检测（ref.bit 上所有活跃 tile，统计每个池格置位率）
    w = tl.World()
    M = tl.load_bits(BITS[0])
    act = w.active_tiles(M)
    cnt = np.zeros((tl.HI, 32, 2), dtype=np.int32)
    for ti in act:
        obs = w.observed(M, ti)
        for (fo, b, par) in obs:
            cnt[fo, b, par] += 1
    n_tiles = len(act)
    rate = cnt / max(n_tiles, 1)
    always = np.argwhere(rate >= 0.999)
    almost = np.argwhere(rate >= 0.90)
    present = np.argwhere(cnt > 0)

    res = {
        "template_pips": len(pips),
        "dst_wires": len(by_dst),
        "multi_dst": len(multi),
        "multi_pips": sum(len(v) for v in multi.values()),
        "single_dst": len(single),
        "single_pips": sum(len(v) for v in single.values()),
        "vcc_pips": len(vcc_pips),
        "vcc_families": len(vcc_fams),
        "vcc_in_law_cells": vcc_in_law,
        "vcc_family_law_sources": vcc_fam_srcs,
        "vcc_family_tpl_fanin_with_vcc": tpl_fanin_vcc,
        "vcc_family_tpl_fanin_without_vcc": tpl_fanin_novcc,
        "vcc_pip_list": vcc_pips,
        "passthrough_pips": pass_pips,
        "pip_bits_vcc_rows": pb_vcc,
        "pip_bits_rows_touching_special": len(pb_hit),
        "pip_bits_special_sample": pb_hit[:10],
        "ref_active_tiles": n_tiles,
        "pool_cells_ever_set": int(len(present)),
        "pool_cells_always_set": int(len(always)),
        "pool_cells_set_rate_ge_90": int(len(almost)),
        "always_set_cells": [[int(a), int(b), int(c)] for a, b, c in always],
        "set_rate_ge_90_cells": [[int(a), int(b), int(c), round(float(rate[a, b, c]), 4)]
                                 for a, b, c in almost],
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    io.open(OUT, "w", encoding="utf-8").write(json.dumps(res, indent=1, ensure_ascii=False))

    print("template pips           ", res["template_pips"])
    print("dst wires               ", res["dst_wires"])
    print("  multi (>1)            ", res["multi_dst"], "pips", res["multi_pips"])
    print("  single (=1)           ", res["single_dst"], "pips", res["single_pips"])
    print("VCC pips                ", res["vcc_pips"], "in", res["vcc_families"], "families")
    print("VCC in law_cells        ", res["vcc_in_law_cells"])
    print("pip_bits rows w/ VCC    ", res["pip_bits_vcc_rows"],
          "| rows touching special dst", res["pip_bits_rows_touching_special"])
    print("ref active tiles        ", n_tiles)
    print("pool cells ever set     ", res["pool_cells_ever_set"], "/", tl.HI * 32 * 2)
    print("pool cells always set   ", res["pool_cells_always_set"])
    print("pool cells rate>=0.90   ", res["pool_cells_set_rate_ge_90"])
    print("json ->", OUT)


if __name__ == "__main__":
    main()
