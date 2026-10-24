#!/bin/bash
set -u
R=/opt/lzh/step03/reuse3
cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
cp /mnt/c/Users/S.tschai/p3_make.py /mnt/c/Users/S.tschai/p3_diff.py .
for PIN in A1 A2 A3 A4 A5 A6; do
  DCP=p_$PIN.dcp EDF=p_$PIN.edf OUTDIR=$R TAG=$PIN NSRC=8 /opt/lzh/venv/bin/python p3_make.py > mk_$PIN.log 2>&1
  grep -E "sink|sources" mk_$PIN.log
done
ls v_*.dcp ref_*.dcp | xargs -P 12 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_*.bit | wc -l) refs=$(ls ref_*.bit | wc -l)"
/opt/lzh/venv/bin/python p3_diff.py > p3_diff.log 2>&1; tail -n 5 p3_diff.log
cp p3_bits.json /mnt/c/Users/S.tschai/p3_bits.json
