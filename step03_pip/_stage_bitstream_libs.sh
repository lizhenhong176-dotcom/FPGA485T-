#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
D=/mnt/c/Users/S.tschai/bitrev
mkdir -p "$D"
cp -f "$V/lib/lnx64.o/librdi_bitstream.so" "$D"/ 2>/dev/null
cp -f "$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitgen.so" "$D"/ 2>/dev/null
cp -f "$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitstream.so" "$D"/ 2>/dev/null
ls -l "$D"
