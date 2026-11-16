import struct, zlib
R = "/opt/lzh/step03/lutmap"
PE = 20271442
SYNC = 334
d = open(R + "/v_0000000000000000.bit", "rb").read()
target = struct.unpack(">I", d[PE + 4:PE + 8])[0]
spans = {"payload": d[338:PE], "fromsync": d[SYNC:PE], "body": d[338:PE]}
for name, s in spans.items():
    print(name, "zlib", hex(zlib.crc32(s) & 0xFFFFFFFF), "zlib0", hex(zlib.crc32(s, 0) & 0xFFFFFFFF))
print("target", hex(target))
# also try adler32
print("adler", hex(zlib.adler32(d[338:PE]) & 0xFFFFFFFF))
