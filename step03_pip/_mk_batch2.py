import base64
import io
import tarfile
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
SRC = ROOT / "tamper" / "ref" / "p1"
names = ["d8b_dense", "d9_wide", "d10_long", "d11_mix", "d12_fanout2"]
files = []
for n in names:
    files += [SRC / (n + ".v"), SRC / (n + ".xdc"), SRC / ("build_" + n + ".tcl")]
files.append(SRC / "run_new.sh")

tgz = ROOT / "step03_pip" / "out" / "_p1b.tgz"
tgz.parent.mkdir(parents=True, exist_ok=True)
with tarfile.open(tgz, "w:gz") as t:
    for f in files:
        t.add(str(f), arcname=f.name)
raw = tgz.read_bytes()
b64 = base64.b64encode(raw).decode("ascii")
lines = [b64[i:i + 120] for i in range(0, len(b64), 120)]

sh = ["set -e", "cd /opt/lzh/v7re/work/p1", "mkdir -p out",
      "base64 -d > /tmp/p1b.tgz <<'B64END'"]
sh += lines
sh += ["B64END", "tar xzf /tmp/p1b.tgz", "ls -l *.v | tail -6",
       "bash run_new.sh", "echo BATCH2_DONE"]
p = ROOT / "step03_pip" / "_remote_build_batch2.sh"
io.open(p, "w", encoding="utf-8", newline="\n").write("\n".join(sh) + "\n")
print("tar", len(raw), "bytes | b64", len(b64), "| script", p, "|", len(sh), "lines")
