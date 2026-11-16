import os
R = "/opt/lzh/step03/lutmap"
base = open(os.path.join(R, "v_0000000000000000.bit"), "rb").read()
for tag in ["0000000000000001", "0000000000000008", "8000000000000000"]:
    d = open(os.path.join(R, "v_%s.bit" % tag), "rb").read()
    print("==", tag)
    for lo, hi in [(12827380, 12827580), (20271380, 20271560)]:
        print(lo, base[lo:hi].hex())
        print(lo, d[lo:hi].hex())
