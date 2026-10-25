# -*- coding: utf-8 -*-
"""生成「写位验证」远端 payload：把我们编码器预测的位与 Vivado 产出的 900 个变体逐位对比。

用法：
    python make_write_verify_payload.py       # 写出 _write_verify.py（自包含，可 stdin 送远端）
"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(HERE, "imux_cells.json")
DOMAIN = os.path.join(HERE, "imux_domain.json")
TILEPIPE = os.path.join(HERE, "tilepipe.json")
OUT = os.path.join(HERE, "_write_verify.py")

TPL = r'''# -*- coding: utf-8 -*-
"""写位验证：在远端用我们的编码器改写 ref.bit，与 Vivado 的变体位流逐位比较。

对比范围：
  A. 10 帧窗口内的 word 0..49（配置位）——必须与 Vivado 完全一致；
  B. word 50（ECC）——统计有多少帧被 Vivado 重算，作为「手写位流需重算 ECC」的证据。
"""
import base64, gzip, json, os, struct, sys

DATA = json.loads(gzip.decompress(base64.b64decode("__BLOB__")))
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
'''


def main():
    cells = {}
    for r in json.load(open(CELLS, encoding="utf-8")):
        if r["tile_type"] != "INT_L":
            continue
        key = "INT_L|" + r["mux"]
        d = cells.setdefault(key, {})
        if r["sense"]:
            d.setdefault(r["src_wire"], []).append([r["df"], r["bit"]])
        else:
            d.setdefault(r["src_wire"], [])
    domain = {}
    for k, v in json.load(open(DOMAIN, encoding="utf-8")).items():
        if k.startswith("INT_L|"):
            domain[k] = v
    tp = json.load(open(TILEPIPE, encoding="utf-8-sig"))
    tags = {tag: rec["sink"] for tag, rec in tp.items()}
    blob = base64.b64encode(gzip.compress(json.dumps(
        {"cells": cells, "domain": domain, "tags": tags}, separators=(",", ":")).encode(), 9)).decode()
    open(OUT, "w", encoding="utf-8", newline="\n").write(TPL.replace("__BLOB__", blob))
    print("wrote", OUT, os.path.getsize(OUT), "bytes; tags", len(tags))


if __name__ == "__main__":
    main()
