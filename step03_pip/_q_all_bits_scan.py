"""全量活跃实例扫描：把本地所有 .bit 上每个活跃 INT tile 都过一遍 L1/L2 判据。

产出（供论文第 6 节引用）：
  - 活跃实例总数 n（去重到 (tile 名) 级别也一并给）
  - 参与解释的置位数 / 表外位（L1 未解释）
  - 槽位违例数（L2）
  - 零反例的 95% 上界 = 3/n
"""
import io
import json
import os
import sys
import glob

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPTS = os.path.join(HERE, "..", "v7re", "scripts")
sys.path.insert(0, os.path.abspath(SCRIPTS))

import numpy as np  # noqa: E402
import tamper_localize as tl  # noqa: E402

ROOT = os.path.abspath(os.path.join(HERE, ".."))
OUT = os.path.join(HERE, "out", "all_bits_scan.json")

PATTERNS = [
    os.path.join(ROOT, "*.bit"),
    os.path.join(ROOT, "tamper", "ref", "*.bit"),
    r"E:\v7work\*.bit",
    r"E:\v7work\**\*.bit",
]


def find_bits():
    seen, out = set(), []
    for pat in PATTERNS:
        for p in glob.glob(pat, recursive=True):
            ap = os.path.abspath(p)
            key = ap.lower()
            if key in seen:
                continue
            try:
                if os.path.getsize(ap) < 1_000_000:
                    continue
            except OSError:
                continue
            seen.add(key)
            out.append(ap)
    return sorted(out)


def main():
    print("loading world ...", flush=True)
    w = tl.World()
    files = find_bits()
    print(f"{len(files)} bitstreams", flush=True)

    rows = []
    tot_act = tot_bits = tot_out = tot_viol = 0
    tiles_seen = set()
    for path in files:
        name = os.path.basename(path)
        try:
            M = tl.load_bits(path)
        except Exception as e:  # noqa: BLE001
            rows.append({"file": name, "error": f"{type(e).__name__}: {e}"})
            print(f"  {name}: ERROR {e}", flush=True)
            continue
        if M is None:
            rows.append({"file": name, "error": "no frames"})
            continue
        act = w.active_tiles(M)
        out_bits = []
        viols = []
        nbits = 0
        for ti in act:
            un, obs, sel = w.explain(M, ti)
            nbits += len(obs)
            for (fo, b, par) in sorted(un):
                out_bits.append([w.tiles[ti][0], fo, b, par])
            for v in w.slot_violations(M, ti):
                viols.append([w.tiles[ti][0]] + list(v))
            tiles_seen.add(w.tiles[ti][0])
        rows.append({
            "file": name, "active_tiles": len(act), "set_bits": nbits,
            "unexplained": len(out_bits), "violations": len(viols),
            "unexplained_sample": out_bits[:8], "violation_sample": viols[:8],
        })
        tot_act += len(act)
        tot_bits += nbits
        tot_out += len(out_bits)
        tot_viol += len(viols)
        print(f"  {name}: tiles={len(act):5d} bits={nbits:7d} "
              f"unexpl={len(out_bits):3d} viol={len(viols):2d}", flush=True)

    n_unique = len(tiles_seen)
    res = {
        "bitstreams": len([r for r in rows if "error" not in r]),
        "errors": [r for r in rows if "error" in r],
        "active_tile_scans": tot_act,
        "unique_active_tiles": n_unique,
        "set_bits_scanned": tot_bits,
        "unexplained_bits": tot_out,
        "slot_violations": tot_viol,
        "rule_of_three_upper_bound_pct": round(300.0 / tot_act, 5) if tot_act else None,
        "per_file": rows,
    }
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    io.open(OUT, "w", encoding="utf-8").write(json.dumps(res, indent=1, ensure_ascii=False))
    print("\n=== SUMMARY ===")
    for k in ("bitstreams", "active_tile_scans", "unique_active_tiles",
              "set_bits_scanned", "unexplained_bits", "slot_violations",
              "rule_of_three_upper_bound_pct"):
        print(f"{k}: {res[k]}")
    print("json ->", OUT)


if __name__ == "__main__":
    main()
