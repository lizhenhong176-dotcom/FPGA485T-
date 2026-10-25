# -*- coding: utf-8 -*-
"""写位验证：在远端用我们的编码器改写 ref.bit，与 Vivado 的变体位流逐位比较。

对比范围：
  A. 10 帧窗口内的 word 0..49（配置位）——必须与 Vivado 完全一致；
  B. word 50（ECC）——统计有多少帧被 Vivado 重算，作为「手写位流需重算 ECC」的证据。
"""
import base64, gzip, json, os, struct, sys

DATA = json.loads(gzip.decompress(base64.b64decode("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")))
CELLS = DATA["cells"]      # "INT_L|IMUX_L7" -> {src: [[df,bit],...]}
DOMAIN = DATA["domain"]    # "INT_L|IMUX_L7" -> [[df,bit],...]
TAGS = DATA["tags"]        # tag -> mux
DIR = "/opt/lzh/step03/tilepipe"
SYNC = b"\xaa\x99\x55\x66"
FW = 101


def frames(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    if pos < 0:
        raise ValueError("no sync " + path)
    body = data[pos + 4:]
    n = len(body) // 4
    words = list(struct.unpack(">%dI" % n, body[:n * 4]))
    payload = []
    i = 0
    while i < len(words):
        h = words[i]; i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            k = h & 0x7FFFFFF
            payload.extend(words[i:i + k]); i += k; continue
        if typ != 1:
            break
        if op == 0:
            continue
        if op == 1:
            i += 1; continue
        if addr == 0x02:
            if cnt == 0:
                t2 = words[i]; i += 1
                k = t2 & 0x7FFFFFF
            else:
                k = cnt
            payload.extend(words[i:i + k]); i += k; continue
        i += cnt
    return [payload[k * FW:(k + 1) * FW] for k in range(len(payload) // FW)]


def fw(mux):
    lut = int("".join(ch for ch in mux if ch.isdigit()))
    return 22 + ((lut // 4) % 2)


def main():
    base = int(os.environ.get("BASE", "31696"))
    tags = TAGS
    ok = fail = 0
    ecc_frames = 0
    ecc_files = 0
    bad = []
    for tag, mux in sorted(tags.items()):
        ref = None
        refp = os.path.join(DIR, "ref_%s.bit" % tag)
        if not os.path.exists(refp):
            continue
        key = "INT_L|" + mux
        srcs = CELLS[key]
        w = fw(mux)
        for src, cells in srcs.items():
            vp = os.path.join(DIR, "v_%s_%s.bit" % (tag, src))
            if not os.path.exists(vp):
                continue
            if ref is None:
                ref = frames(refp)
            var = frames(vp)
            # 预测：ref 的该 mux 域清零 + 目标位置位
            pred = [list(f) for f in ref]
            for df, bit in DOMAIN[key]:
                pred[base + df][w] &= ~(1 << bit)
            for df, bit in cells:
                pred[base + df][w] |= 1 << bit
            diff_cfg = 0
            diff_ecc = 0
            for k in range(10):
                a, b = pred[base + k], var[base + k]
                for word in range(50):
                    if a[word] != b[word]:
                        diff_cfg += 1
                if a[50] != b[50]:
                    diff_ecc += 1
            if diff_cfg == 0:
                ok += 1
            else:
                fail += 1
                if len(bad) < 5:
                    bad.append((tag, src, diff_cfg))
            if diff_ecc:
                ecc_files += 1
                ecc_frames += diff_ecc
    print("config-word match: %d ok, %d fail" % (ok, fail))
    for b in bad:
        print("  mismatch", b)
    print("word50(ECC) differs in %d files / %d frames (说明改写位后 ECC 必须重算)" % (ecc_files, ecc_frames))


main()
