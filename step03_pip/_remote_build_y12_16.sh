cd /opt/lzh/v7re/work/clkmux3
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
unset LANGUAGE
for k in 12 13 14 15 16; do
  cp y1_s0.v y${k}_s0.v
  sed -e "s|y2_s0|y${k}_s0|g" -e "s|BUFGCTRL_X0Y2|BUFGCTRL_X0Y${k}|g" out/y2_s0.tcl > out/y${k}_s0.tcl
  vivado -mode batch -source out/y${k}_s0.tcl -nojournal -notrace > out/y${k}_s0.log 2>&1 && echo "BUILD_OK y${k}" || echo "BUILD_FAIL y${k}"
done
ls -1 out/y1?_s0.bit 2>/dev/null | wc -l
echo "ALL_DONE"