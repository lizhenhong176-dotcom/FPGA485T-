#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
D=/mnt/c/Users/S.tschai/bitrev
export LD_LIBRARY_PATH="$V/lib/lnx64.o:$LD_LIBRARY_PATH"
export LANG=C LC_ALL=C XILINX_VIVADO="$V"
cp -f "$D/crc_harness2" "$V/bin/unwrapped/lnx64.o/crctest" 2>/dev/null
cd "$V/bin/unwrapped/lnx64.o" || exit 1
echo "--- A: binary inside \$XILINX_VIVADO ---"
./crctest "$V/lib/lnx64.o/librdi_bitstream.so" 2>&1 | head -8
echo "--- B: argv0 spoofed as vivado ---"
exec -a vivado ./crctest "$V/lib/lnx64.o/librdi_bitstream.so" 2>&1 | head -8
