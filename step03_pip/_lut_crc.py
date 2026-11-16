import os, struct
R = "/opt/lzh/step03/lutmap"
PE = 20271442
out = {}
for tag in sorted(os.listdir(R)):
    if not tag.startswith("v_") or not tag.endswith(".bit"):
        continue
    d = open(os.path.join(R, tag), "rb").read()
    k = tag[2:-4]
    crc = struct.unpack(">I", d[PE + 4:PE + 8])[0]
    w20 = [struct.unpack(">I", d[PE - (50176 - f) * 404 + 80:PE - (50176 - f) * 404 + 84])[0] for f in (31748, 31749, 31750, 31751)]
    w50 = [struct.unpack(">I", d[PE - (50176 - f) * 404 + 200:PE - (50176 - f) * 404 + 204])[0] for f in (31748, 31749, 31750, 31751)]
    out[k] = {"crc": crc, "w20": w20, "w50": w50}
import json
print(json.dumps(out, sort_keys=True))
