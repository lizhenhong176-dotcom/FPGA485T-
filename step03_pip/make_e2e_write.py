# -*- coding: utf-8 -*-
"""端到端写位测试：用我们的编码器改写 ref.bit（含 ECC），与 Vivado 的 v_*.bit 做逐字节比较。"""
import base64
import gzip
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))

SCRIPT = r'''# -*- coding: utf-8 -*-
import base64, gzip, json, os, struct

DATA = json.loads(gzip.decompress(base64.b64decode(__BLOB__)))
CELLS, DOMAIN, COL, TAGS = DATA["cells"], DATA["muxes"], DATA["col"], DATA["tags"]
DIR = "/opt/lzh/step03/tilepipe"
SYNC = b"\xaa\x99\x55\x66"
FW = 101
BASE = 31696


def parse(path):
    data = open(path, "rb").read()
    pos = data.find(SYNC)
    body = data[pos + 4:]
    n = len(body) // 4
    words = list(struct.unpack(">%dI" % n, body[:n * 4]))
    payload, i = [], 0
    while i < len(words):
        h = words[i]; i += 1
        typ, op, addr, cnt = (h >> 29) & 7, (h >> 27) & 3, (h >> 13) & 0x3FFF, h & 0x7FF
        if typ == 2:
            k = h & 0x7FFFFFF; payload.extend(words[i:i+k]); i += k; continue
        if typ != 1: break
        if op == 0: continue
        if op == 1: i += 1; continue
        if addr == 0x02:
            if cnt == 0:
                t2 = words[i]; i += 1; k = t2 & 0x7FFFFFF
            else:
                k = cnt
            payload.extend(words[i:i+k]); i += k; continue
        i += cnt
    return data, pos + 4, payload


def fw(mux):
    lut = int("".join(ch for ch in mux if ch.isdigit()))
    return 22 + ((lut // 4) % 2)


def bits(w):
    out = []
    while w:
        b = w & -w; out.append(b.bit_length()-1); w ^= b
    return out


def write_one(tag, src):
    data, off, payload = parse(os.path.join(DIR, "ref_%s.bit" % tag))
    frames = [payload[k*FW:(k+1)*FW] for k in range(len(payload)//FW)]
    old = [list(f) for f in frames]
    w = fw(TAGS[tag])
    for df, bit in DOMAIN[tag]:
        frames[BASE+df][w] &= ~(1 << bit)
    for df, bit in CELLS["%s|%s" % (tag, src)]:
        frames[BASE+df][w] |= 1 << bit
    for i, fr in enumerate(frames):
        if fr[:50] == old[i][:50]:
            continue
        syn = 0
        for ww in range(50):
            d = old[i][ww] ^ fr[ww]
            for bit in bits(d):
                syn ^= COL["%d:%d" % (ww, bit)]
        fr[50] = (fr[50] ^ syn) & 0x1FFF
    flat = b"".join(struct.pack(">I", x) for fr in frames for x in fr)
    ours = data[:off] + flat + data[off+len(flat):]
    ans, aoff, apay = parse(os.path.join(DIR, "v_%s_%s.bit" % (tag, src)))
    vfr = [apay[k*FW:(k+1)*FW] for k in range(len(apay)//FW)]
    if len(vfr) != len(frames):
        return "DIFF frame count %d vs %d" % (len(frames), len(vfr))
    for k in range(len(frames)):
        if list(frames[k]) == list(vfr[k]):
            continue
        for w in range(FW):
            d = frames[k][w] ^ vfr[k][w]
            if d:
                return "DIFF frame %d word %d xor 0x%08x" % (k, w, d)
    return "PAYLOAD-IDENTICAL"


ok = bad = 0
for tag in list(TAGS)[:6]:
    srcs = [k.split("|", 1)[1] for k in CELLS if k.startswith(tag + "|")]
    srcs = srcs[:2] + srcs[-1:]
    for src in srcs:
        r = write_one(tag, src)
        print("%-30s %-18s %s" % (tag, src, r))
        ok += r == "PAYLOAD-IDENTICAL"; bad += r != "PAYLOAD-IDENTICAL"
print("BYTE-IDENTICAL %d/%d" % (ok, ok+bad))
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/tilepipe"
open(os.path.join(R, "e2e_write.py"), "wb").write(gzip.decompress(base64.b64decode("__BLOB__")))
p = subprocess.run(["/usr/bin/python3", os.path.join(R, "e2e_write.py")], capture_output=True, text=True)
print(p.stdout[-4000:]); print("ERR", p.stderr[-1500:])
'''


def main():
    cells_raw = json.load(open(os.path.join(HERE, "imux_cells.json"), encoding="utf-8"))
    dom_raw = json.load(open(os.path.join(HERE, "imux_domain.json"), encoding="utf-8"))
    tp = json.load(open(os.path.join(HERE, "tilepipe.json"), encoding="utf-8-sig"))
    tags = {tag: rec["sink"] for tag, rec in tp.items()}
    out_cells, dom = {}, {}
    for tag, mux in tags.items():
        dom[tag] = dom_raw["INT_L|" + mux]
        for r in cells_raw:
            if r["tile_type"] != "INT_L" or r["mux"] != mux:
                continue
            out_cells.setdefault("%s|%s" % (tag, r["src_wire"]), [])
            if r["sense"]:
                out_cells["%s|%s" % (tag, r["src_wire"])].append([r["df"], r["bit"]])
    col = json.load(open(os.path.join(HERE, "ecc_table.json"), encoding="utf-8"))
    payload = gzip.compress(json.dumps({"cells": out_cells, "muxes": dom, "col": col, "tags": tags},
                                       separators=(",", ":")).encode(), 9)
    inner = SCRIPT.replace("__BLOB__", '"' + base64.b64encode(payload).decode() + '"')
    blob = base64.b64encode(gzip.compress(inner.encode(), 9))
    out = os.path.join(HERE, "_e2e_write.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob.decode()))
    print("wrote", out, os.path.getsize(out), "tags", len(tags), "cells", len(out_cells))


if __name__ == "__main__":
    main()
