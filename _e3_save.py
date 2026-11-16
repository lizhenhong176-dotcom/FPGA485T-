import json, os, re
root = os.path.dirname(os.path.abspath(__file__))
s = open(os.path.join(root, "_e3_diff_out.txt"), encoding="utf-8", errors="replace").read()
m = re.search(r"E3DIFF_JSON_BEGIN(.*?)E3DIFF_JSON_END", s, re.S)
data = json.loads(m.group(1).strip())
p = os.path.join(root, "v7re", "steps", "e3_result.json")
open(p, "w", encoding="utf-8", newline="\n").write(json.dumps(data, indent=1, sort_keys=True))
print("wrote", p, os.path.getsize(p), "B")
