import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
D = "/opt/lzh/step03/s7/"
T = {
 "A": (31544, 20), "B": (31580, 20), "C": (31508, 20), "D": (21224, 0),
}
out = {}
for tag, (B, w) in T.items():
    for d in ("d1", "d2"):
        v = f"{tag}_{d}"
        fr = frames_from_bit(D + "s7_%s.bit" % v)
        words = [x % 101 for x in range(w - 2, w + 4)]
        bits = []
        for f in range(B, B + 36):
            for wd in set(words):
                word = fr[f][wd]
                for b in range(32):
                    if word >> b & 1:
                        bits.append([f, wd, b])
        out[v] = bits
json.dump(out, open(D + "s7_bits.json", "w"))
print("WROTE s7_bits.json", {k: len(v) for k, v in out.items()})
