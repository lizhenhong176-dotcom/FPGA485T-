import json
from pathlib import Path

p = Path(__file__).resolve().parent / "CLBLL_L.json"
d = json.loads(p.read_text())
pips = d["pip_defs"]
print("pips ending at A3/A5 pins:")
for pip in pips:
    if pip[1] in {"CLBLL_L_A3", "CLBLL_LL_A3", "CLBLL_L_A5", "CLBLL_LL_A5"}:
        print(" ", pip)
print("pips ending at IMUX wires used by A3/A5:")
for target in ("CLBLL_IMUX1", "CLBLL_IMUX8", "CLBLL_IMUX9"):
    print(target)
    for pip in pips:
        if pip[1] == target:
            print("  ", pip)
print("pips ending at B3/B5 pins and IMUX16/17/24/25:")
for target in ("CLBLL_L_B3", "CLBLL_LL_B3", "CLBLL_L_B5", "CLBLL_LL_B5",
               "CLBLL_IMUX16", "CLBLL_IMUX17", "CLBLL_IMUX24", "CLBLL_IMUX25"):
    print(target)
    for pip in pips:
        if pip[1] == target:
            print("  ", pip)
