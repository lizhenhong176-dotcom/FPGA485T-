export LANG=C LC_ALL=C
export XILINX_VIVADO=/opt/lzh/Xilinx/Vivado/2017.2
export PATH=$XILINX_VIVADO/bin:$PATH
ls -la $XILINX_VIVADO/bin/vivado 2>&1 | head -2
echo "== version (无 license 也会打印)"
timeout 120 vivado -version 2>&1 | head -8
echo "rc=$?"
