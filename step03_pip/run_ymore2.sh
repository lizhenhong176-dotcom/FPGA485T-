#!/bin/bash
set -u
cd /opt/lzh/step03/pip2 || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic
export LANG=C LC_ALL=C
for Y in 21 31 41 50 60; do
  YN=$((Y+1))
  sed "s/SLICE_X8Y20/SLICE_X8Y$Y/g; s/SLICE_X8Y21/SLICE_X8Y$YN/g" top_y20.xdc > top_y$Y.xdc
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source build_y.tcl -tclargs $Y -log build_y$Y.log -journal build_y$Y.jou > build_y$Y.out 2>&1
  echo "Y=$Y build=$? done=$(grep -c BUILD_DONE build_y$Y.out)"
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs routed_y$Y.dcp a_y$Y.bit -log ba_y$Y.log -journal ba_y$Y.jou > ba_y$Y.out 2>&1
  P=/opt/lzh/step03/pip2 DCP=routed_y$Y.dcp EDF=top_y$Y.edf OUT=b_y$Y.dcp JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /opt/lzh/venv/bin/python edit_y.py > edit_y$Y.log 2>&1
  echo "Y=$Y drop: $(grep -E "^drop" edit_y$Y.log)"
  /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs b_y$Y.dcp b_y$Y.bit -log bb_y$Y.log -journal bb_y$Y.jou > bb_y$Y.out 2>&1
  echo "Y=$Y diff:"
  /opt/lzh/venv/bin/python diff_y.py a_y$Y.bit b_y$Y.bit
done
