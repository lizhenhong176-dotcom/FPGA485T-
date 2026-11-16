set -u
export LANG=C.UTF-8; export LC_ALL=C.UTF-8; unset LANGUAGE
cd /opt/lzh/v7re/work/e3 || exit 1
cat > probe.py <<'PYEOF'
import struct
raw = open("e3_base.bit", "rb").read()
i = raw.find(b"\xaa\x99\x55\x66")
print("file size", len(raw), "sync at", i)
body = raw[i + 4:]
n = len(body) // 4
words = struct.unpack(">%dI" % n, body[: n * 4])
print("words after sync", n)
k = 0
for _ in range(40):
    if k >= n:
        break
    h = words[k]
    typ = (h >> 29) & 7
    op = (h >> 27) & 3
    addr = (h >> 13) & 0x3FFF
    cnt11 = h & 0x7FF
    cnt27 = h & 0x7FFFFFF
    print("k=%7d h=0x%08X typ=%d op=%d addr=0x%04X cnt11=%d cnt27=%d" % (
        k, h, typ, op, addr, cnt11, cnt27))
    if typ == 2:
        k += 1 + cnt11
    elif typ == 1 and op == 2:
        k += 1 + cnt11
    else:
        k += 1
PYEOF
PY=/opt/lzh/venv/bin/python; [ -x $PY ] || PY=python3
$PY probe.py
echo E3DONE
