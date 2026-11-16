import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

out = {}
D = "/opt/lzh/step03/s5/"
for v in ["b_a5q", "a_o6", "d_fdld", "d_ffx"]:
    fr = frames_from_bit(D + "s5_%s.bit" % v)
    words = list(range(32, 50)) + [90]
    out[v] = {str(f): [fr[f][wd] for wd in words] for f in range(31716, 31752)}
json.dump(out, open(D + "s6_col.json", "w"))
print("WROTE s6_col.json")
