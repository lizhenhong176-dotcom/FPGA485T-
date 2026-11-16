set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
cd /opt/lzh/v7re/work || exit 1
ls -d crcgen e3 2>/dev/null
cat > cmp_base.py <<'PYEOF'
import struct

def payload(path):
    raw = open(path, "rb").read()
    i = raw.find(b"\xaa\x99\x55\x66")
    body = raw[i + 4:]
    n = len(body) // 4
    w = struct.unpack(">%dI" % n, body[: n * 4])
    out = []
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
            continue
        if typ != 1 or op != 2 or cnt == 0:
            continue
        out.extend(w[k:k + cnt])
        k += cnt
    return out

a = payload("e3/e3_base.bit")
b = payload("crcgen/c_base.bit")
print("e3_base words", len(a), "c_base words", len(b))
if len(a) != len(b):
    print("LEN DIFF")
else:
    diff = [i for i in range(len(a)) if a[i] != b[i]]
    print("word diffs:", len(diff))
    for i in diff[:20]:
        print("  frame", i // 101, "word", i % 101, "e3=0x%08X cbase=0x%08X" % (a[i], b[i]))
PYEOF
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY cmp_base.py
echo E3DONE
