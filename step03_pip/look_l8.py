import json, collections
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
rec = [v for v in d.values() if v["sink"] == "IMUX_L8"][0]
srcs = rec["sources"]
# cell index within window: frame-31696 -> 0..9, bit base 2 -> b/ b+1
print("%-20s mask" % "source")
for s in sorted(srcs):
    cells = sorted((f - 31696, b - 2) for f, w, b in srcs[s])
    print("%-20s %s" % (s, cells))
cnt = collections.Counter()
for s in srcs:
    for f, w, b in srcs[s]:
        cnt[(f - 31696, b - 2)] += 1
print("\ncell -> #sources:", sorted(cnt.items()))
