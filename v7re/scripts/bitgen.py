#!/usr/bin/env python3
"""bitgen.py —— 在 .bit 文件里按位改写，并同步重算帧级 ECC。

改动以「(frame, word, bit) → 0/1」给出；写回时：
  * 数据位按清单改动；
  * 受影响帧的 word50 低 13 位按 ECC 模型 XOR 修正（`ecc_model.json`），
    高位置（marker）原样保留 —— 见 STATUS §34；
  * 未知位置（模型里没有 L[p]）直接报错，不做猜测。

用法：
    python bitgen.py --in _c0.bit --out out.bit --set '31750:20:15=0'
    python bitgen.py --in _c0.bit --out out.bit --set-file changes.json
"""
import argparse
import json
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, ROOT)

SYNC = b"\xAA\x99\x55\x66"
FAR, FDRI, CMD = 0x01, 0x02, 0x04
FRAME_WORDS = 101
ECC_WORD = 50
NEXC = 32


def load_words(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    if pos < 0:
        raise SystemExit("找不到 sync 字")
    n = (len(data) - pos - 4) // 4
    words = list(struct.unpack(">%dI" % n, data[pos + 4:pos + 4 + 4 * n]))
    return data, pos, words


def payload_word_offset(words):
    """返回 payload 在 words 中的起始下标（即 FDRI 突发第一个 payload 字）。"""
    i = 0
    while i < len(words):
        header = words[i]
        i += 1
        typ = (header >> 29) & 0x7
        op = (header >> 27) & 0x3
        addr = (header >> 13) & 0x3FFF
        cnt = header & 0x7FF
        if typ == 2:
            return i
        if typ != 1:
            raise SystemExit("遇到非 Type1 包: 0x%08X" % header)
        if op == 0:
            continue
        if op == 1:
            i += 1
            continue
        if addr == FDRI:
            if cnt == 0:
                return i + 1          # 跳过 Type2 头
            return i
        i += cnt
    raise SystemExit("未找到 FDRI 包")


def load_ecc(bit_dir):
    with open(os.path.join(ROOT, "steps", "ecc_model.json"), encoding="utf-8") as fh:
        m = json.load(fh)
    return {int(k): v for k, v in m["positions"].items()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="src", required=True)
    ap.add_argument("--out", dest="dst", required=True)
    ap.add_argument("--set", action="append", default=[],
                    help="frame:word:bit=0/1")
    ap.add_argument("--set-file", default=None, help="JSON: [[frame,word,bit,value],...]")
    ap.add_argument("--ecc", default=None, help="ecc_model.json 路径")
    a = ap.parse_args()

    changes = []
    for spec in a.set:
        pos, val = spec.split("=")
        f, w, b = (int(x) for x in pos.split(":"))
        changes.append((f, w, b, int(val)))
    if a.set_file:
        changes.extend(tuple(x) for x in json.load(open(a.set_file, encoding="utf-8")))

    from bitstream.parser import parse_bit
    bs = parse_bit(a.src)
    data, sync_pos, words = load_words(a.src)
    poff = payload_word_offset(words)
    nframes = len(bs.payload_words) // FRAME_WORDS

    def word_index(frame, word):
        return poff + frame * FRAME_WORDS + word

    # 记录每帧的数据改动位置
    per_frame = {}
    for f, w, b, v in changes:
        if w == ECC_WORD:
            raise SystemExit("不允许直接改 word 50")
        if f >= nframes:
            raise SystemExit("帧号超范围: %d (共 %d)" % (f, nframes))
        cur = (words[word_index(f, w)] >> b) & 1
        if cur == v:
            continue
        words[word_index(f, w)] ^= (1 << b)
        per_frame.setdefault(f, set()).add(w * NEXC + b)

    ecc = load_ecc(ROOT) if os.path.exists(os.path.join(ROOT, "steps", "ecc_model.json")) else {}
    if a.ecc:
        ecc = {int(k): v for k, v in json.load(open(a.ecc, encoding="utf-8"))["positions"].items()}

    for f, positions in sorted(per_frame.items()):
        delta = 0
        unknown = [p for p in positions if p not in ecc]
        if unknown:
            raise SystemExit("帧 %d 有未知位置 %s，无 ECC 模型，拒绝写入"
                             % (f, [(p // NEXC, p % NEXC) for p in unknown]))
        for p in positions:
            delta ^= ecc[p]
        wi = word_index(f, ECC_WORD)
        old = words[wi]
        words[wi] = (old & ~0x1FFF) | ((old & 0x1FFF) ^ delta)

    out = bytearray(data)
    out[sync_pos + 4:sync_pos + 4 + 4 * len(words)] = struct.pack(">%dI" % len(words), *words)
    open(a.dst, "wb").write(bytes(out))
    print("写出 %s：改动 %d 位，影响 %d 帧" % (a.dst, len(changes), len(per_frame)))


if __name__ == "__main__":
    main()
