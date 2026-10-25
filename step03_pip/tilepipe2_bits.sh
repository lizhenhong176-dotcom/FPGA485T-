#!/bin/bash
set -u
cd /opt/lzh/step03/tilepipe2 || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
for i in $(seq 1 60); do
  n=$(ls v_*.bit 2>/dev/null | wc -l); r=$(ls ref_*.bit 2>/dev/null | wc -l)
  echo "iter $i bits=$n refs=$r"
  [ "$n" -ge 900 ] && [ "$r" -ge 36 ] && break
  : > missing.txt
  for f in v_*.dcp ref_*.dcp; do b="${f%.dcp}.bit"; [ -f "$b" ] || echo "$f" >> missing.txt; done
  [ -s missing.txt ] && cat missing.txt | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
  sleep 20
done
echo "FINAL bits=$(ls v_*.bit | wc -l) refs=$(ls ref_*.bit | wc -l)"
