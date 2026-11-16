set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
D=/opt/lzh/v7re/work/e4
cd $D || exit 1
ls -l *.bit | head -20

cat > diff_fix.py <<'PYEOF'
# -*- coding: utf-8 -*-
import json, struct, sys

SYNC = b"\xaa\x99\x55\x66"
FW = 101


def fdraws(path):
    """只取 Type2（FDRI）写包的数据字，返回 (words, stats)。"""
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync " + path)
    body = raw[i + 4:]
    n = len(body) // 4
    w = struct.unpack(">%dI" % n, body[: n * 4])
    out = []
    stats = {"typ1_data_words": 0, "typ2_packets": 0, "typ1_write_pkts": 0}
    k = 0
    while k < n:
        h = w[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            c = h & 0x7FFFFFF
            out.extend(w[k:k + c])
            k += c
            stats["typ2_packets"] += 1
            continue
        if typ != 1:
            continue
        if op == 2:
            stats["typ1_write_pkts"] += 1
            if cnt == 0:
                continue
            stats["typ1_data_words"] += cnt
            k += cnt
        elif op == 1:
            k += 1
    return out, stats


def main():
    d = sys.argv[1]
    pairs = sys.argv[2].split(",")
    cache = {}

    def get(tag):
        if tag not in cache:
            cache[tag] = fdraws(d + "/" + tag + ".bit")
        return cache[tag]

    res = {"variants": {}, "file_stats": {}}
    for tag in sys.argv[3].split(","):
        wds, st = get(tag)
        res["file_stats"][tag] = {
            "words": len(wds),
            "frames": len(wds) // FW,
            "rem": len(wds) % FW,
            "typ1_data_words": st["typ1_data_words"],
            "typ2_packets": st["typ2_packets"],
            "typ1_write_pkts": st["typ1_write_pkts"],
        }

    for p in pairs:
        base_tag, var_tag = p.split(":")
        a = get(base_tag)[0]
        b = get(var_tag)[0]
        if len(a) != len(b):
            res["variants"][var_tag] = {"error": "len %d vs %d" % (len(a), len(b))}
            continue
        content, ecc, frames = [], {}, set()
        for idx in range(len(a)):
            if a[idx] == b[idx]:
                continue
            fr, wd = idx // FW, idx % FW
            frames.add(fr)
            if wd == 50:
                ecc.setdefault(fr, [a[idx], b[idx]])
            else:
                x = a[idx] ^ b[idx]
                for bit in range(32):
                    if (x >> bit) & 1:
                        content.append([fr, wd, bit])
        res["variants"][var_tag] = {
            "base": base_tag,
            "content_positions": content,
            "n_content": len(content),
            "ecc": {str(k): v for k, v in sorted(ecc.items())},
            "frames_touched": sorted(frames),
        }
        print("done", var_tag, "content", len(content), "ecc", len(ecc), file=sys.stderr)
    print(json.dumps(res))


main()
PYEOF

PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
TAGS=e4_y4_b,e4_y4_1,e4_y4_3,e4_y5_b,e4_y5_1,e4_y6_b,e4_y6_1,e4_y7_b,e4_y7_1
PAIRS=e4_y4_b:e4_y4_1,e4_y4_b:e4_y4_3,e4_y5_b:e4_y5_1,e4_y6_b:e4_y6_1,e4_y7_b:e4_y7_1
$PY diff_fix.py . "$PAIRS" "$TAGS" 2>diff2.err > diff2.json
echo ERR_BEGIN; cat diff2.err; echo ERR_END
echo E4DIFF2_BEGIN
cat diff2.json
echo E4DIFF2_END
echo E4FIXDONE
