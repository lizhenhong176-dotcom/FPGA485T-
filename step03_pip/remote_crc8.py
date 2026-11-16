f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
payload = bytearray(buf[338:PE])
NF = len(payload) // 404
print("frames", NF, "len", len(payload))

def mk_refl(poly=0xEDB88320):
    t = []
    for i in range(256):
        c = i
        for _ in range(8):
            c = (c >> 1) ^ poly if c & 1 else c >> 1
        t.append(c)
    return t

def mk_msb(poly=0x04C11DB7):
    t = []
    for i in range(256):
        c = i << 24
        for _ in range(8):
            c = ((c << 1) ^ poly) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
        t.append(c)
    return t

TR = mk_refl(); TM = mk_msb()

def crc(data, t, msb, init=0xFFFFFFFF, xorout=0):
    c = init
    if msb:
        for b in data:
            c = ((c << 8) & 0xFFFFFFFF) ^ t[((c >> 24) ^ b) & 0xFF]
    else:
        for b in data:
            c = (c >> 8) ^ t[(c ^ b) & 0xFF]
    return c ^ xorout

# variant a: clear low 13 bits of word 50
a = bytearray(payload)
for i in range(NF):
    off = i * 404 + 200
    w = int.from_bytes(a[off:off+4], "big")
    w &= ~0x1FFF
    a[off:off+4] = w.to_bytes(4, "big")
# variant b: zero whole word 50
b = bytearray(payload)
for i in range(NF):
    off = i * 404 + 200
    b[off:off+4] = b"\x00\x00\x00\x00"

for name, data in (("ecc13_clear", bytes(a)), ("word50_zero", bytes(b))):
    for msb in (True, False):
        for xo in (0, 0xFFFFFFFF):
            v = crc(data, TM if msb else TR, msb, 0xFFFFFFFF, xo)
            print(name, "msb" if msb else "refl", hex(xo), hex(v), "MATCH" if v == target else "")
