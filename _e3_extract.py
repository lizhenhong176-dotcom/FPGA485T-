import base64, io, os, re, zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
src = os.path.join(ROOT, "_crcgen_run.sh")
s = open(src, "r", encoding="utf-8", errors="replace").read()
m = re.search(r"<<'B64EOF'\n(.*?)\nB64EOF", s, re.S)
b = base64.b64decode(m.group(1))
z = zipfile.ZipFile(io.BytesIO(b))
names = z.namelist()
print("files:", len(names))
print(sorted(names)[:8])
out = os.path.join(ROOT, "_e3_src")
os.makedirs(out, exist_ok=True)
z.extractall(out)
print("extracted to", out)
for n in sorted(names):
    if n.endswith((".v", ".tcl")) and (n.startswith("c_base") or n.startswith("c00")):
        p = os.path.join(out, n)
        print("=" * 20, n, os.path.getsize(p))
        print(open(p, "r", encoding="utf-8", errors="replace").read())
