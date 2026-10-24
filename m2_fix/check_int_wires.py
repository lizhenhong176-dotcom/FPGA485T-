import json
from pathlib import Path

root = Path("/data/lzh/v7re/work/refs_20261021/routing/out_routing/templates")
for typ in ("INT_L", "INT_R"):
    d = json.loads((root / (typ + ".json")).read_text())
    wires = {w[0] for w in d["wire_defs"]}
    print(typ, "wires", len(wires))
    for name in ("CLBLL_NE4C1", "CLBLL_IMUX1", "CLBLL_IMUX8", "CLBLL_IMUX9",
                 "CLBLL_L_A3", "CLBLL_LL_A3", "NR1END0", "NR1BEG0"):
        print(" ", name, name in wires)
    print("pips touching CLBLL_IMUX1")
    for p in d["pip_defs"]:
        if "CLBLL_IMUX1" in p[:2]:
            print("  ", p)
    print("pips touching NR1END0")
    for p in d["pip_defs"]:
        if "NR1END0" in p[:2]:
            print("  ", p)
