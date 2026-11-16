# -*- coding: utf-8 -*-
import base64, gzip, json, os, struct

DATA = json.loads(gzip.decompress(base64.b64decode("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")))
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
