#!/usr/bin/env python3
"""gen_tilegrid_bits.py — 用地址律批量填 V7 tilegrid.json 的 bits 字段。

对 INT_L/INT_R/CLBLL_L/CLBLL_R/CLBLM_L/CLBLM_R 六类 tile，从名字解析
(col, Y)，用 pip_law 的 block_start 律算列基址帧、_word 律算 offset，
反查 frame_index_far.csv 得 FAR(baseaddr)。

约定（artix7-native，让 artix7 segbits 库直接可复用）：
  INT:  baseaddr=FAR(block_start), frames=28, offset=_word(Y,0), words=2
  CLB:  baseaddr=FAR(block_start), frames=36, offset=_word(Y,0), words=2

用法:
  python gen_tilegrid_bits.py <input_tilegrid.json> <output_tilegrid.json> [--far-csv path]
"""
import csv, json, os, re, sys, collections, argparse

HERE = os.path.dirname(os.path.abspath(__file__))
PROJ = os.path.dirname(HERE)
FAR_CSV_DEFAULT = os.path.join(PROJ, "phaseA", "frame_index_far.csv")

ROW_FRAMES = 5246
BAND_ROWS = 50
BAND_BY_REGION = [6, 5, 0, 1, 2, 3, 4]
N_BANDS = 7

CLB_TYPES = ("CLBLL_L", "CLBLL_R", "CLBLM_L", "CLBLM_R")
INT_TYPES = ("INT_L", "INT_R")
FILL_TYPES = CLB_TYPES + INT_TYPES
FRAMES_BY_TYPE = {**{t: 28 for t in INT_TYPES}, **{t: 36 for t in CLB_TYPES}}

_TILE_RE = re.compile(r"_X(\d+)Y(\d+)$")


def load_prefix(csv_path):
    by_band = collections.defaultdict(dict)
    with open(csv_path, newline="", encoding="utf-8") as fh:
        for r in csv.DictReader(fh):
            row = int(r["row"])
            band = row - 1
            if band < 0 or band >= N_BANDS:
                continue
            ba = int(r["block_addr"], 16)
            col = (((ba >> 14) & 1) << 7) | ((ba >> 7) & 0x7F)  # half×128 + col_local = tile X (0..153)
            fi = int(r["frame_index"])
            e = by_band[band].setdefault(col, [fi, fi])
            e[0] = min(e[0], fi)
            e[1] = max(e[1], fi)
    starts = {}
    for band, cols in by_band.items():
        starts[band] = {c: cols[c][0] for c in sorted(cols)}
    return starts


def load_far_map(csv_path):
    fi2far = {}
    with open(csv_path, newline="", encoding="utf-8") as fh:
        for r in csv.DictReader(fh):
            fi2far[int(r["frame_index"])] = int(r["far"], 16)
    return fi2far


def word_offset(y):
    w = 2 * (y % BAND_ROWS)
    return w + 1 if w >= 50 else w


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("input")
    ap.add_argument("output")
    ap.add_argument("--far-csv", default=FAR_CSV_DEFAULT)
    ap.add_argument("--validate-only", action="store_true")
    args = ap.parse_args()

    starts = load_prefix(args.far_csv)
    fi2far = load_far_map(args.far_csv)

    with open(args.input, encoding="utf-8") as fh:
        tg = json.load(fh)
    print("Loaded tilegrid: %d tiles" % len(tg))

    filled = collections.Counter()
    skipped_missing = collections.Counter()
    skipped_type = collections.Counter()
    anchors = {
        "CLBLL_L_X6Y10":   ("0x00420300", 20, 36),
        "CLBLM_R_X7Y10":   ("0x00420380", 20, 36),
        "CLBLL_L_X10Y303": ("0x00080500",  6, 36),
    }
    anchor_ok = 0; anchor_fail = []

    for name, entry in tg.items():
        m = _TILE_RE.search(name)
        if not m:
            continue
        ttype = entry.get("type", "")
        if ttype not in FILL_TYPES:
            continue
        col, y = int(m.group(1)), int(m.group(2))
        region = y // BAND_ROWS
        if region >= len(BAND_BY_REGION):
            skipped_missing[ttype] += 1
            continue
        band = BAND_BY_REGION[region]
        if band not in starts or col not in starts[band]:
            skipped_missing[ttype] += 1
            continue
        base_fi = starts[band][col]
        if base_fi not in fi2far:
            skipped_missing[ttype] += 1
            continue
        baseaddr = fi2far[base_fi]
        frames = FRAMES_BY_TYPE[ttype]
        offset = word_offset(y)
        bits = {"CLB_IO_CLK": {
            "baseaddr": "0x%08X" % baseaddr,
            "frames": frames,
            "offset": offset,
            "words": 2,
        }}

        if name in anchors:
            want_addr, want_off, want_frames = anchors[name]
            got_addr = "0x%08X" % baseaddr
            if got_addr == want_addr and offset == want_off and frames == want_frames:
                anchor_ok += 1
            else:
                anchor_fail.append((name, got_addr, offset, frames, want_addr, want_off, want_frames))

        if not args.validate_only:
            entry["bits"] = bits
        filled[ttype] += 1

    print("\n=== 填充结果 ===")
    for t in FILL_TYPES:
        print("  %-9s filled=%-6d missing=%d" % (t, filled[t], skipped_missing[t]))
    total_filled = sum(filled.values())
    total_miss = sum(skipped_missing.values())
    print("  合计 filled=%d  missing=%d  (%.1f%% of %d)" % (
        total_filled, total_miss, 100.0 * total_filled / len(tg), len(tg)))

    print("\n=== 锚点验证 ===")
    print("  %d/%d OK" % (anchor_ok, len(anchors)))
    if anchor_fail:
        for f in anchor_fail:
            print("  FAIL %s: got %s off=%d fr=%d, want %s off=%d fr=%d" % f)

    # offset 合理性检查
    if not args.validate_only:
        offsets = [word_offset(y) for name, e in tg.items()
                   if _TILE_RE.search(name) and e.get("type") in FILL_TYPES
                   for y in [int(_TILE_RE.search(name).group(2))]]
        print("\n=== offset 分布 ===")
        print("  min=%d max=%d" % (min(offsets), max(offsets)))

    if not args.validate_only and anchor_ok == len(anchors):
        with open(args.output, "w", encoding="utf-8") as fh:
            json.dump(tg, fh, separators=(",", ":"), ensure_ascii=False)
        sz = os.path.getsize(args.output)
        print("\n=== 输出 ===")
        print("  %s  (%.1f MB)" % (args.output, sz / 1e6))
        # 抽样
        for probe in ["INT_L_X6Y11", "INT_R_X7Y10", "CLBLL_L_X6Y10",
                       "CLBLM_R_X7Y10", "CLBLL_L_X10Y303", "CLBLM_L_X8Y11"]:
            if probe in tg:
                print("  %-22s %s" % (probe, json.dumps(tg[probe].get("bits"), separators=(",", ":"))))

    return 0 if anchor_ok == len(anchors) else 1


if __name__ == "__main__":
    sys.exit(main())
