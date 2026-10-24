#!/bin/bash
set -e
root=/data/lzh/v7re/data/m2/validation
rm -rf "$root/clbll_l_y99_125"
mkdir -p "$root/clbll_l_y99_125"
cp -a "$root/clbll_l_y51/a3" "$root/clbll_l_y99_125/a3"
cp -a "$root/clbll_l_y51/a5" "$root/clbll_l_y99_125/a5"
for v in a3 a5; do
  d="$root/clbll_l_y99_125/$v"
  cd "$d"
  rm -rf m2_pin design.bit design.bin routed.dcp pips.txt rc build.log
  sed -i 's/SLICE_X8Y50/SLICE_X8Y99/g; s/SLICE_X8Y51/SLICE_X8Y125/g' top.xdc
  grep 'set_property LOC' top.xdc
  nohup ./run.sh >/dev/null 2>&1 &
done
sleep 5
ps -ef | grep '[v]ivado' | wc -l
