set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
D=/opt/lzh/v7re/work/e3; cd $D || exit 1
ls -1 *.bit
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
cat > diff_e3.py <<'PYEOF'
# -*- coding: utf-8 -*-
"""远端差分：按 Xilinx 包结构取 FDRI 数据 -> 50176 x 101 帧，逐字比较。
只回传 JSON，不回传 .bit。"""
import json, struct, sys, os

SYNC = b"\xaa\x99\x55\x66"
FRAME_WORDS = 101


def payload(path):
    raw = open(path, "rb").read()
    i = raw.find(SYNC)
    if i < 0:
        raise SystemExit("no sync in " + path)
    body = raw[i + 4:]
    words = struct.unpack(">%dI" % (len(body) // 4), body[: (len(body) // 4) * 4])
    out = []
    n = len(words)
    k = 0
    fdri = 0x0002
    while k < n:
        h = words[k]
        typ = (h >> 29) & 7
        op = (h >> 27) & 3
        addr = (h >> 13) & 0x3FFF
        cnt = h & 0x7FF
        k += 1
        if typ == 2:
            out.extend(words[k:k + cnt])
            k += cnt
            continue
        if typ != 1:
            continue
        if op == 1:          # READ：只有包头，无数据
            continue
        if op != 2:
            continue
        if cnt == 0:
            continue
        if addr == fdri:
            out.extend(words[k:k + cnt])
        k += cnt
    return out


def main():
    d = sys.argv[1] if len(sys.argv) > 1 else "."
    tags = sys.argv[2].split(",")
    base_tag = tags[0]
    base = payload(os.path.join(d, base_tag + ".bit"))
    nf = len(base) // FRAME_WORDS
    print(json.dumps({"base_frames": nf, "base_words": len(base)}), file=sys.stderr)
    res = {"frame_words": FRAME_WORDS, "frames": nf, "variants": {}}
    for tag in tags[1:]:
        w = payload(os.path.join(d, tag + ".bit"))
        if len(w) != len(base):
            res["variants"][tag] = {"error": "len %d != %d" % (len(w), len(base))}
            continue
        content = []          # (frame, word, bit) 非 word50
        ecc = {}              # frame -> [base_val, var_val]
        frames_touched = set()
        for idx in range(len(base)):
            a = base[idx]
            b = w[idx]
            if a == b:
                continue
            frame = idx // FRAME_WORDS
            word = idx % FRAME_WORDS
            frames_touched.add(frame)
            x = a ^ b
            bitlist = [bit for bit in range(32) if (x >> bit) & 1]
            if word == 50:
                ecc.setdefault(frame, [a, b])
            else:
                for bit in bitlist:
                    content.append([frame, word, bit])
        res["variants"][tag] = {
            "content_positions": content,
            "n_content": len(content),
            "ecc": {str(k): [v[0], v[1]] for k, v in sorted(ecc.items())},
            "frames_touched": sorted(frames_touched),
        }
        print("done", tag, "content", len(content), "eccframes", len(ecc), file=sys.stderr)
    print(json.dumps(res))


main()
PYEOF
$PY diff_e3.py . e3_base,e3_a,e3_b,e3_c,e3_d,e3_e 2>diff.err > diff.json
echo ERR_BEGIN; cat diff.err; echo ERR_END
echo E3DIFF_JSON_BEGIN
cat diff.json
echo E3DIFF_JSON_END
echo E3DONE
