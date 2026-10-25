# -*- coding: utf-8 -*-
"""远端：把 dump_pips.py 写到 right/ 并用 venv python 运行，打印 n1 的 PIP 与 tile 类型。"""
import base64
import gzip
import os

DUMP = r'''import os
import rapidwright
from com.xilinx.rapidwright.design import Design

d = Design.readCheckpoint("/opt/lzh/step03/right/rA1.dcp", "/opt/lzh/step03/right/rA1.edf")
n = d.getNet("n1")
print("net pips", len(list(n.getPIPs())))
for p in n.getPIPs():
    s = str(p)
    tile = s.split("/")[0]
    t = d.getDevice().getTile(tile)
    try:
        tt = t.getTileType().toString()
    except Exception:
        tt = "?"
    print(" ", tt, s)
c = d.getCell("lut_b")
print("lut_b site", c.getSiteName() if c else None)
'''

PAYLOAD = r'''# -*- coding: utf-8 -*-
import base64, gzip, os, subprocess
R = "/opt/lzh/step03/right"
code = gzip.decompress(base64.b64decode("__BLOB__")).decode()
p = os.path.join(R, "dump_pips.py")
open(p, "w", newline="\n").write(code)
env = dict(os.environ, JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64", LANG="C", LC_ALL="C")
r = subprocess.run(["/opt/lzh/venv/bin/python", p], capture_output=True, text=True, env=env, cwd=R)
print(r.stdout[-6000:])
print("ERR", r.stderr[-1500:])
'''


def main():
    blob = base64.b64encode(gzip.compress(DUMP.encode(), 9)).decode()
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "_right_pips.py")
    open(out, "w", encoding="utf-8", newline="\n").write(PAYLOAD.replace("__BLOB__", blob))
    print("wrote", out, os.path.getsize(out))


if __name__ == "__main__":
    main()
