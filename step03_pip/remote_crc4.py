import struct
f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
payload = buf[338:PE]

def mk_refl(poly):
    t = []
    for i in range(256):
        c = i
        for _ in range(8):
            c = (c >> 1) ^ poly if c & 1 else c >> 1
        t.append(c)
    return t

def mk_msb(poly):
    t = []
    for i in range(256):
        c = i << 24
        for _ in range(8):
            c = ((c << 1) ^ poly) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
        t.append(c)
    return t

def crc(data, t, msb, init, xorout):
    c = init
    if msb:
        for b in data:
            c = ((c << 8) & 0xFFFFFFFF) ^ t[((c >> 24) ^ b) & 0xFF]
    else:
        for b in data:
            c = (c >> 8) ^ t[(c ^ b) & 0xFF]
    return c ^ xorout

polys = [0x04C11DB7, 0x1EDC6F41, 0x741B8CD7, 0xA833982B, 0x814141AB, 0x000000AF, 0xF4ACFB13]
for poly in polys:
    for msb in (True, False):
        t = mk_msb(poly) if msb else mk_refl(poly if not msb else poly)
        if not msb:
            rp = 0
            p = poly
            for i in range(32):
                rp = (rp << 1) | (p & 1)
                p >>= 1
            t = mk_refl(rp)
        for init, xo in ((0xFFFFFFFF, 0), (0xFFFFFFFF, 0xFFFFFFFF), (0, 0)):
            v = crc(payload, t, msb, init, xo)
            print(hex(poly), "msb" if msb else "refl", hex(init), hex(xo), hex(v), "MATCH" if v == target else "")
