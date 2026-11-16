# -*- coding: utf-8 -*-
import json
from pathlib import Path

for f in ("tamper/classes_ref300_154col.json", "tamper/atk_ref300_154col.json"):
    p = Path(r"E:\DEEPSEEK\FPGA比特流逆向") / f
    if not p.exists():
        print("missing", f)
        continue
    d = json.load(open(p, encoding="utf-8"))
    print("==", f)
    for k, v in d.items():
        if isinstance(v, dict):
            print("  ", k, {kk: vv for kk, vv in v.items() if not isinstance(vv, (list, dict))})
        elif not isinstance(v, list):
            print("  ", k, "=", v)
    print("  keys:", list(d))
