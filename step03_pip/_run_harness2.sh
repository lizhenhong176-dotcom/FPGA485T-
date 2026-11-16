#!/bin/bash
set +e
D=/mnt/c/Users/S.tschai/bitrev
V=/opt/lzh/Xilinx/Vivado/2017.2
cd "$D" || exit 1
export LD_LIBRARY_PATH="$V/lib/lnx64.o:$V/ids_lite/ISE/virtex7/lib/lin64:$LD_LIBRARY_PATH"
export LANG=C LC_ALL=C
./crc_harness 2>&1 | head -45
