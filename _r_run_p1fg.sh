cd /opt/lzh/v7re/work/p1
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
vivado -mode batch -source build_p1.tcl -nojournal -notrace > build.log 2>&1
echo "VIVADO_EXIT=$?"
grep -E "BUILD_OK|BUILD_FAIL|ALL_DONE" build.log
ls -1 out/*.bit | wc -l
ls -1 out/*.pips | wc -l