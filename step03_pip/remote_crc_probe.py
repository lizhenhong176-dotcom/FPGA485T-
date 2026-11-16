import json, os, struct, sys

D = "/opt/lzh/step03/lutmap"
f = None
for name in sorted(os.listdir(D)):
    if name.startswith("v_") and name.endswith(".bit") and "0000000000000000" in name:
        f = os.path.join(D, name)
        break
if f is None:
    for name in sorted(os.listdir(D)):
        if name.startswith("v_") and name.endswith(".bit"):
            f = os.path.join(D, name)
            print("fallback", name)
            break
buf = open(f, "rb").read()
n = len(buf)
target = struct.unpack(">I", buf[-4:])[0]
print("file", f, "len", n, "target", hex(target))

def crc_refl(data, poly=0xEDB88320, init=0xFFFFFFFF, xorout=0xFFFFFFFF):
    t = []
    for i in range(256):
        c = i
        for _ in range(8):
            c = (c >> 1) ^ poly if c & 1 else c >> 1
        t.append(c)
    c = init
    for b in data:
        c = (c >> 8) ^ t[(c ^ b) & 0xFF]
    return c ^ xorout

def crc_msb(data, poly=0x04C11DB7, init=0xFFFFFFFF, xorout=0):
    t = []
    for i in range(256):
        c = i << 24
        for _ in range(8):
            c = ((c << 1) ^ poly) & 0xFFFFFFFF if c & 0x80000000 else (c << 1) & 0xFFFFFFFF
        t.append(c)
    c = init
    for b in data:
        c = ((c << 8) & 0xFFFFFFFF) ^ t[((c >> 24) ^ b) & 0xFF]
    return c ^ xorout

spans = {
    "payload": (338, n - 4),
    "payload_ecc": (338, n - 4),
    "after_fdri_cmd": (330, n - 4),
    "sync_onward": (334, n - 4),
    "whole_minus_tail": (0, n - 4),
    "payload_to_eof": (338, n),
}
res = []
for name, (a, b) in spans.items():
    data = buf[a:b]
    res.append([name, "refl", hex(crc_refl(data))])
    res.append([name, "msb", hex(crc_msb(data))])
    res.append([name, "refl_noxor", hex(crc_refl(data, xorout=0))])
    res.append([name, "msb_xor", hex(crc_msb(data, xorout=0xFFFFFFFF))])
    res.append([name, "msb_init0", hex(crc_msb(data, init=0))])
    res.append([name, "refl_init0", hex(crc_refl(data, init=0))])
for r in res:
    print(r[0], r[1], r[2], "MATCH" if int(r[2], 16) == target else "")
