#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cd /opt/lzh/step03/s5

$VIV -mode batch -notrace -source s6_build.tcl -tclargs d_f8 \
  -log s5_d_f8.log > s5_d_f8.out 2>&1
[ -f s5_d_f8.bit ] && echo "OK d_f8" || { echo FAIL; tail -8 s5_d_f8.out; }

/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
BASE = 31716
foi = [BASE+0, BASE+1, BASE+30, BASE+31, BASE+34, BASE+35]
variants = ["d_fdld","d_ffx","d_ffse","d_ceinv","d_srinv","d_ckinv","d_f8","d_fo5","d_ffxor",
            "b_a5q","a_o6"]
out = {}
for v in variants:
    fr = frames_from_bit("s5_%s.bit" % v)
    out[v] = {str(x): [fr[x][w] for w in list(range(32,50)) + [90]] for x in foi}
json.dump(out, open("s6_words.json","w"))
print("WROTE s6_words.json")
PYEOF
