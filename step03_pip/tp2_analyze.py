import json, collections
a = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8-sig"))
r = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tp2.json", encoding="utf-8-sig"))
def summarize(d, label):
    rows = []
    for tag, v in d.items():
        srcs = v["sources"]
        words = sorted({w for m in srcs.values() for f, w, b in m})
        frames = sorted({f for m in srcs.values() for f, w, b in m})
        n = [len(m) for m in srcs.values()]
        rows.append((v["sink"], len(srcs), words, (frames[0], frames[-1]) if frames else None, collections.Counter(n)))
    print("==", label, "designs", len(rows))
    for x in sorted(rows)[:6]:
        print("  ", x)
summarize(a, "INT_L_X6Y11")
summarize(r, "INT_R (X14/X15 designs)")
# wire name overlap
wa = {s for v in a.values() for s in v["sources"]}
wr = {s for v in r.values() for s in v["sources"]}
print("shared wire names:", len(wa & wr), "onlyL:", len(wa - wr), "onlyR:", len(wr - wa))
print("sample shared:", sorted(wa & wr)[:8])
