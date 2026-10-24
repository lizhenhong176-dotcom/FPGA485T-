#!/bin/bash
set -u
R=/opt/lzh/step03/reuse3
mkdir -p $R && cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
cp /opt/lzh/step03/pip2/top_y20.v .
cp /opt/lzh/step03/pip1/bit_any.tcl .
cp /mnt/c/Users/S.tschai/build_pin.tcl /mnt/c/Users/S.tschai/p3_make.py .
for PIN in A1 A2 A3 A4 A5 A6; do
  $V -mode batch -notrace -source build_pin.tcl -tclargs $PIN -log b_$PIN.log -journal b_$PIN.jou > b_$PIN.out 2>&1
  echo "BUILD $PIN $? $(grep -c BUILD_PIN_DONE b_$PIN.out)"
  $V -mode batch -notrace -source bit_any.tcl -tclargs p_$PIN.dcp a_$PIN.bit -log ba_$PIN.log -journal ba_$PIN.jou > ba_$PIN.out 2>&1
  DCP=p_$PIN.dcp EDF=p_$PIN.edf OUTDIR=$R TAG=$PIN NSRC=8 /opt/lzh/venv/bin/python p3_make.py > mk_$PIN.log 2>&1
  grep -E "sink|sources" mk_$PIN.log
done
$V -mode batch -notrace -source bit_any.tcl -tclargs ref_A6.dcp ref_A6.bit -log ref6.log -journal ref6.jou > ref6.out 2>&1
echo "bits_before=$(ls v_*.bit 2>/dev/null | wc -l)"
ls v_*.dcp ref_*.dcp | xargs -P 10 -I{} bash -c 'f="{}"; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs "$f" "${f%.dcp}.bit" -log "${f%.dcp}.bl" > "${f%.dcp}.bo" 2>&1'
echo "bits=$(ls v_*.bit 2>/dev/null | wc -l) refs=$(ls ref_*.bit 2>/dev/null | wc -l)"
