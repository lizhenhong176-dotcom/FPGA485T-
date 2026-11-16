import base64
import io
import tarfile
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
b64 = io.open(ROOT / "step03_pip" / "out" / "_b2.b64", encoding="ascii").read().strip()
raw = base64.b64decode(b64)
tgz = ROOT / "step03_pip" / "out" / "_b2.tgz"
tgz.write_bytes(raw)
dest = ROOT / "tamper" / "ref" / "p1" / "remote" / "out2"
dest.mkdir(parents=True, exist_ok=True)
with tarfile.open(tgz) as t:
    members = t.getmembers()
    t.extractall(dest, filter="data")
names = sorted(m.name for m in members)
print("bytes", len(raw), "members", len(names))
for n in names:
    print(" ", n, (dest / n).stat().st_size)
