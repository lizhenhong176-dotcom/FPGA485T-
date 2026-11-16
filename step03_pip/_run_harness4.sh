#!/bin/bash
set +e
D=/mnt/c/Users/S.tschai/bitrev
V=/opt/lzh/Xilinx/Vivado/2017.2
cd "$D" || exit 1
g++ -O2 -o crc_harness2 crc_harness2.cpp -ldl 2>&1 | head -10
export LD_LIBRARY_PATH="$V/lib/lnx64.o:$V/ids_lite/ISE/virtex7/lib/lin64:$LD_LIBRARY_PATH"
export LANG=C LC_ALL=C XILINX_VIVADO="$V"
echo "=== librdi_bitstream.so ==="
./crc_harness2 "$V/lib/lnx64.o/librdi_bitstream.so" 2>&1 | head -20
echo "=== libBsFuji_Bitstream.so ==="
./crc_harness2 "$V/ids_lite/ISE/virtex7/lib/lin64/libBsFuji_Bitstream.so" 2>&1 | head -20
