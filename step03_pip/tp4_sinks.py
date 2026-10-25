import glob, json, os, re
R = "/opt/lzh/step03/tilepipe4"
out = json.load(open("/mnt/c/Users/S.tschai/tp4.json"))
for f in glob.glob(os.path.join(R, "mk_*.log")):
    tag = os.path.basename(f)[3:-4]
    txt = open(f, errors="replace").read()
    m = re.search(r"sink\s+(IMUX\w*)", txt)
    if tag in out:
        out[tag]["sink"] = m.group(1) if m else None
json.dump(out, open("/mnt/c/Users/S.tschai/tp4b.json", "w"), indent=1)
print("sinks", sum(1 for v in out.values() if v.get("sink")), "of", len(out))
print(sorted({v.get("sink") for v in out.values()})[:10])