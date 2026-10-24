import json
from pathlib import Path

p = Path(__file__).resolve().parent / "CLBLL_L.json"
d = json.loads(p.read_text())
print(type(d), list(d))
for key, value in d.items():
    try:
        n = len(value)
    except Exception:
        n = "?"
    print(key, type(value).__name__, n)
for key in list(d)[:5]:
    print("---", key)
    print(json.dumps(d[key], indent=1)[:2500])
