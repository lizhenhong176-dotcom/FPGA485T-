import struct

p = "/opt/lzh/step03/famr/ref_now.bit"
data = open(p, "rb").read()
sync = data.find(b"\xaa\x99\x55\x66")
pos = sync + 4
while pos + 4 <= len(data):
    w = struct.unpack_from(">I", data, pos)[0]
    typ = w >> 29
    op = (w >> 27) & 0x3
    reg = (w >> 13) & 0x3FFF
    cnt = w & 0x1FFF
    if reg == 2 or (typ == 2):
        print(pos, hex(w), "type", typ, "op", op, "reg", reg, "cnt", cnt)
        if typ == 2:
            break
    pos += 4
    if typ in (1, 2) and cnt:
        pos += 4 * cnt
