#!/bin/bash
set -e
root=/data/lzh/v7re/data/m2/validation
rm -rf "$root/clblm_r_x144y100"
mkdir -p "$root/clblm_r_x144y100"
cp -a "$root/clbll_l_y51/a3" "$root/clblm_r_x144y100/a3"
cp -a "$root/clbll_l_y51/a5" "$root/clblm_r_x144y100/a5"
for v in a3 a5; do
  d="$root/clblm_r_x144y100/$v"
  cd "$d"
  rm -rf m2_pin design.bit design.bin routed.dcp pips.txt rc build.log
  sed -i 's/SLICE_X8Y50/SLICE_X144Y99/g; s/SLICE_X8Y51/SLICE_X144Y100/g' top.xdc
  grep 'set_property LOC' top.xdc
  nohup ./run.sh >/dev/null 2>&1 &
done
sleep 5
ps -ef | grep '[v]ivado' | wc -l
