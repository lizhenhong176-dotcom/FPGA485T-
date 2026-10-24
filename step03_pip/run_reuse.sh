#!/bin/bash
set -u
cd /opt/lzh/step03/pip1 || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
cp /mnt/c/Users/S.tschai/add_pip.py .
for W in EE2END0 GFAN0 LOGIC_OUTS_L12 NL1END0 NN2END0; do
  P=/opt/lzh/step03/pip1 ADD="${W}" OUT=v_${W}.dcp JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /opt/lzh/venv/bin/python add_pip.py > add_${W}.log 2>&1
  echo "== $W edit=$? $(grep -o "replaced.*" add_${W}.log | head -c 90)"
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs v_${W}.dcp v_${W}.bit -log bv_${W}.log -journal bv_${W}.jou > bv_${W}.out 2>&1
  echo "== $W bit=$?"
  /opt/lzh/venv/bin/python -c "import sys;sys.path.insert(0,\"/opt/lzh/v7re\");from bitstream.parser import frames_from_bit as F;from bitstream.frames import diff_frame_indices as DI,diff_bits_in_frame as DB;a=F(\"/opt/lzh/step03/pip1/a.bit\");b=F(\"/opt/lzh/step03/pip1/v_${W}.bit\");idx=DI(a,b);print(\"FRAMES\",idx);[print(\" \",f,[x for x in DB(a,b,f) if x[0]!=50]) for f in idx]"
done

