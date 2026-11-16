export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
/opt/lzh/venv/bin/python - <<'PY'
import re
planes = []
for k in range(6):
    v = 0
    for i in range(64):
        if (i >> k) & 1: v |= 1 << i
    planes.append(v)
src0 = open("top8.v").read()
for b in range(6):
    src = src0
    for j, init in enumerate("1 2 4 8 10 20 40 80".split()):
        old = "64'h%016x" % int(init, 16)
        new = "64'h%016x" % planes[(b + j) % 6]
        # 逐个替换第 j 个 LUT 的 INIT
        src = src.replace(old, new, 1)
    open("top8_r%d.v" % b, "w").write(src)
    print("r%d 写好" % b)
PY
for b in 0 1 2 3 4 5; do
  sed "s|./top8.v|./top8_r$b.v|; s|full8.dcp|full8_r$b.dcp|; s|full8.pips|full8_r$b.pips|; s|T1B_DONE|T1B_R$b|" build8.tcl > build8_r$b.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8_r$b.tcl > b_r$b.log 2>&1
  grep -q "T1B_R$b" b_r$b.log && echo "SYNTH OK r=$b" || { echo "SYNTH FAIL r=$b"; tail -6 b_r$b.log; continue; }
  sed "s|full8_i3|full8_r$b|g; s|BIT_I3_OK|BIT_R${b}_OK|" bit_i3.tcl > bit_r$b.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_r$b.tcl > b_bit_r$b.log 2>&1
  grep -q "BIT_R${b}_OK" b_bit_r$b.log && gzip -9 -c full8_r$b.bit | base64 -w 0 > full8_r$b.bit.b64 && echo "BIT OK r=$b $(stat -c %s full8_r$b.bit.b64)" || { echo "BIT FAIL r=$b"; tail -6 b_bit_r$b.log; }
done