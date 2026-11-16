#!/bin/bash
set +e
V=/opt/lzh/Xilinx/Vivado/2017.2
D=/mnt/c/Users/S.tschai/bitrev
export LD_LIBRARY_PATH="$V/lib/lnx64.o:$V/ids_lite/ISE/virtex7/lib/lin64:$LD_LIBRARY_PATH"
export LANG=C LC_ALL=C
export XILINX_VIVADO="$V"
export XILINX="$V"
export RDI_DATADIR="$V/data"
mkdir -p /opt/lzh/crctest && cp -f "$D/crc_harness" /opt/lzh/crctest/
cd /opt/lzh/crctest || exit 1
echo "--- try1: run inside XILINX_VIVADO env ---"
./crc_harness "$V/lib/lnx64.o/librdi_bitstream.so" 2>&1 | head -12
echo "--- try2: LD_PRELOAD nothing, different cwd ---"
cd "$V/bin" && /opt/lzh/crctest/crc_harness "$V/lib/lnx64.o/librdi_bitstream.so" 2>&1 | head -12
