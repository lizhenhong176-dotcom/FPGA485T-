export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
for k in 0 1 2 3 4 5; do
  /opt/lzh/venv/bin/python - "$k" <<'PY'
import sys
k = int(sys.argv[1])
val = 0
for i in range(64):
    if (i >> k) & 1:
        val |= 1 << i
src = open("top8.v").read()
src = src.replace("64'h0000000000000001", "64'h%016x" % val, 1)
open("top8_k%d.v" % k, "w").write(src)
print("k=%d INIT=0x%016x" % (k, val))
PY
  sed "s|./top8.v|./top8_k$k.v|; s|full8.dcp|full8_k$k.dcp|; s|full8.pips|full8_k$k.pips|; s|T1B_DONE|T1B_K$k|" build8.tcl > build8_k$k.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8_k$k.tcl > b_k$k.log 2>&1
  grep -q "T1B_K$k" b_k$k.log && echo "SYNTH OK k=$k" || { echo "SYNTH FAIL k=$k"; tail -8 b_k$k.log; continue; }
  sed "s|full8_i3|full8_k$k|g; s|BIT_I3_OK|BIT_K${k}_OK|" bit_i3.tcl > bit_k$k.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_k$k.tcl > b_bit_k$k.log 2>&1
  grep -q "BIT_K${k}_OK" b_bit_k$k.log && echo "BIT OK k=$k" || { echo "BIT FAIL k=$k"; tail -8 b_bit_k$k.log; }
done
ls -l full8_k*/top.bit 2>/dev/null | wc -l