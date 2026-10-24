import json
from pathlib import Path

p = Path("/tmp/m2_bad/m2_mcd_0001.json")
d = json.loads(p.read_text())
d["data_bits"] = [[22, 2], [22, 3], [22, 99]]
p.write_text(json.dumps(d, indent=2) + "\n")
print("corrupted", p)
