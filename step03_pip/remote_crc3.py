import struct
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

def crc(data, msb, init=0xFFFFFFFF, xorout=0):
    c = init
    if msb:
        for b in data:
            c = ((c << 8) & 0xFFFFFFFF) ^ TM[((c >> 24) ^ b) & 0xFF]
    else:
        for b in data:
            c = (c >> 8) ^ TR[(c ^ b) & 0xFF]
    return c ^ xorout

def bitrev32(w):
    w = ((w & 0x55555555) << 1) | ((w >> 1) & 0x55555555)
    w = ((w & 0x33333333) << 2) | ((w >> 2) & 0x33333333)
    w = ((w & 0x0F0F0F0F) << 4) | ((w >> 4) & 0x0F0F0F0F)
    w = ((w & 0x00FF00FF) << 8) | ((w >> 8) & 0x00FF00FF)
    return ((w << 16) | (w >> 16)) & 0xFFFFFFFF

words = [struct.unpack(">I", payload[i:i+4])[0] for i in range(0, len(payload), 4)]
print("words", len(words))
cands = {}
cands["be"] = payload
cands["le_words"] = b"".join(struct.pack("<I", w) for w in words)
cands["bitrev_words"] = b"".join(struct.pack(">I", bitrev32(w)) for w in words)
# skip ECC word (last of each 101) - frame content: 101 words per frame
data_wo_ecc = b"".join(payload[i*404:i*404+400] for i in range(len(payload)//404))
cands["no_ecc_word"] = data_wo_ecc
for name, data in cands.items():
    for msb in (True, False):
        for xo in (0, 0xFFFFFFFF):
            v = crc(data, msb, xorout=xo)
            tag = "MATCH" if v == target else ""
            print(name, "msb" if msb else "refl", hex(xo), hex(v), tag)
