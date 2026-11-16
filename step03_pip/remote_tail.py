import struct, os
D = "/opt/lzh/step03/lutmap"
f = os.path.join(D, "v_0000000000000000.bit")
buf = open(f, "rb").read()
n = len(buf)
print("len", n)
# find all occurrences of 0x30000001
needle = b"\x30\x00\x00\x01"
pos = 0
hits = []
while True:
    i = buf.find(needle, pos)
    if i < 0:
        break
    hits.append(i)
    pos = i + 1
print("30000001 hits", hits)
print("tail words")
for i in range(max(0, n - 256), n, 4):
    print(i, buf[i:i+4].hex(), hex(struct.unpack(">I", buf[i:i+4])[0]))
