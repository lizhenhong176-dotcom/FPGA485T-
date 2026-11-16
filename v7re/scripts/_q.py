import json
for f in ("tamper\classes_ref300.json","tamper\classes_full8_300.json"):
    d = json.load(open(f, encoding="utf-8"))
    print(f)
    for c in d["classes"]:
        print("  ", c["class"], "n=%d det=%d rate=%s" % (c["attempted"], c["detected"], c["detect_rate_pct"]))
