import struct
R = "/opt/lzh/step03/lutmap"
PE = 20271442
d = open(R + "/v_0000000000000000.bit", "rb").read()
target = struct.unpack(">I", d[PE + 4:PE + 8])[0]

def tab():
    t = []
    for i in range(256):
        c = i << 24
        for _ in range(8):
            c = ((c << 1) ^ 0x04C11DB7) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
        t.append(c)
    return t
T = tab()

def crc(data, init=0, xorout=0):
    c = init
    for b in data:
        c = ((c << 8) & 0xFFFFFFFF) ^ T[((c >> 24) ^ b) & 0xFF]
    return c ^ xorout

def rev32(x):
    return int("{:032b}".format(x)[::-1], 2)

def swap4(b):
    out = bytearray(b)
    for i in range(0, len(b) - 3, 4):
        out[i], out[i+1], out[i+2], out[i+3] = b[i+3], b[i+2], b[i+1], b[i]
    return bytes(out)

pay = d[338:PE]
print("target %08x" % target)
for label, data in [("payload", pay), ("sync..", d[334:PE]), ("file..", d[0:PE]), ("hdrsync", d[154:PE])]:
    for init in (0, 0xFFFFFFFF):
        v = crc(data, init, 0)
        for tag, vv in [("", v), ("rev", rev32(v)), ("~", v ^ 0xFFFFFFFF)]:
            mark = "  <== MATCH" if vv == target else ""
            print("%-8s init=%08x %s %08x%s" % (label, init, tag, vv, mark))
sw = swap4(pay)
for init in (0, 0xFFFFFFFF):
    v = crc(sw, init, 0)
    print("swap4 init=%08x %08x%s" % (init, v, "  <== MATCH" if v == target else ""))
