f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
payload = buf[338:PE]

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

swap16 = bytearray(payload)
swap16[0::2], swap16[1::2] = payload[1::2], payload[0::2]
cands = {"swap16": bytes(swap16), "backward": payload[::-1]}
for name, data in cands.items():
    for msb in (True, False):
        t = TM if msb else TR
        for init, xo in ((0xFFFFFFFF, 0), (0xFFFFFFFF, 0xFFFFFFFF), (0, 0)):
            v = crc(data, t, msb, init, xo)
            print(name, "msb" if msb else "refl", hex(init), hex(xo), hex(v), "MATCH" if v == target else "")
