import json
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\p3_bits.json", encoding="utf-8"))
for tag in sorted(d):
    pos = sorted({(f, w, b) for rec in d[tag].values() for f, w, b in rec["config"]})
    print(tag, "positions:", pos)
    for src, rec in sorted(d[tag].items())[:8]:
        print("   %-16s %s" % (src, rec["config"]))
