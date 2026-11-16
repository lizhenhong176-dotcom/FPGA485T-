import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

fr = frames_from_bit("/opt/lzh/step03/s8/s8_v0.bit")
out = {"nframes": len(fr), "col": {}}
for off in range(36):
    f = 31680 + off
    out["col"][str(f)] = [fr[f][w] for w in range(101)]
json.dump(out, open("/opt/lzh/step03/s8/s8_col.json", "w"))
print("dumped", out["nframes"], "frames; col 31680-31715")
