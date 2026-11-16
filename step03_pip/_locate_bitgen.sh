#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
echo "== bin/unwrapped dirs =="
ls -la "$V/bin/unwrapped" 2>/dev/null | head -20
echo "== find bitgen =="
find "$V" -maxdepth 6 -name 'bitgen' -o -maxdepth 6 -name 'bitgen.exe' 2>/dev/null | head -10
echo "== lin64.o =="
ls -la "$V/bin/unwrapped/lin64.o" 2>/dev/null | head -40
