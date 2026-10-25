#!/bin/bash
set -u
R=/opt/lzh/step03/reuse6; cd $R || exit 1
export XILINXD_LICENSE_FILE=/opt/lzh/Xilinx/Vivado_license_2037.lic LANG=C LC_ALL=C
cp /mnt/c/Users/S.tschai/make_ref.py /mnt/c/Users/S.tschai/holdout_diff.py .
for d in *.dcp; do case "$d" in ref_*) continue;; esac; t=${d%.dcp}; DCP=$d EDF=$t.edf OUT=ref_$t.dcp /opt/lzh/venv/bin/python make_ref.py > $t.sink 2>&1; done
echo "refs=$(ls ref_*.dcp 2>/dev/null | wc -l)"
for d in ref_*.dcp; do t=${d#ref_}; t=${t%.dcp}; /opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source bit_any.tcl -tclargs $d r_$t.bit -log r_$t.bl > r_$t.bo 2>&1 & done; wait
echo "r=$(ls r_*.bit 2>/dev/null | wc -l)"
/opt/lzh/venv/bin/python holdout_diff.py > holdout.log 2>&1; tail -n 30 holdout.log
cp holdout.json /mnt/c/Users/S.tschai/holdout.json
