import struct, os
D = "/opt/lzh/step03/lutmap"
f = os.path.join(D, "v_0000000000000000.bit")
buf = open(f, "rb").read()
PE = 20271442
crc1 = struct.unpack(">I", buf[PE+4:PE+8])[0]
crc2 = struct.unpack(">I", buf[20271918:20271922])[0]
print("crc1", hex(crc1), "crc2", hex(crc2))
print("words at 20271438..20271470")
for i in range(20271434, 20271474, 4):
    print(i, buf[i:i+4].hex())
print("words at 20271906..20271934")
for i in range(20271906, 20271934, 4):
    print(i, buf[i:i+4].hex())

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

def crc_refl(data, init=0xFFFFFFFF, xorout=0xFFFFFFFF):
    c = init
    for b in data:
        c = (c >> 8) ^ TR[(c ^ b) & 0xFF]
    return c ^ xorout

def crc_msb(data, init=0xFFFFFFFF, xorout=0):
    c = init
    for b in data:
        c = ((c << 8) & 0xFFFFFFFF) ^ TM[((c >> 24) ^ b) & 0xFF]
    return c ^ xorout

spans = {
    "payload": (338, PE),
    "sync_fdri": (330, PE),
    "from_0xAA99": (334, PE),
    "header_all": (0, PE),
}
for name, (a, b) in spans.items():
    data = buf[a:b]
    print(name, len(data),
          "refl", hex(crc_refl(data)),
          "refl_noxor", hex(crc_refl(data, xorout=0)),
          "refl_init0", hex(crc_refl(data, init=0, xorout=0)),
          "msb", hex(crc_msb(data)),
          "msb_xor", hex(crc_msb(data, xorout=0xFFFFFFFF)),
          "msb_init0", hex(crc_msb(data, init=0)))
