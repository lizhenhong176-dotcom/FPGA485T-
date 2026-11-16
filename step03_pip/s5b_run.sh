#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s5

for v in b_xor b_cy b_a5q; do
  $VIV -mode batch -notrace -source s5_build.tcl -tclargs $v \
    -log s5_$v.log > s5_$v.out 2>&1
  if [ -f s5_$v.bit ]; then echo "OK $v"; else echo "FAIL $v"; tail -5 s5_$v.out; fi
done

/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

variants = ["b_xor", "b_cy", "b_a5q", "a_o6", "a_o5", "a_a5q", "a_f7"]
BASE = 31716
foi = [BASE+0, BASE+1, BASE+30, BASE+31]
out = {}
for v in variants:
    fr = frames_from_bit("s5_%s.bit" % v)
    out[v] = {str(x): [fr[x][w] for w in range(32, 50)] for x in foi}
with open("s5b_words.json", "w") as f:
    json.dump(out, f)
print("WROTE s5b_words.json")
PYEOF
