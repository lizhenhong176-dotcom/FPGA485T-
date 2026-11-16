import zlib
f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
buf = open(f, "rb").read()
PE = 20271442
target = 0x5f3586d1
hits = []
for start in range(0, 460):
    for end in (PE, PE + 4, PE + 8, PE + 12):
        d = buf[start:end]
        v = zlib.crc32(d) & 0xFFFFFFFF
        if v == target:
            hits.append(("std", start, end))
        v2 = zlib.crc32(d, 0xFFFFFFFF) & 0xFFFFFFFF
        if v2 == target:
            hits.append(("noxor", start, end))
print("hits", hits)
print("sample", hex(zlib.crc32(buf[338:PE]) & 0xFFFFFFFF))
