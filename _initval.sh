export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/initsweep
cd $D || exit 1
/opt/lzh/venv/bin/python - <<'PY'
src = open("base8.v").read().split("\n")
n = [i for i, L in enumerate(src) if "l3 (" in L][0]
src[n] = src[n].replace("64'h0000000000000000", "64'hdeadbeefcafebabe")
n = [i for i, L in enumerate(src) if "l6 (" in L][0]
src[n] = src[n].replace("64'h0000000000000000", "64'h0123456789abcdef")
open("v3.v", "w").write("\n".join(src))
PY
sed "s|b0.v|v3.v|; s|b0.bit|v3.bit|g; s|DONE_b0|DONE_v3|" b0.tcl > v3.tcl
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source v3.tcl > v3.log 2>&1
grep -q DONE_v3 v3.log && gzip -9 -c v3.bit | base64 -w 0 > v3.bit.b64 && echo "OK v3 $(stat -c %s v3.bit.b64)" || { echo FAIL; tail -8 v3.log; }