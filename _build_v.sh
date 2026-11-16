export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/t1; cd $D || exit 1
/opt/lzh/venv/bin/python - <<'PY'
val = 0xDEADBEEFCAFEBABE
src = open("top8.v").read().replace("64'h0000000000000001", "64'h%016x" % val, 1)
open("top8_v.v", "w").write(src)
print("INIT=0x%016x" % val)
PY
sed "s|./top8.v|./top8_v.v|; s|full8.dcp|full8_v.dcp|; s|full8.pips|full8_v.pips|; s|T1B_DONE|T1B_V|" build8.tcl > build8_v.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build8_v.tcl > b_v.log 2>&1
grep -q T1B_V b_v.log && echo "SYNTH OK" || { echo FAIL; tail -8 b_v.log; }
sed "s|full8_i3|full8_v|g; s|BIT_I3_OK|BIT_V_OK|" bit_i3.tcl > bit_v.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_v.tcl > b_bit_v.log 2>&1
grep -q BIT_V_OK b_bit_v.log && gzip -9 -c full8_v.bit | base64 -w 0 > full8_v.bit.b64 && echo "BIT OK $(stat -c %s full8_v.bit.b64)"