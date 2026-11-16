import json, csv
a = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8-sig"))
t = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\t16.json", encoding="utf-8-sig"))
# locate sink tile for T16 from mk log? assume IMUX_L8
def by_sink(d, sink):
    for tag,v in d.items():
        if v["sink"] == sink: return tag, v["sources"]
    return None, None
tag, L8 = by_sink(a, "IMUX_L8")
print("tilepipe L8 tag", tag)
print("GFAN0 L", L8["GFAN0"])
print("GFAN0 T16", t["GFAN0"])
def norm(m):
    f0 = min(x[0] for x in m); b0 = min(x[2] for x in m)
    return sorted((x[0]-f0, x[2]-b0) for x in m)
print("norm L", norm(L8["GFAN0"]))
print("norm T16", norm(t["GFAN0"]))
# same for EE2END0
print("EE2END0 L", L8.get("EE2END0"), "T16", t.get("EE2END0"))
# locate block containing 31840
rows = list(csv.DictReader(open(r"E:\DEEPSEEK\FPGA比特流逆向\codex_review_framemap_20261024\data\frame_index_far.csv")))
for r in rows:
    if int(r["frame_index"]) == 31840:
        a_ = int(r["block_addr"],16)
        print("frame31840 block", hex(a_), "col", (a_>>7)&0x3ff, "rowf", (a_>>17)&0x1f, "tb", (a_>>22)&1, "kind", r["kind"])
        break
