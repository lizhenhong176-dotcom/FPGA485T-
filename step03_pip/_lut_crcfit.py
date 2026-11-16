import struct
R = "/opt/lzh/step03/lutmap"
PE = 20271442
PS = 338
d = open(R + "/v_0000000000000000.bit", "rb").read()
pay = d[PS:PE]
target = struct.unpack(">I", d[PE + 4:PE + 8])[0]
print("target", hex(target), "len", len(pay))

def tab_msb(poly):
    t = []
    for i in range(256):
        c = i << 24
        for _ in range(8):
            c = ((c << 1) ^ poly) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
        t.append(c)
    return t

def crc_msb(data, T, init, xorout):
    c = init
    for b in data:
        c = ((c << 8) & 0xFFFFFFFF) ^ T[((c >> 24) ^ b) & 0xFF]
    return c ^ xorout

for poly in (0x04C11DB7, 0x1EDC6F41, 0x741B8CD7):
    T = tab_msb(poly)
    for init in (0, 0xFFFFFFFF):
        for xor in (0, 0xFFFFFFFF):
            v = crc_msb(pay, T, init, xor)
            if v == target:
                print("MATCH msb poly=%08x init=%08x xor=%08x" % (poly, init, xor))
print("done")
