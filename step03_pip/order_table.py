import json
order = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\pip_order_L8.json", encoding="utf-8"))
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
rec = [v for v in d.values() if v["sink"] == "IMUX_L8"][0]["sources"]
rows = []
for src, i in order.items():
    m = sorted((f - 31696, b - 2) for f, w, b in rec[src])
    r = [c for c in m if c[0] <= 5]
    c = [c[0] for c in m if c[0] >= 6]
    rows.append((i, src, r[0] if len(r) == 1 else r, tuple(c)))
for i, s, r, c in sorted(rows):
    print("%2d %-20s row=%-9s col=%s" % (i, s, r, c))
