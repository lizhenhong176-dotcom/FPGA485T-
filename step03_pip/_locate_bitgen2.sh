#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
D="$V/bin/unwrapped/lnx64.o"
echo "== lnx64.o (first 40) =="
ls -la "$D" 2>/dev/null | head -40
echo "== bitgen =="
ls -l "$D"/bitgen* 2>/dev/null
echo "== file =="
file "$D"/bitgen 2>/dev/null
echo "== total files =="
ls "$D" 2>/dev/null | wc -l
