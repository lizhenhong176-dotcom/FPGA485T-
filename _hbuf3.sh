cd /opt/lzh/v7re/work/hbuf || exit 1
/opt/lzh/Xilinx/Vivado/2017.2/bin/vivado -mode batch -notrace -source d0.tcl > d0.log 2>&1
echo "RC=$?"
echo "--- grep ---"
grep -E "CHK_BH|DONE_d0|ERROR" d0.log | head -10
echo "--- tail ---"
tail -n 6 d0.log
