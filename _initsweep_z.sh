export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/initsweep
cd $D || exit 1
for j in 0 1 2 3 4 5 6 7; do
  /opt/lzh/venv/bin/python - "$j" <<'PY'
import sys
j = int(sys.argv[1])
src = open("base8.v").read()
lines = src.split("\n")
n = [i for i, L in enumerate(lines) if "l%d (" % j in L][0]
lines[n] = lines[n].replace("64'h0000000000000000", "64'h0000000000000001")
open("z%d.v" % j, "w").write("\n".join(lines))
PY
  sed "s|base8.v|z$j.v|; s|b0.bit|z$j.bit|g; s|DONE_b0|DONE_z$j|" b0.tcl > z$j.tcl
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source z$j.tcl > z$j.log 2>&1
  if grep -q "DONE_z$j" z$j.log; then
    gzip -9 -c z$j.bit | base64 -w 0 > z$j.bit.b64
    echo "OK z$j $(stat -c %s z$j.bit.b64)"
  else
    echo "FAIL z$j"; tail -5 z$j.log
  fi
done
echo "ZDONE"