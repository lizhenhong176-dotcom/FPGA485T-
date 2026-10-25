#!/bin/bash
set -u
R=/opt/lzh/step03/tilepipe; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/License/vivado.lic 2>/dev/null || true
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
for i in $(seq 1 300); do
  n=$(ls v_*.bit 2>/dev/null | wc -l)
  if [ "$n" -ge 900 ]; then echo "ALL $n"; break; fi
  for f in v_*.dcp; do b="${f%.dcp}.bit"; [ -f "$b" ] || echo "$f"; done > missing.txt
  cnt=$(wc -l < missing.txt)
  echo "iter $i done=$n missing=$cnt"
  if [ "$cnt" -gt 0 ]; then head -200 missing.txt | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1' ; fi
  sleep 20
done
echo "FINAL bits=$(ls v_*.bit | wc -l)"
/opt/lzh/venv/bin/python tilepipe_diff.py > tilepipe_diff.log 2>&1; echo "DIFF rc=$?"; tail -n 20 tilepipe_diff.log
cp tilepipe.json /mnt/c/Users/S.tschai/tilepipe.json 2>/dev/null && echo COPIED
