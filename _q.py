import json
d = json.load(open(r"tamper\classes_ref_all.json", encoding="utf-8"))
c = d["classes"][0]
print(list(c.keys()))
print(json.dumps(c.get("detected_examples", c)[:3] if isinstance(c.get("detected_examples"), list) else c, ensure_ascii=False)[:700])
