#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s5

$VIV -mode batch -notrace -source s5_build.tcl -tclargs c_zini \
  -log s5_c_zini.log > s5_c_zini.out 2>&1
[ -f s5_c_zini.bit ] && echo "OK c_zini" || { echo FAIL; tail -5 s5_c_zini.out; }

/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit

BASE = 31716
foi = [BASE+0, BASE+1, BASE+30, BASE+31, BASE+34, BASE+35]
variants = ["c_zini", "b_a5q"]
out = {}
for v in variants:
    fr = frames_from_bit("s5_%s.bit" % v)
    out[v] = {str(x): [fr[x][w] for w in list(range(32,50)) + [90]] for x in foi}
json.dump(out, open("s5c_words.json","w"))
print("WROTE s5c_words.json")
PYEOF
