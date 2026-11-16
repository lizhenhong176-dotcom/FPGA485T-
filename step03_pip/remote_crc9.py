f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
payload = buf[338:PE]
NF = len(payload) // 404
frames = [payload[i*404:(i+1)*404] for i in range(NF)]

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

def rev_words(fr):
    ws = [fr[i:i+4] for i in range(0, 404, 4)]
    return b"".join(reversed(ws))

v1 = b"".join(rev_words(fr) for fr in frames)
v2 = b"".join(reversed(frames))
v3 = b"".join(rev_words(fr) for fr in reversed(frames))
for name, data in (("words_rev", v1), ("frames_rev", v2), ("both_rev", v3)):
    for msb in (True, False):
        for xo in (0, 0xFFFFFFFF):
            v = crc(data, TM if msb else TR, msb, 0xFFFFFFFF, xo)
            print(name, "msb" if msb else "refl", hex(xo), hex(v), "MATCH" if v == target else "")
