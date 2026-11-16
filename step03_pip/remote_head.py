import struct
f = "/opt/lzh/step03/lutmap/v_0000000000000000.bit"
with open(f, "rb") as fh:
    head = fh.read(1500)
for i in range(0, 400, 4):
    w = struct.unpack(">I", head[i:i+4])[0]
    if i < 96 or 300 <= i < 400:
        print(i, hex(w))
