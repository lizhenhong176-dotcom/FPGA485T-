cd /opt/lzh/v7re/work/clkmux3
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
for k in 8 9 10 11; do
  vivado -mode batch -source out/y${k}_s0.tcl -nojournal -notrace > out/y${k}_s0.log 2>&1 && echo "BUILD_OK y${k}" || echo "BUILD_FAIL y${k}"
  grep -E "^(ERROR|CRITICAL)" out/y${k}_s0.log | head -3
  grep -c "DONE_y" out/y${k}_s0.log
done
ls -l out/y8_s0.bit out/y9_s0.bit out/y10_s0.bit out/y11_s0.bit 2>/dev/null | wc -l
echo "ALL_DONE"