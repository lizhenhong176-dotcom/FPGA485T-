import json, collections
from pathlib import Path
cands=json.loads(Path(r"E:\DEEPSEEK\FPGA比特流逆向\m2_fix\candidates.json").read_text())
print("total",len(cands))
for c in cands:
    if c["clb_type"]=="CLBLL_L" and c["lut"]=="CLBLL_L" and {c["pin_a"],c["pin_b"]}=={"A3","A5"}:
        print("A3/A5",c)
print("LCA top")
print(collections.Counter(c["lca"] for c in cands).most_common(15))
print("pin pairs top")
print(collections.Counter((c["pin_a"],c["pin_b"]) for c in cands).most_common(10))
print("by type")
print(collections.Counter(c["clb_type"] for c in cands))
print("A3/A5 all halves")
for c in cands:
    if {c["pin_a"],c["pin_b"]}=={"A3","A5"}:
        print(c["clb_type"],c["lut"],c["branch_pips"],c["lca"],c["path_a"],c["path_b"])
