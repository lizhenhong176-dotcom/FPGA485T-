#!/bin/bash
cd /opt/lzh/v7re/work/p1
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
mkdir -p out
echo === d8b_dense
vivado -mode batch -notrace -source build_d8b_dense.tcl -log ../p1_d8b_dense.log
echo RC=d8b_dense $?
echo === d9_wide
vivado -mode batch -notrace -source build_d9_wide.tcl -log ../p1_d9_wide.log
echo RC=d9_wide $?
echo === d10_long
vivado -mode batch -notrace -source build_d10_long.tcl -log ../p1_d10_long.log
echo RC=d10_long $?
echo === d11_mix
vivado -mode batch -notrace -source build_d11_mix.tcl -log ../p1_d11_mix.log
echo RC=d11_mix $?
echo === d12_fanout2
vivado -mode batch -notrace -source build_d12_fanout2.tcl -log ../p1_d12_fanout2.log
echo RC=d12_fanout2 $?
