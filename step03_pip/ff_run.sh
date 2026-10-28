#!/bin/bash
set -u
export LANG=C LC_ALL=C HOME=/root
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
VIV=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
mkdir -p /opt/lzh/step03/s4ff && cd /opt/lzh/step03/s4ff

for v in ax o5 o6 f7; do
  $VIV -mode batch -notrace -source ff_build.tcl -tclargs $v \
    -log ff_$v.log > ff_$v.out 2>&1
  if [ -f ff_$v.bit ]; then echo "OK $v"; else echo "FAIL $v"; tail -5 ff_$v.out; fi
done

/opt/lzh/venv/bin/python - <<'PYEOF'
import sys, json
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
from bitstream.frames import diff_frame_indices, diff_bits_in_frame

fa = frames_from_bit("ff_ax.bit")
for v in ["o5", "o6", "f7"]:
    fb = frames_from_bit("ff_%s.bit" % v)
    frames = diff_frame_indices(fa, fb)
    cfg = [[x, w, b] for x in frames for w, b in diff_bits_in_frame(fa, fb, x) if w != 50]
    print(v, "vs ax ->", cfg)
PYEOF
