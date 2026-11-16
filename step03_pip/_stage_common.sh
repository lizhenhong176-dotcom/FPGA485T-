#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
D=/mnt/c/Users/S.tschai/bitrev
mkdir -p "$D"
cp -f "$V/lib/lnx64.o/librdi_common.so" "$D"/ 2>/dev/null
cp -f "$V/lib/lnx64.o/librdi_device.so" "$D"/ 2>/dev/null
cp -f "$V/lib/lnx64.o/librdiconfig.so" "$D"/ 2>/dev/null
ls -l "$D"/librdi_*.so "$D"/librdiconfig.so 2>/dev/null
