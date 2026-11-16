#!/usr/bin/env python3
"""bit2fasm_py.py — 纯 Python bit→FASM 解码器（替代 prjxray 的 bitread+bit2fasm）。

原料：
  .bit 文件        → 解析出 50,176 帧 × 101 字
  frame_index_far.csv → frame_index → FAR 地址映射
  tilegrid.json (filled) → tile → baseaddr/frames/offset/words
  segbits_*.db     → tile_type → feature → [(col, bitidx, is_set), ...]

算法：
  1. 解析 .bit → frames[frame_index] = [101 words]
  2. 建 FAR → frame_index 反查表（从 CSV）
  3. 对每个有 bits 的 tile：
     a. 收集该 tile 范围内所有置位 (col, bitidx)
     b. 用 segbits 反查 → 只检查引用了这些位的 feature
     c. 全部 spec 匹配（set 位置 1、clear 位置 0）→ 输出 FASM 行
  4. 未匹配的置位 → unknown_bit 行（到 stderr）

用法：
  python3 bit2fasm_py.py input.bit -t tilegrid.json -s segbits_dir/ -f frame_index_far.csv > out.fasm

无外部依赖（纯标准库）。
"""
from __future__ import annotations
import sys, os, json, csv, struct, re, argparse
from collections import defaultdict

# ───────────────────────────── V7 极性修正
# artix7 segbits 的极性对 V7 大多数特征一致，但 ZINI 反转：
#   artix7: ZINI bit=1 → INIT=1   V7: ZINI bit=1 → INIT=0
#   详见 CLB_VERIFY.md。
# 注意：不能在 segbits 层面翻转 ZINI，因为未配置 tile 的 ZINI 位也 CLEAR，
# 翻转后会对每个 tile 的每个 FF 都发射 ZINI。极性修正在 fasm_to_rw.py 做。
V7_INVERTED_FEATURES = {"ZINI"}  # 这些特征在 V7 极性反转，fasm_to_rw 需处理

# ───────────────────────────── 比特流解析（内联，不依赖 v7re）
SYNC = b"\xAA\x99\x55\x66"
FRAME_WORDS = 101  # V7 485T

def parse_bit_frames(path):
    """返回 list[list[int]]：50,176 帧 × 101 字。"""
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    if pos < 0:
        raise ValueError("sync word not found")
    words = list(struct.unpack(">%dI" % ((len(data) - pos - 4) // 4), data[pos + 4:]))
    payload = []
    i = 0
    while i < len(words):
        h = words[i]; i += 1
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF

        if typ == 2:
            n = h & 0x07FFFFFF
            payload.extend(words[i:i + n])
            i += n
            continue
        if typ != 1:
            break
        if op == 0:  # NOP
            continue
        if op == 1:  # READ: skip 1 word
            i += 1
            continue
        # op == 2: WRITE
        if addr == 0x02:  # FDRI
            if cnt == 0:
                # Type 2 packet follows
                t2 = words[i]; i += 1
                if ((t2 >> 29) & 7) != 2:
                    raise ValueError("expected Type 2 packet: 0x%08X" % t2)
                n = t2 & 0x07FFFFFF
                payload.extend(words[i:i + n])
                i += n
            else:
                payload.extend(words[i:i + cnt])
                i += cnt
        else:
            i += cnt
    n_frames = len(payload) // FRAME_WORDS
    return [payload[k * FRAME_WORDS:(k + 1) * FRAME_WORDS] for k in range(n_frames)]


# ───────────────────────────── FAR CSV
def load_far_csv(path):
    """返回 {far_int: frame_index}。"""
    m = {}
    with open(path, newline="") as f:
        for r in csv.DictReader(f):
            fi = int(r["frame_index"])
            far = int(r["far"], 16)
            m[far] = fi
    return m


# ───────────────────────────── segbits
def load_segbits(segbits_dir):
    """返回 {tile_type: [(feature, [(col, bitidx, is_set), ...]), ...]}。
    也返回反向索引 {(tile_type, col, bitidx): set(feature)}。"""
    table = defaultdict(list)           # tile_type → [(feature, specs)]
    reverse = defaultdict(set)          # (tile_type, col, bitidx) → {feature}
    pat = re.compile(r'^(!?)(\d+)_(\d+)$')
    for fn in os.listdir(segbits_dir):
        if not fn.startswith("segbits_") or not fn.endswith(".db"):
            continue
        ttype = fn[len("segbits_"):-len(".db")].upper()  # INT_L, CLBLL_L, ...
        for ln in open(os.path.join(segbits_dir, fn), encoding="utf-8", errors="replace"):
            ln = ln.strip()
            if not ln or ln.startswith("#"):
                continue
            parts = ln.split()
            feature = parts[0]
            specs = []
            for tok in parts[1:]:
                m = pat.match(tok)
                if not m:
                    continue
                is_set = not m.group(1)
                col = int(m.group(2))
                bitidx = int(m.group(3))
                specs.append((col, bitidx, is_set))
                reverse[(ttype, col, bitidx)].add(feature)
            if specs:
                table[ttype].append((feature, specs))
    return table, reverse


# ───────────────────────────── 主解码
def decode(bit_path, tilegrid_path, segbits_dir, far_csv_path):
    print("# bit2fasm_py: parsing bitstream...", file=sys.stderr)
    frames = parse_bit_frames(bit_path)
    n_frames = len(frames)
    print("#  frames: %d" % n_frames, file=sys.stderr)

    print("# loading FAR CSV...", file=sys.stderr)
    far2fi = load_far_csv(far_csv_path)
    fi_by_far = {}
    for far, fi in far2fi.items():
        if fi < n_frames:
            fi_by_far[far] = fi
    print("#  FAR entries: %d (within bitstream: %d)" % (len(far2fi), len(fi_by_far)), file=sys.stderr)

    print("# loading tilegrid...", file=sys.stderr)
    tg = json.load(open(tilegrid_path))
    tiles_with_bits = sum(1 for v in tg.values() if v.get("bits"))
    print("#  tiles: %d (with bits: %d)" % (len(tg), tiles_with_bits), file=sys.stderr)

    print("# loading segbits...", file=sys.stderr)
    seg_table, seg_reverse = load_segbits(segbits_dir)
    print("#  tile types: %s" % ", ".join(sorted(seg_table.keys())), file=sys.stderr)

    n_features = 0
    n_unknown = 0
    n_tiles_decoded = 0

    for tile_name, info in sorted(tg.items()):
        bits = info.get("bits", {}).get("CLB_IO_CLK")
        if not bits:
            continue
        ttype = info.get("type", "")
        if ttype not in seg_table:
            continue

        baseaddr = int(bits["baseaddr"], 16)
        n_frames_tile = bits["frames"]
        offset = bits["offset"]
        words = bits["words"]

        # 收集置位: {(col, bitidx): True}
        set_bits = set()
        for col in range(n_frames_tile):
            far = baseaddr + col
            fi = fi_by_far.get(far)
            if fi is None:
                continue
            frame = frames[fi]
            for rw in range(words):
                aw = offset + rw
                if aw >= len(frame):
                    break
                wval = frame[aw]
                if wval == 0:
                    continue
                bitidx_base = rw * 32
                for b in range(32):
                    if wval & (1 << b):
                        set_bits.add((col, bitidx_base + b))

        if not set_bits:
            continue

        # 候选 feature：引用了任意一个置位的 feature
        candidates = set()
        for (col, bitidx) in set_bits:
            candidates.update(seg_reverse.get((ttype, col, bitidx), set()))

        if not candidates:
            # 所有置位都是 unknown
            for (col, bitidx) in sorted(set_bits):
                far = baseaddr + col
                aw = offset + bitidx // 32
                bit = bitidx % 32
                print("# unknown_bit = \"%08x_%03d_%d\"" % (far, aw, bit), file=sys.stderr)
                n_unknown += 1
            continue

        # 检查每个候选 feature
        feature_table = dict(seg_table[ttype])
        matched = []
        for feat_name in sorted(candidates):
            specs = feature_table.get(feat_name)
            if specs is None:
                continue
            ok = True
            for (col, bitidx, is_set) in specs:
                present = (col, bitidx) in set_bits
                if is_set and not present:
                    ok = False; break
                if not is_set and present:
                    ok = False; break
            if ok:
                matched.append(feat_name)

        # 输出 FASM
        for feat in matched:
            # FASM 行格式：TILE_NAME.FEATURE（去掉 tile_type 前缀，加 tile_name）
            # segbits 里 feature = "INT_L.IMUX_L0.NR1END0"
            # FASM 输出 = "INT_L_X6Y11.IMUX_L0.NR1END0"
            parts = feat.split(".", 1)
            if len(parts) == 2:
                print("%s.%s" % (tile_name, parts[1]))
            else:
                print("%s.%s" % (tile_name, feat))
            n_features += 1

        # 未匹配的置位 → unknown
        matched_bits = set()
        for feat_name in matched:
            specs = feature_table.get(feat_name, [])
            for (col, bitidx, is_set) in specs:
                if is_set:
                    matched_bits.add((col, bitidx))
        for (col, bitidx) in sorted(set_bits - matched_bits):
            far = baseaddr + col
            aw = offset + bitidx // 32
            bit = bitidx % 32
            print("# unknown_bit = \"%08x_%03d_%d\"" % (far, aw, bit), file=sys.stderr)
            n_unknown += 1

        n_tiles_decoded += 1

    print("# === DONE: %d features, %d unknown bits, %d tiles decoded ===" % (
        n_features, n_unknown, n_tiles_decoded), file=sys.stderr)


def main():
    ap = argparse.ArgumentParser(description="Pure Python bit→FASM decoder")
    ap.add_argument("bitfile")
    ap.add_argument("-t", "--tilegrid", required=True)
    ap.add_argument("-s", "--segbits-dir", required=True)
    ap.add_argument("-f", "--far-csv", required=True)
    args = ap.parse_args()
    decode(args.bitfile, args.tilegrid, args.segbits_dir, args.far_csv)

if __name__ == "__main__":
    main()
