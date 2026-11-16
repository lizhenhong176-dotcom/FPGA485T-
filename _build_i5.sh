export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
sed "s/64'h0000000000000001/64'h0000000000000005/" top8.v > top8_init5.v
sed 's|./top8.v|./top8_init5.v|; s|full8.dcp|full8_i5.dcp|; s|full8.pips|full8_i5.pips|; s|T1B_DONE|T1B_I5|' build8.tcl > build8_i5.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8_i5.tcl > b_i5.log 2>&1
grep -q T1B_I5 b_i5.log && echo OK || { echo FAIL; tail -10 b_i5.log; }
sed 's|full8_i3|full8_i5|g; s|BIT_I3_OK|BIT_I5_OK|' bit_i3.tcl > bit_i5.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_i5.tcl > b_bit_i5.log 2>&1
grep -q BIT_I5_OK b_bit_i5.log && echo "BIT OK" || { echo BITFAIL; tail -10 b_bit_i5.log; }
/opt/lzh/venv/bin/python - <<'PY'
import sys, numpy as np
sys.path.insert(0, "/opt/lzh/v7re")
from bitstream.parser import frames_from_bit
a = np.array(frames_from_bit("full8.bit"), dtype=np.uint32)
for n in ("full8_i3","full8_i5"):
    b = np.array(frames_from_bit(n + ".bit"), dtype=np.uint32)
    d = np.argwhere(a != b)
    print(n, "与 full8(INIT=1) 差异:", [(int(f), int(w), hex(int(b[f][w]))) for f, w in d])
PY