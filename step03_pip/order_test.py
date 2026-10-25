import json
tt = json.load(open(r"E:\v7work\db\prjxray\xc7vx485t\tile_type_INT_L.json", encoding="utf-8"))
pips = list(tt["pips"].keys())
l8 = [p for p in pips if p.endswith("->IMUX_L8")]
print("order of pips into IMUX_L8 (declaration):")
for i, p in enumerate(l8):
    print(i, p)
print("\ntotal pips:", len(pips), "l8:", len(l8))
# also look at wires order subset
wires = list(tt["wires"].keys())
print("wire count:", len(wires))
print("first 10 wires:", wires[:10])
