#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
echo "== files containing 're-install this software' =="
grep -rla "re-install this software" "$V/lib/lnx64.o" 2>/dev/null | head -10
echo "== also check data dir =="
grep -rla "re-install this software" "$V/data" 2>/dev/null | head -5
