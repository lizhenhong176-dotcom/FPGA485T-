#!/bin/bash
set -e
root=/data/lzh/v7re/data/m2/validation/init_word50
rm -rf "$root"
mkdir -p "$root"
for v in base1 base2 perturb; do
  cp -a /data/lzh/v7re/data/m2/fam/clbll_l/pin_a3 "$root/$v"
  d="$root/$v"
  cd "$d"
  rm -rf m2_pin design.bit design.bin design_run1.bit routed.dcp pips.txt rc build.log run.out build_*.backup.*
  if [ "$v" = "perturb" ]; then
    /data/lzh/venv/bin/python - "$d/top.v" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
s = p.read_text()
old = "64'hFFFFFFFFFFFFFFFE"
i = s.find(old)
j = s.find(old, i + len(old))
if j < 0:
    raise SystemExit('second INIT not found')
s = s[:j] + "64'hFFFFFFFFFFFFFFFF" + s[j + len(old):]
p.write_text(s)
PY
  fi
  nohup /data/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -nojournal -nolog -notrace -source build.tcl > run.out 2>&1 &
done
sleep 5
ps -ef | grep '[v]ivado' | wc -l
