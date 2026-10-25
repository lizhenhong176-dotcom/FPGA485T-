set -u
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
V=/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado
R=/opt/lzh/step03/sweep1; cd $R || exit 1
cp /mnt/c/Users/S.tschai/netdump.py .
for COL in 8 40 80 120; do
for Y in 11 61 111 161 211 261 311; do
  TAG=S_${COL}_${Y}
  if [ -f $TAG.dcp ]; then :; else
    $V -mode batch -notrace -source build_bel.tcl -tclargs A5 SLICE_X${COL}Y${Y} A6LUT $TAG -log $TAG.bl -journal $TAG.j > $TAG.bo 2>&1
    grep -q BEL_DONE $TAG.bo || { echo "BUILDFAIL $TAG"; continue; }
  fi
  DCP=$TAG.dcp EDF=$TAG.edf OUT=$R TAG=$TAG /opt/lzh/venv/bin/python netdump.py > nd_$TAG.log 2>&1 || { echo "DUMPFAIL $TAG"; tail -3 nd_$TAG.log; continue; }
  [ -f $TAG.bit ] || $V -mode batch -notrace -source bit_any.tcl -tclargs $TAG.dcp $TAG.bit -log b1_$TAG.bl > b1_$TAG.bo 2>&1
  [ -f ref_$TAG.bit ] || $V -mode batch -notrace -source bit_any.tcl -tclargs ref_$TAG.dcp ref_$TAG.bit -log b2_$TAG.bl > b2_$TAG.bo 2>&1
  echo "DONE $TAG"
done
done
echo SWEEP1_ALLDONE