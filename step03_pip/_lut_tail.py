import struct
R = "/opt/lzh/step03/lutmap"
PE = 20271442
base = open(R + "/v_0000000000000000.bit", "rb").read()
for tag in ["0000000000000001", "0000000000000008", "8000000000000000"]:
    d = open(R + "/v_%s.bit" % tag, "rb").read()
    bw = [struct.unpack(">I", base[i:i + 4])[0] for i in range(PE, len(base), 4)]
    dw = [struct.unpack(">I", d[i:i + 4])[0] for i in range(PE, len(d), 4)]
    diffs = [(i, hex(bw[i]), hex(dw[i])) for i in range(min(len(bw), len(dw))) if bw[i] != dw[i]]
    print(tag, "tail words", len(bw), "diffs", diffs[:10])
    # header diffs
    hd = [(i, base[i:i+4].hex(), d[i:i+4].hex()) for i in range(0, 338, 4) if base[i:i+4] != d[i:i+4]]
    print("  header diffs", hd)
