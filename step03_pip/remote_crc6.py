f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
payload = buf[338:PE]
REV = bytes(int(f"{i:08b}"[::-1], 2) for i in range(256))

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

def br(w):
    w = ((w & 0x55555555) << 1) | ((w >> 1) & 0x55555555)
    w = ((w & 0x33333333) << 2) | ((w >> 2) & 0x33333333)
    w = ((w & 0x0F0F0F0F) << 4) | ((w >> 4) & 0x0F0F0F0F)
    w = ((w & 0x00FF00FF) << 8) | ((w >> 8) & 0x00FF00FF)
    return ((w << 16) | (w >> 16)) & 0xFFFFFFFF

d_rev8 = payload.translate(REV)
cands = {"rev8": d_rev8, "raw": payload}
for name, data in cands.items():
    for msb in (True, False):
        t = TM if msb else TR
        for init, xo in ((0xFFFFFFFF, 0), (0xFFFFFFFF, 0xFFFFFFFF), (0, 0)):
            v = crc(data, t, msb, init, xo)
            v2 = br(v)
            print(name, "msb" if msb else "refl", hex(init), hex(xo), hex(v), hex(v2),
                  "MATCH" if v == target else "", "MATCHrev" if v2 == target else "")
