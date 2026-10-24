import json
from pathlib import Path

c = json.loads(Path(r"E:\DEEPSEEK\FPGA比特流逆向\m2_fix\candidates.json").read_text())
print("total", len(c))
nr = [x for x in c if x["lca"].startswith("NR1END")]
print("NR1END", len(nr))
for x in nr[:30]:
    print(x["clb_type"], x["lut"], x["pin_a"], x["pin_b"], x["lca"],
          x["path_a"], x["path_b"])
print("unique pairs total", len({(x["clb_type"], x["lut"], x["pin_a"], x["pin_b"]) for x in c}))
print("NR unique pairs", len({(x["clb_type"], x["lut"], x["pin_a"], x["pin_b"]) for x in nr}))
