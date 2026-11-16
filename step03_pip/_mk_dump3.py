import base64
import io
from pathlib import Path

ROOT = Path(r"E:\DEEPSEEK\FPGA比特流逆向")
dump = (ROOT / "step03_pip" / "_remote_dump_cells.py").read_bytes()
b64 = base64.b64encode(dump).decode("ascii")
lines = [b64[i:i + 120] for i in range(0, len(b64), 120)]

sh = ["cd /opt/lzh/v7re/work/p1",
      "base64 -d > _dump.py <<'B64END'"] + lines + ["B64END",
      "mkdir -p out2",
      "for n in d8b_dense d9_wide d10_long d11_mix d12_fanout2; do cp -f out/$n.bit out2/; cp -f out/$n.pips out2/; done",
      "python3 _dump.py out2",
      "tar czf /tmp/b2out.tgz -C out2 .",
      "echo PACK $(stat -c%s /tmp/b2out.tgz)",
      "base64 -w0 /tmp/b2out.tgz > /tmp/b2out.b64",
      "echo B64SIZE $(stat -c%s /tmp/b2out.b64)"]
p = ROOT / "step03_pip" / "_remote_dump_batch2c.sh"
io.open(p, "w", encoding="utf-8", newline="\n").write("\n".join(sh) + "\n")
print("wrote", p)
