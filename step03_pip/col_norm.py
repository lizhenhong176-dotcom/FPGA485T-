import collections, json
d = json.load(open(r"E:\DEEPSEEK\FPGA比特流逆向\step03_pip\tilepipe.json", encoding="utf-8"))
def f(L): return 1 + 8*(L%4) + (L//8)
per = {}
for tag, rec in d.items():
    mux = rec["sink"]; L = int(mux.split("_L")[1]); b0 = f(L)
    per[mux] = {s: sorted({(fr-31696, b-b0) for fr, w, b in m}) for s, m in rec["sources"].items()}
bywire = collections.defaultdict(dict)
for mux, srcs in per.items():
    for s, mask in srcs.items():
        bywire[s][mux] = tuple(mask)
for w in ["GFAN0", "EE2END0", "LOGIC_OUTS_L0", "BYP_BOUNCE_N3_2"]:
    print("==", w)
    for mux, mask in sorted(bywire[w].items(), key=lambda kv: int(kv[0].split("_L")[1]))[:8]:
        print("   %-9s %s" % (mux, mask))
# consistency: for wires in >=2 muxes, how often identical normalized mask?
same = 0; total = 0
for w, mm in bywire.items():
    masks = set(mm.values())
    if len(mm) >= 2:
        total += 1
        if len(masks) == 1:
            same += 1
print("\nwires in >=2 muxes:", total, "with identical normalized mask:", same)
