#!/bin/bash
set -u
R=/opt/lzh/step03/tilepipe; mkdir -p $R; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/p6_make.py .
cp /opt/lzh/step03/reuse5/*.dcp /opt/lzh/step03/reuse5/*.edf . 2>/dev/null
cp /opt/lzh/step03/reuse5/*.sink . 2>/dev/null
for dcp in SLICE_*.dcp; do
  case "$dcp" in ref_*) continue;; esac
  TAG=${dcp%.dcp}
  DCP=$dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python p6_make.py > mk_$TAG.log 2>&1
  mv -f $TAG.sink $TAG.sink 2>/dev/null || true
done
echo "dcp: $(ls v_*.dcp 2>/dev/null | wc -l) ref: $(ls ref_*.dcp 2>/dev/null | wc -l)"
ls v_*.dcp ref_*.dcp 2>/dev/null | xargs -P 12 -I{} bash -c 'f="{}"; [ -f "${f%.dcp}.bit" ] && exit 0; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits: $(ls v_*.bit 2>/dev/null | wc -l) refs: $(ls ref_*.bit 2>/dev/null | wc -l)"
cp /mnt/c/Users/S.tschai/tilepipe_diff.py .
/opt/lzh/venv/bin/python tilepipe_diff.py > tilepipe.log 2>&1
tail -n 3 tilepipe.log
cp tilepipe.json /mnt/c/Users/S.tschai/tilepipe.json 2>/dev/null || true
