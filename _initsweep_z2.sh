export LANG=C LC_ALL=C
D=/opt/lzh/v7re/work/initsweep
cd $D || exit 1
for j in 0 1 2 3 4 5 6 7; do
  sed "s|b0.v|z$j.v|; s|b0.bit|z$j.bit|g; s|DONE_b0|DONE_z$j|" b0.tcl > z$j.tcl
  grep -q "z$j.v" z$j.tcl || { echo "TCL 替换失败 j=$j"; exit 1; }
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source z$j.tcl > z$j.log 2>&1
  if grep -q "DONE_z$j" z$j.log; then
    rm -f z$j.bit.b64
    gzip -9 -c z$j.bit | base64 -w 0 > z$j.bit.b64
    echo "OK z$j $(stat -c %s z$j.bit.b64)"
  else
    echo "FAIL z$j"; tail -5 z$j.log
  fi
done
echo "ZDONE2"