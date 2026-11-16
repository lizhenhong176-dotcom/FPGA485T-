#!/bin/bash
cd /opt/lzh/v7re/work/p1
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
mkdir -p out
vivado -mode batch -source build_d1_lut_chain.tcl -nojournal -notrace > out/d1_lut_chain.log 2>&1 && echo "OK d1_lut_chain" || echo "FAIL d1_lut_chain"
vivado -mode batch -source build_d2_lut_big.tcl -nojournal -notrace > out/d2_lut_big.log 2>&1 && echo "OK d2_lut_big" || echo "FAIL d2_lut_big"
vivado -mode batch -source build_d3_carry.tcl -nojournal -notrace > out/d3_carry.log 2>&1 && echo "OK d3_carry" || echo "FAIL d3_carry"
vivado -mode batch -source build_d4_fanout.tcl -nojournal -notrace > out/d4_fanout.log 2>&1 && echo "OK d4_fanout" || echo "FAIL d4_fanout"
vivado -mode batch -source build_d5_srl.tcl -nojournal -notrace > out/d5_srl.log 2>&1 && echo "OK d5_srl" || echo "FAIL d5_srl"
vivado -mode batch -source build_d6_muxtree.tcl -nojournal -notrace > out/d6_muxtree.log 2>&1 && echo "OK d6_muxtree" || echo "FAIL d6_muxtree"
vivado -mode batch -source build_d7_spread.tcl -nojournal -notrace > out/d7_spread.log 2>&1 && echo "OK d7_spread" || echo "FAIL d7_spread"
vivado -mode batch -source build_d8_dense.tcl -nojournal -notrace > out/d8_dense.log 2>&1 && echo "OK d8_dense" || echo "FAIL d8_dense"
ls -1 out/*.bit | wc -l; ls -1 out/*.pips | wc -l; echo ALL_DONE
