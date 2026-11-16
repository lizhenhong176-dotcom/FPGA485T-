import struct
f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = bytearray(open(f, "rb").read())
PE = 20271442
t1 = 0x5f3586d1
t2 = 0xe3ad7ea5
print("crc1", hex(struct.unpack(">I", buf[PE+4:PE+8])[0]), "crc2", hex(struct.unpack(">I", buf[20271918:20271922])[0]))
buf[PE+4:PE+8] = b"\x00\x00\x00\x00"
buf[20271918:20271922] = b"\x00\x00\x00\x00"

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

TR = mk_refl(0xEDB88320); TM = mk_msb(0x04C11DB7)

def crc(data, msb, init, xorout):
    c = init
    if msb:
        for b in data:
            c = ((c << 8) & 0xFFFFFFFF) ^ TM[((c >> 24) ^ b) & 0xFF]
    else:
        for b in data:
            c = (c >> 8) ^ TR[(c ^ b) & 0xFF]
    return c ^ xorout

spans = {
    "whole": (0, len(buf)),
    "to_crc2": (0, 20271922),
    "payload_end_1": (0, PE + 8),
    "payload_only": (338, PE),
    "sync_to_crc2": (330, 20271922),
}
for name, (a, b) in spans.items():
    data = bytes(buf[a:b])
    for msb in (True, False):
        for init, xo in ((0xFFFFFFFF, 0), (0xFFFFFFFF, 0xFFFFFFFF), (0, 0)):
            v = crc(data, msb, init, xo)
            mark = "MATCH1" if v == t1 else ("MATCH2" if v == t2 else "")
            print(name, "msb" if msb else "refl", hex(init), hex(xo), hex(v), mark)
